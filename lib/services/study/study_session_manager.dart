import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/vocabulary_word.dart';
import '../common/study_progress_service.dart';
import '../common/temporary_delete_service.dart';
import '../word_card/study_service.dart';

/// 학습 세션의 상태와 진행률을 관리하는 서비스
class StudySessionManager {
  static StudySessionManager? _instance;
  static StudySessionManager get instance => _instance ??= StudySessionManager._internal();
  StudySessionManager._internal();

  final StudyProgressService _progressService = StudyProgressService.instance;
  final TemporaryDeleteService _tempDeleteService = TemporaryDeleteService.instance;
  
  StudySession? _currentSession;
  String? _sessionId;
  DateTime? _sessionStartTime;
  bool _isShuffled = false;
  
  // 스트림 컨트롤러
  final StreamController<StudySession> _sessionController = StreamController<StudySession>.broadcast();
  
  /// 세션 상태 스트림
  Stream<StudySession> get sessionStream => _sessionController.stream;
  
  /// 현재 세션 getter
  StudySession? get currentSession => _currentSession;
  
  /// 세션 초기화
  Future<StudySession> initializeSession({
    required StudyMode mode,
    required List<VocabularyWord> words,
    required List<String> vocabularyFiles,
    required String studyModePreference,
    required List<String> posFilters,
    required List<String> typeFilters,
  }) async {
    // 기존 진행률 확인
    final sessionKey = StudyProgressService.createSessionKey(
      vocabularyFiles: vocabularyFiles,
      studyMode: _getStudyModeString(mode),
      targetMode: studyModePreference,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
    
    final existingProgress = _progressService.getProgress(sessionKey);
    
    // 위주 학습 설정에 따라 초기 카드 면 결정
    CardSide initialSide = _getInitialCardSide(studyModePreference);
    
    // 단어들의 즐겨찾기 상태 동기화 및 임시삭제된 단어 필터링
    final processedWords = await _processWords(words);
    
    // 이전 진행률이 있고 첫 번째 카드가 아니면 진행률 복원
    if (existingProgress != null && !existingProgress.isAtStart) {
      final orderedWords = _progressService.restoreWordOrder(processedWords, existingProgress);
      _isShuffled = existingProgress.isShuffled;
      
      _currentSession = StudySession(
        mode: mode,
        words: orderedWords,
        vocabularyFiles: List.from(vocabularyFiles),
        currentSide: initialSide,
        currentIndex: existingProgress.currentIndex,
      );
    } else {
      // 새 세션 시작
      _currentSession = StudySession(
        mode: mode,
        words: processedWords,
        vocabularyFiles: List.from(vocabularyFiles),
        currentSide: initialSide,
      );
    }
    
    // 세션 추적 시작
    await _startSessionTracking(mode, vocabularyFiles);
    
    // 임시 삭제 세션 시작
    _startTemporaryDeleteSession(mode, vocabularyFiles, studyModePreference, posFilters, typeFilters);
    
    _sessionController.add(_currentSession!);
    return _currentSession!;
  }
  
  /// 세션 업데이트
  void updateSession(StudySession newSession) {
    _currentSession = newSession;
    _sessionController.add(_currentSession!);
  }
  
  /// 이전 카드로 이동
  void goToPrevious(String studyModePreference) {
    if (_currentSession == null || !_currentSession!.canGoPrevious) return;
    
    final prevSide = _getInitialCardSide(studyModePreference);
    
    updateSession(_currentSession!.copyWith(
      currentIndex: _currentSession!.currentIndex - 1,
      currentSide: prevSide,
    ));
  }
  
  /// 다음 카드로 이동
  void goToNext(String studyModePreference) {
    if (_currentSession == null || !_currentSession!.canGoNext) return;
    
    final nextSide = _getInitialCardSide(studyModePreference);
    
    updateSession(_currentSession!.copyWith(
      currentIndex: _currentSession!.currentIndex + 1,
      currentSide: nextSide,
    ));
  }
  
  /// 카드 뒤집기
  void flipCard() {
    if (_currentSession == null) return;
    
    updateSession(_currentSession!.copyWith(
      currentSide: _currentSession!.currentSide == CardSide.front
          ? CardSide.back
          : CardSide.front,
    ));
  }
  
  /// 단어 섞기
  void shuffleWords(String studyModePreference) {
    if (_currentSession == null) return;
    
    final shuffledWords = List<VocabularyWord>.from(_currentSession!.words);
    shuffledWords.shuffle();
    _isShuffled = true;
    
    final shuffledSide = _getInitialCardSide(studyModePreference);
    
    updateSession(_currentSession!.copyWith(
      words: shuffledWords,
      currentIndex: 0,
      currentSide: shuffledSide,
    ));
  }
  
  /// 즐겨찾기 토글
  Future<bool> toggleFavorite() async {
    if (_currentSession == null) return false;
    
    final currentWord = _currentSession!.currentWord;
    if (currentWord == null) return false;
    
    final isNowFavorite = await StudyService.instance.toggleFavorite(currentWord);
    
    // 메모리상 단어 객체 업데이트
    final updatedWord = currentWord.copyWith(isFavorite: isNowFavorite);
    final updatedWords = List<VocabularyWord>.from(_currentSession!.words);
    updatedWords[_currentSession!.currentIndex] = updatedWord;
    
    updateSession(_currentSession!.copyWith(words: updatedWords));
    
    return isNowFavorite;
  }
  
  /// 세션에서 단어 제거
  void removeWordFromSession(VocabularyWord word) {
    if (_currentSession == null) return;
    
    final updatedWords = _currentSession!.words.where((w) => w.id != word.id).toList();
    
    if (updatedWords.isEmpty) {
      // 모든 단어가 제거되면 세션 종료
      _currentSession = _currentSession!.copyWith(words: []);
      _sessionController.add(_currentSession!);
      return;
    }
    
    // 현재 인덱스 조정
    int newIndex = _currentSession!.currentIndex;
    if (newIndex >= updatedWords.length) {
      newIndex = updatedWords.length - 1;
    }
    
    updateSession(_currentSession!.copyWith(
      words: updatedWords,
      currentIndex: newIndex,
    ));
  }
  
  /// 세부사항 토글
  void toggleDetails() {
    if (_currentSession == null) return;
    
    updateSession(_currentSession!.copyWith(
      showDetails: !_currentSession!.showDetails,
    ));
  }
  
  /// 현재 진행률 저장
  Future<void> saveCurrentProgress(List<String> vocabularyFiles, String studyModePreference, List<String> posFilters, List<String> typeFilters) async {
    if (_currentSession == null) return;
    
    try {
      final sessionKey = StudyProgressService.createSessionKey(
        vocabularyFiles: vocabularyFiles,
        studyMode: _getStudyModeString(_currentSession!.mode),
        targetMode: studyModePreference,
        posFilters: posFilters,
        typeFilters: typeFilters,
      );

      await _progressService.saveProgress(
        sessionKey: sessionKey,
        currentIndex: _currentSession!.currentIndex,
        words: _currentSession!.words,
        isShuffled: _isShuffled,
        studyMode: _getStudyModeString(_currentSession!.mode),
        targetMode: studyModePreference,
        vocabularyFiles: vocabularyFiles,
        posFilters: posFilters,
        typeFilters: typeFilters,
      );
    } catch (e) {
      debugPrint('📊 진행률 저장 실패: $e');
    }
  }
  
  /// 진행률 삭제 (학습 완료 시)
  Future<void> clearCurrentProgress(List<String> vocabularyFiles, String studyModePreference, List<String> posFilters, List<String> typeFilters) async {
    if (_currentSession == null) return;
    
    try {
      final sessionKey = StudyProgressService.createSessionKey(
        vocabularyFiles: vocabularyFiles,
        studyMode: _getStudyModeString(_currentSession!.mode),
        targetMode: studyModePreference,
        posFilters: posFilters,
        typeFilters: typeFilters,
      );

      await _progressService.clearProgress(sessionKey);
    } catch (e) {
      debugPrint('📊 진행률 삭제 실패: $e');
    }
  }
  
  /// 세션 종료
  Future<void> endSession() async {
    if (_sessionId != null && _sessionStartTime != null && _currentSession != null) {
      try {
        final studyModeString = _getStudyModeString(_currentSession!.mode);
        await StudyService.instance.completeStudySessionEnhanced(
          studiedWords: _currentSession!.words,
          studyMode: studyModeString,
          vocabularyFiles: _currentSession!.vocabularyFiles,
          sessionId: _sessionId,
          sessionStart: _sessionStartTime,
          sessionEnd: DateTime.now(),
          posFilters: [], // 별도 관리 필요
          typeFilters: [], // 별도 관리 필요
          targetMode: 'TargetVoca', // 별도 관리 필요
        );
        debugPrint('✅ 학습 세션 데이터 저장 완료: $_sessionId');
      } catch (e) {
        debugPrint('❌ 세션 종료 실패: $e');
      }
    }
    
    _tempDeleteService.endSession();
    _sessionId = null;
    _sessionStartTime = null;
    _currentSession = null;
    _isShuffled = false;
  }
  
  /// 단어 처리 (즐겨찾기 상태 동기화 및 임시삭제 필터링)
  Future<List<VocabularyWord>> _processWords(List<VocabularyWord> words) async {
    return words.where((word) {
      return !_tempDeleteService.isTemporarilyDeleted(word.id);
    }).map((word) {
      final isFavorite = StudyService.instance.isFavorite(word.id);
      return word.copyWith(isFavorite: isFavorite);
    }).toList();
  }
  
  /// 세션 추적 시작
  Future<void> _startSessionTracking(StudyMode mode, List<String> vocabularyFiles) async {
    try {
      _sessionStartTime = DateTime.now();
      final studyModeString = _getStudyModeString(mode);
      _sessionId = await StudyService.instance.startStudySession(
        words: _currentSession!.words,
        studyMode: studyModeString,
        vocabularyFiles: vocabularyFiles,
      );
      debugPrint('🏁 세션 시작: 모드=$studyModeString, ID=$_sessionId');
    } catch (e) {
      debugPrint('❌ 세션 추적 시작 실패: $e');
    }
  }
  
  /// 임시 삭제 세션 시작
  void _startTemporaryDeleteSession(StudyMode mode, List<String> vocabularyFiles, String studyModePreference, List<String> posFilters, List<String> typeFilters) {
    final sessionKey = TemporaryDeleteService.createSessionKey(
      vocabularyFiles: vocabularyFiles,
      studyMode: _getStudyModeString(mode),
      targetMode: studyModePreference,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
    _tempDeleteService.startSession(sessionKey);
    debugPrint('🗑️ 임시삭제 세션 시작: $sessionKey');
  }
  
  /// 초기 카드 면 결정
  CardSide _getInitialCardSide(String studyModePreference) {
    switch (studyModePreference) {
      case 'ReferenceVoca':
        return CardSide.back;
      case 'Random':
        return [CardSide.front, CardSide.back][DateTime.now().millisecondsSinceEpoch % 2];
      default:
        return CardSide.front;
    }
  }
  
  /// StudyMode enum을 문자열로 변환
  String _getStudyModeString(StudyMode mode) {
    switch (mode) {
      case StudyMode.cardStudy:
        return 'card';
      case StudyMode.favoriteReview:
        return 'favorites';
      case StudyMode.wrongWordsStudy:
        return 'wrong_words';
      case StudyMode.urgentReview:
        return 'urgent_review';
      case StudyMode.recommendedReview:
        return 'recommended_review';
      case StudyMode.leisureReview:
        return 'leisure_review';
      case StudyMode.forgettingRisk:
        return 'forgetting_risk';
    }
  }
  
  /// 서비스 정리
  void dispose() {
    _sessionController.close();
  }
}