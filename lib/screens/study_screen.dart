import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common/app_layout.dart';
import '../models/vocabulary_word.dart';

import '../utils/i18n/simple_i18n.dart';
import '../services/word_card/study_service.dart';
import '../services/home/vocabulary_list/vocabulary_list_service.dart';
import '../services/common/vocabulary_service.dart';
import '../services/common/temporary_delete_service.dart';
import '../services/common/study_progress_service.dart';
import '../services/common/daily_study_time_service.dart';
import '../services/home/study_status/study_status_service.dart';
import '../widgets/home/recent_study_section.dart';
// 위젯들을 직접 구현하므로 import 제거

class StudyScreen extends StatefulWidget {
  final StudyMode mode;
  final List<VocabularyWord> words;
  final List<String> vocabularyFiles;
  final String
      studyModePreference; // 위주 학습 설정: 'TargetVoca', 'ReferenceVoca', 'Random'
  final List<String> posFilters; // 품사 필터
  final List<String> typeFilters; // 어휘 타입 필터

  const StudyScreen({
    super.key,
    required this.mode,
    required this.words,
    required this.vocabularyFiles,
    this.studyModePreference = 'TargetVoca', // 기본값
    this.posFilters = const [],
    this.typeFilters = const [],
  });

  @override
  State<StudyScreen> createState() => StudyScreenState();
}

// StudyScreen 컨트롤러 - 외부에서 종료 가능하도록
class StudyScreenController {
  static final GlobalKey<StudyScreenState> _key = GlobalKey<StudyScreenState>();
  
  static GlobalKey<StudyScreenState> get key => _key;
  
  static void exitStudy() {
    _key.currentState?._exitStudy();
  }
}

class StudyScreenState extends State<StudyScreen> with WidgetsBindingObserver {
  late StudySession _session;
  late FocusNode _focusNode;
  final VocabularyService _vocabularyService = VocabularyService.instance;
  final TemporaryDeleteService _tempDeleteService = TemporaryDeleteService.instance;
  final StudyProgressService _progressService = StudyProgressService.instance;
  final DailyStudyTimeService _dailyTimeService = DailyStudyTimeService.instance;
  final StudyStatusService _studyStatusService = StudyStatusService.instance;

  // 학습 세션 추적을 위한 변수들
  String? _sessionId;
  DateTime? _sessionStartTime;
  
  // 학습 시간 표시용 변수들
  Duration _totalStudyTime = Duration.zero; // 실제 누적된 학습 시간
  late Timer _studyTimer;
  
  // 단어별 시간 제한용 변수들
  late DateTime _currentCardStartTime;
  Duration _currentCardTime = Duration.zero; // 현재 카드에서 소요된 시간
  bool _isMainTimerActive = true; // 전체 타이머 활성화 상태
  bool _isShuffled = false; // 섞기 상태 추적

  bool _isExiting = false; // 중복 종료 방지 플래그

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();
    _initializeSession();
    _startSessionTracking();
    _startTemporaryDeleteSession();
    _startStudyTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _studyTimer.cancel(); // 타이머 정리
    // dispose에서는 async를 사용할 수 없으므로 즉시 실행
    _saveCurrentProgress().then((_) {
      debugPrint('🧹 dispose에서 진행률 저장 완료');
      return _endSessionTracking();
    }).then((_) {
      debugPrint('🧹 dispose에서 세션 데이터 저장 완료');
    }).catchError((e) {
      debugPrint('❌ dispose에서 저장 실패: $e');
    });
    _tempDeleteService.endSession(); // 임시 삭제 세션 종료
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // 앱이 백그라운드로 가거나 종료될 때 세션 데이터 저장
      debugPrint('📱 앱 상태 변경: $state - 세션 데이터 저장');
      _endSessionTracking();
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

  /// 학습 세션 추적 시작
  void _startSessionTracking() async {
    try {
      _sessionStartTime = DateTime.now();
      final studyModeString = _getStudyModeString(widget.mode);
      _sessionId = await StudyService.instance.startStudySession(
        words: widget.words,
        studyMode: studyModeString,
        vocabularyFiles: widget.vocabularyFiles,
      );
      debugPrint('🏁 세션 시작: 모드=$studyModeString, ID=$_sessionId');
    } catch (e) {
      debugPrint('❌ 세션 추적 시작 실패: $e');
    }
  }

  /// 학습 세션 추적 종료
  Future<void> _endSessionTracking() async {
    if (_sessionId != null && _sessionStartTime != null) {
      try {
        final studyModeString = _getStudyModeString(widget.mode);
        debugPrint('💾 학습 세션 데이터 저장 시작: $_sessionId (모드: $studyModeString)');
        await StudyService.instance.completeStudySessionEnhanced(
          studiedWords: _session.words,
          studyMode: studyModeString,
          vocabularyFiles: widget.vocabularyFiles,
          sessionId: _sessionId,
          sessionStart: _sessionStartTime,
          sessionEnd: DateTime.now(),
          posFilters: widget.posFilters,
          typeFilters: widget.typeFilters,
          targetMode: widget.studyModePreference,
        );
        debugPrint('✅ 학습 세션 데이터 저장 완료: $_sessionId');
      } catch (e) {
        debugPrint('❌ 세션 추적 종료 실패: $e');
      }
    } else {
      debugPrint('ℹ️ 저장할 세션 데이터 없음');
    }
  }

  /// 임시 삭제 세션 시작
  void _startTemporaryDeleteSession() {
    final sessionKey = TemporaryDeleteService.createSessionKey(
      vocabularyFiles: widget.vocabularyFiles,
      studyMode: _getStudyModeString(widget.mode),
      targetMode: widget.studyModePreference,
      posFilters: widget.posFilters,
      typeFilters: widget.typeFilters,
    );
    _tempDeleteService.startSession(sessionKey);
    debugPrint('🗑️ 임시삭제 세션 시작: $sessionKey');
  }

  void _initializeSession() {
    // 기존 진행률 확인
    final sessionKey = StudyProgressService.createSessionKey(
      vocabularyFiles: widget.vocabularyFiles,
      studyMode: _getStudyModeString(widget.mode),
      targetMode: widget.studyModePreference,
      posFilters: widget.posFilters,
      typeFilters: widget.typeFilters,
    );
    
    final existingProgress = _progressService.getProgress(sessionKey);
    
    // 위주 학습 설정에 따라 초기 카드 면 결정
    CardSide initialSide = CardSide.front;

    if (widget.studyModePreference == 'ReferenceVoca') {
      // ReferenceVoca 모드: ReferenceVoca부터 시작
      initialSide = CardSide.back;
    } else if (widget.studyModePreference == 'Random') {
      // Random 모드: 무작위로 시작면 결정
      initialSide = [
        CardSide.front,
        CardSide.back
      ][DateTime.now().millisecondsSinceEpoch % 2];
    }
    // TargetVoca 모드는 기본값(CardSide.front) 사용

    // 단어들의 즐겨찾기 상태를 실제 데이터베이스와 동기화하고 임시삭제된 단어들 필터링
    final wordsWithFavoriteStatus = widget.words.where((word) {
      // 임시삭제된 단어는 제외
      return !_tempDeleteService.isTemporarilyDeleted(word.id);
    }).map((word) {
      final isFavorite = StudyService.instance.isFavorite(word.id);
      return word.copyWith(isFavorite: isFavorite);
    }).toList();

    // 이전 진행률이 있고 첫 번째 카드가 아니면 진행률 복원
    if (existingProgress != null && !existingProgress.isAtStart) {
      final orderedWords = _progressService.restoreWordOrder(wordsWithFavoriteStatus, existingProgress);
      _isShuffled = existingProgress.isShuffled; // 섞기 상태 복원
      _session = StudySession(
        mode: widget.mode,
        words: orderedWords,
        vocabularyFiles: List.from(widget.vocabularyFiles),
        currentSide: initialSide,
        currentIndex: existingProgress.currentIndex,
      );
    } else {
      // 일반적인 새 세션 시작
      _session = StudySession(
        mode: widget.mode,
        words: wordsWithFavoriteStatus,
        vocabularyFiles: List.from(widget.vocabularyFiles),
        currentSide: initialSide,
      );
    }
  }

  /// 학습 시간 타이머 시작
  void _startStudyTimer() {
    _startCardTimer(); // 첫 번째 카드 타이머도 시작
    
    _studyTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      
      if (_isMainTimerActive) {
        _currentCardTime = now.difference(_currentCardStartTime);
        
        // 현재 카드에서 정확히 10초 경과 체크
        if (_currentCardTime.inSeconds >= 10) {
          _isMainTimerActive = false;
          _currentCardTime = const Duration(seconds: 10); // 정확히 10초로 제한
          _totalStudyTime = _totalStudyTime + _currentCardTime;
          debugPrint('⏱️ 정확히 10초에서 타이머 정지');
        } else {
          // 1초마다 UI 업데이트 및 당일 누적 시간 업데이트
          if (_currentCardTime.inMilliseconds % 1000 < 100) {
            final currentSessionTime = _totalStudyTime + _currentCardTime;
            _dailyTimeService.updateCurrentTime(currentSessionTime);
            setState(() {});
          }
        }
      }
    });
    debugPrint('⏱️ 학습 시간 타이머 시작');
  }
  
  /// 현재 카드 타이머 시작 (새 카드로 이동 시)
  void _startCardTimer() {
    // 이전 카드에서 사용한 시간을 총 시간에 누적
    if (!_isMainTimerActive) {
      // 정지된 상태에서 카드 이동하는 경우 (이미 10초 누적됨)
      debugPrint('🎯 정지된 상태에서 카드 이동');
    } else {
      // 10초 전에 카드 이동하는 경우
      _totalStudyTime = _totalStudyTime + _currentCardTime;
      debugPrint('🎯 ${_currentCardTime.inSeconds}초에서 카드 이동');
    }
    
    _currentCardStartTime = DateTime.now();
    _currentCardTime = Duration.zero;
    _isMainTimerActive = true; // 새 카드에서는 타이머 재활성화
    debugPrint('🎯 새 카드 진입 - 타이머 재시작');
  }

  /// 학습 시간 포맷팅
  String _formatStudyDuration() {
    final currentTotal = _totalStudyTime + (_isMainTimerActive ? _currentCardTime : Duration.zero);
    final minutes = currentTotal.inMinutes;
    final seconds = currentTotal.inSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return _isMainTimerActive ? timeText : '$timeText ⏸';
  }

  void _updateSession(StudySession newSession) {
    setState(() {
      _session = newSession;
    });
  }

  // 키보드 이벤트 처리
  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _goToPrevious();
        return true;
      case LogicalKeyboardKey.arrowRight:
        _goToNext();
        return true;
      case LogicalKeyboardKey.space:
        _flipCard();
        return true;
      case LogicalKeyboardKey.keyR:
        _shuffleWords();
        return true;
      case LogicalKeyboardKey.keyS:
        _toggleFavorite();
        return true;
      case LogicalKeyboardKey.keyD:
        _toggleDetails();
        return true;
      case LogicalKeyboardKey.escape:
        _exitStudy();
        return true;
      case LogicalKeyboardKey.delete:
        _showWordDeleteDialog();
        return true;
      default:
        return false;
    }
  }

  // 네비게이션 메서드들
  void _goToPrevious() {
    if (_session.canGoPrevious) {
      // 위주 학습 설정에 따라 이전 카드의 시작면 결정
      CardSide prevSide = CardSide.front;

      if (widget.studyModePreference == 'ReferenceVoca') {
        prevSide = CardSide.back;
      } else if (widget.studyModePreference == 'Random') {
        // Random 모드: 매번 무작위로 시작면 결정
        prevSide = [
          CardSide.front,
          CardSide.back
        ][DateTime.now().millisecondsSinceEpoch % 2];
      }

      _updateSession(_session.copyWith(
        currentIndex: _session.currentIndex - 1,
        currentSide: prevSide,
      ));
      _startCardTimer(); // 새 카드로 이동 시 타이머 시작
    }
  }

  void _goToNext() {
    if (_session.canGoNext) {
      // 위주 학습 설정에 따라 다음 카드의 시작면 결정
      CardSide nextSide = CardSide.front;

      if (widget.studyModePreference == 'ReferenceVoca') {
        nextSide = CardSide.back;
      } else if (widget.studyModePreference == 'Random') {
        // Random 모드: 매번 무작위로 시작면 결정
        nextSide = [
          CardSide.front,
          CardSide.back
        ][DateTime.now().millisecondsSinceEpoch % 2];
      }

      _updateSession(_session.copyWith(
        currentIndex: _session.currentIndex + 1,
        currentSide: nextSide,
      ));
      _startCardTimer(); // 새 카드로 이동 시 타이머 시작
    } else if (_session.currentIndex == _session.words.length - 1) {
      // 마지막 단어에서 다음 버튼을 누르면 완료 처리
      _showCompletionDialog();
    }
  }

  void _flipCard() {
    _updateSession(_session.copyWith(
      currentSide: _session.currentSide == CardSide.front
          ? CardSide.back
          : CardSide.front,
    ));
  }

  void _shuffleWords() {
    final shuffledWords = List<VocabularyWord>.from(_session.words);
    shuffledWords.shuffle();
    _isShuffled = true; // 섞기 상태 업데이트

    // 위주 학습 설정에 따라 섞기 후 시작면 결정
    CardSide shuffledSide = CardSide.front;

    if (widget.studyModePreference == 'ReferenceVoca') {
      shuffledSide = CardSide.back;
    } else if (widget.studyModePreference == 'Random') {
      // Random 모드: 무작위로 시작면 결정
      shuffledSide = [
        CardSide.front,
        CardSide.back
      ][DateTime.now().millisecondsSinceEpoch % 2];
    }

    _updateSession(_session.copyWith(
      words: shuffledWords,
      currentIndex: 0,
      currentSide: shuffledSide,
    ));

    // 섞기 완료 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('study.words_shuffled', namespace: 'word_card')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite() async {
    final currentWord = _session.currentWord;
    if (currentWord == null) return;

    try {
      // StudyService를 통해 즐겨찾기 토글
      final isNowFavorite =
          await StudyService.instance.toggleFavorite(currentWord);

      // 메모리상 단어 객체 업데이트
      final updatedWord = currentWord.copyWith(
        isFavorite: isNowFavorite,
      );

      final updatedWords = List<VocabularyWord>.from(_session.words);
      updatedWords[_session.currentIndex] = updatedWord;

      _updateSession(_session.copyWith(words: updatedWords));

      // 즐겨찾기 토글 피드백
      final message = isNowFavorite
          ? tr('study.favorite_added', namespace: 'word_card')
          : tr('study.favorite_removed', namespace: 'word_card');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // 오류 발생 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('즐겨찾기 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleDetails() {
    _updateSession(_session.copyWith(
      showDetails: !_session.showDetails,
    ));
  }

  void _exitStudy() async {
    if (_isExiting) {
      debugPrint('⚠️ 이미 종료 중이므로 중복 처리 방지');
      return;
    }

    _isExiting = true;
    debugPrint('🚪 StudyScreen 종료 시작');

    try {
      // 진행률 저장
      await _saveCurrentProgress();
      
      // 당일 누적 시간에 현재 세션 시간 추가
      final finalSessionTime = _totalStudyTime + (_isMainTimerActive ? _currentCardTime : Duration.zero);
      await _dailyTimeService.addStudyTime(finalSessionTime);
      
      // 연속학습 통계 업데이트 (1분 이상 학습했을 때만)
      if (finalSessionTime.inMinutes >= 1) {
        _studyStatusService.refreshStats();
        debugPrint('📊 1분 이상 학습으로 연속학습 통계 업데이트');
      }
      
      // 세션 추적 종료 (데이터 저장 완료까지 대기)
      await _endSessionTracking();

      debugPrint('✅ StudyScreen 종료 완료 - 홈으로 이동');

      if (mounted) {
        // 어휘집 선택 상태 초기화
        VocabularyListService.instance.unselectAll();
        
        // 단순히 현재 화면 종료 (ESC와 동일한 방식)
        Navigator.of(context).pop();
        
        // 홈으로 돌아간 후 최근 학습 기록 새로고침
        WidgetsBinding.instance.addPostFrameCallback((_) {
          RecentStudySectionController.refresh();
        });
      }
    } catch (e) {
      debugPrint('❌ StudyScreen 종료 중 오류: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      _isExiting = false;
    }
  }

  void _showWordDeleteDialog() {
    final currentWord = _session.currentWord;
    if (currentWord == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tr('title', namespace: 'dialogs/word_delete'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 현재 단어 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('word_to_delete', namespace: 'dialogs/word_delete'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📝 ${currentWord.targetVoca}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '🔤 ${currentWord.referenceVoca}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '📂 ${currentWord.vocabularyFile}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(tr('question', namespace: 'dialogs/word_delete')),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('temporary_delete.title', namespace: 'dialogs/word_delete'),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[700]),
                    ),
                    Text(tr('temporary_delete.description_1', namespace: 'dialogs/word_delete')),
                    Text(tr('temporary_delete.description_2', namespace: 'dialogs/word_delete')),
                    Text(tr('temporary_delete.description_3', namespace: 'dialogs/word_delete')),
                    Text(tr('temporary_delete.description_4', namespace: 'dialogs/word_delete')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('permanent_delete.title', namespace: 'dialogs/word_delete'),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                    ),
                    Text(tr('permanent_delete.description_1', namespace: 'dialogs/word_delete')),
                    Text(tr('permanent_delete.description_2', namespace: 'dialogs/word_delete')),
                    Text(tr('permanent_delete.description_3', namespace: 'dialogs/word_delete')),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('buttons.cancel', namespace: 'dialogs/word_delete')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleWordDelete(currentWord, false); // 임시삭제
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange[700]),
              child: Text(tr('buttons.temporary_delete', namespace: 'dialogs/word_delete')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleWordDelete(currentWord, true); // 영구삭제
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
              child: Text(tr('buttons.permanent_delete', namespace: 'dialogs/word_delete')),
            ),
          ],
        );
      },
    );
  }

  void _handleWordDelete(VocabularyWord word, bool isPermanent) async {
    if (isPermanent) {
      // 영구삭제: 어휘집 파일에서 실제 단어 삭제
      try {
        final success = await _vocabularyService.deleteVocabularyWord(word.vocabularyFile, word.id);
        
        if (success) {
          // 모든 세션에서 단어 제거 (영구삭제되었으므로)
          _tempDeleteService.removeFromAllSessions(word.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('messages.permanent_deleted', namespace: 'dialogs/word_delete', params: {'word': word.targetVoca})),
              backgroundColor: Colors.red,
            ),
          );
          
          // 삭제된 단어를 세션에서 제거
          _removeWordFromSession(word);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('messages.delete_failed', namespace: 'dialogs/word_delete')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('messages.delete_error', namespace: 'dialogs/word_delete', params: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // 임시삭제: 이 세션에서만 제외 (최근 학습 기록에서도 제외됨)
      _tempDeleteService.addTemporarilyDeletedWord(word.id);
      _removeWordFromSession(word);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('messages.temporary_deleted', namespace: 'dialogs/word_delete', params: {'word': word.targetVoca})),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeWordFromSession(VocabularyWord word) {
    final updatedWords = _session.words.where((w) => w.id != word.id).toList();
    
    if (updatedWords.isEmpty) {
      // 모든 단어가 제거되면 학습 종료
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('messages.all_words_removed', namespace: 'dialogs/word_delete')),
          backgroundColor: Colors.red,
        ),
      );
      _exitStudy();
      return;
    }
    
    // 현재 인덱스 조정
    int newIndex = _session.currentIndex;
    if (newIndex >= updatedWords.length) {
      newIndex = updatedWords.length - 1;
    }
    
    // 세션 업데이트
    _updateSession(_session.copyWith(
      words: updatedWords,
      currentIndex: newIndex,
    ));
    
    setState(() {});
  }

  /// 현재 학습 진행률 저장
  Future<void> _saveCurrentProgress() async {
    try {
      final sessionKey = StudyProgressService.createSessionKey(
        vocabularyFiles: widget.vocabularyFiles,
        studyMode: _getStudyModeString(widget.mode),
        targetMode: widget.studyModePreference,
        posFilters: widget.posFilters,
        typeFilters: widget.typeFilters,
      );

      await _progressService.saveProgress(
        sessionKey: sessionKey,
        currentIndex: _session.currentIndex,
        words: _session.words,
        isShuffled: _isShuffled,
        studyMode: _getStudyModeString(widget.mode),
        targetMode: widget.studyModePreference,
        vocabularyFiles: widget.vocabularyFiles,
        posFilters: widget.posFilters,
        typeFilters: widget.typeFilters,
      );
    } catch (e) {
      debugPrint('📊 진행률 저장 실패: $e');
    }
  }

  /// 현재 학습 진행률 삭제 (학습 완료 시)
  Future<void> _clearCurrentProgress() async {
    try {
      final sessionKey = StudyProgressService.createSessionKey(
        vocabularyFiles: widget.vocabularyFiles,
        studyMode: _getStudyModeString(widget.mode),
        targetMode: widget.studyModePreference,
        posFilters: widget.posFilters,
        typeFilters: widget.typeFilters,
      );

      await _progressService.clearProgress(sessionKey);
    } catch (e) {
      debugPrint('📊 진행률 삭제 실패: $e');
    }
  }

  /// 이어하기 다이얼로그 표시

  void _showCompletionDialog() async {
    // 진행률 삭제 (학습 완료)
    await _clearCurrentProgress();
    
    // 세션 완료 처리 (데이터 저장 완료까지 대기)
    await _endSessionTracking();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Focus(
            autofocus: true,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Enter') {
                // 엔터 키 누르면 '학습 계속'
                Navigator.of(context).pop();
                _initializeSession();
                _startSessionTracking();
                setState(() {});
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(tr('study.congratulations', namespace: 'word_card')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr('study.study_completed', namespace: 'word_card')),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 팁: Enter 키를 누르면 학습을 계속할 수 있습니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debugPrint('🏠 학습 완료 다이얼로그에서 홈으로 돌아가기 클릭');
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    _exitStudy(); // 기존의 exitStudy 메서드 호출
                  },
                  child: Text(tr('study.return_to_home', namespace: 'word_card')),
                ),
                ElevatedButton(
                  autofocus: true, // 기본 포커스를 '학습 계속' 버튼에 설정
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    _initializeSession(); // 세션 초기화
                    _startSessionTracking(); // 새 세션 시작
                    setState(() {}); // 화면 새로고침
                  },
                  child: Text(tr('study.continue_study', namespace: 'word_card')),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  String _getModeTitle() {
    switch (_session.mode) {
      case StudyMode.cardStudy:
        return '📖 ${tr('modes.card_study', namespace: 'word_card')}';
      case StudyMode.favoriteReview:
        return '⭐ ${tr('modes.favorite_review', namespace: 'word_card')}';
      case StudyMode.wrongWordsStudy:
        return '❌ ${tr('modes.wrong_words_study', namespace: 'word_card')}';
      case StudyMode.urgentReview:
        return '🔴 ${tr('modes.urgent_review', namespace: 'word_card')}';
      case StudyMode.recommendedReview:
        return '🟡 ${tr('modes.recommended_review', namespace: 'word_card')}';
      case StudyMode.leisureReview:
        return '🟢 ${tr('modes.leisure_review', namespace: 'word_card')}';
      case StudyMode.forgettingRisk:
        return '⚠️ ${tr('modes.forgetting_risk', namespace: 'word_card')}';
    }
  }

  bool _shouldShowVocabularyInfo() {
    // 망각곡선 기반 복습은 어휘집 정보를 표시하지 않음
    return ![
      StudyMode.urgentReview,
      StudyMode.recommendedReview,
      StudyMode.leisureReview,
      StudyMode.forgettingRisk,
    ].contains(_session.mode);
  }

  // 진행도 바 위젯 구현
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 학습 모드 타이틀
          Expanded(
            flex: 3,
            child: Text(
              _getModeTitle(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getModeColor(),
                  ),
            ),
          ),

          // 선택된 어휘집 정보 (조건부 표시)
          if (_shouldShowVocabularyInfo()) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildVocabularyInfo(),
            ),
          ],

          const SizedBox(width: 16),

          // 진행도 정보
          Expanded(
            flex: 2,
            child: _buildProgressInfo(),
          ),
          
          const SizedBox(width: 16),
          
          // 학습 시간 정보
          Expanded(
            flex: 1,
            child: _buildStudyTimeInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyInfo() {
    final vocabularyCount = _session.vocabularyFiles.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tr('info.selected_vocabularies', namespace: 'word_card')}($vocabularyCount${tr('info.vocabulary_count_suffix', namespace: 'word_card')})',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStudyTimeInfo() {
    final timerColor = _isMainTimerActive ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isMainTimerActive ? Icons.timer : Icons.timer_off,
            size: 16,
            color: timerColor[700],
          ),
          const SizedBox(height: 2),
          Text(
            _formatStudyDuration(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: timerColor[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    final current = _session.currentIndex + 1;
    final total = _session.words.length;
    final percent = _session.progressPercent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tr('info.progress', namespace: 'word_card')}: $current/$total ($percent%)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getModeColor() {
    return StudyService.instance.getStudyModeColor(_session.mode);
  }

  // 학습 카드 위젯 구현
  Widget _buildStudyCard() {
    final word = _session.currentWord;
    if (word == null) {
      return const Center(
        child: Text('단어를 불러올 수 없습니다'),
      );
    }

    return Column(
      children: [
        // POS | Type 태그 영역
        _buildPosTypeTag(word),

        const SizedBox(height: 8),

        // 메인 카드
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 카드 상단 정보 패널
                _buildCardHeader(word),

                const SizedBox(height: 16),

                // 메인 단어 표시 영역
                Expanded(
                  child: _buildMainContent(word),
                ),

                const SizedBox(height: 16),

                // 설명 및 예시 토글 버튼
                _buildDetailsButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPosTypeTag(VocabularyWord word) {
    final pos = word.pos ?? '';
    final type = word.type ?? '';

    if (pos.isEmpty && type.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Text(
        pos.isNotEmpty && type.isNotEmpty
            ? '$pos | $type'
            : pos.isNotEmpty
                ? pos
                : type,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildCardHeader(VocabularyWord word) {
    return Row(
      children: [
        // 틀린횟수 표시
        if (word.wrongCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${tr('info.wrong_count_prefix', namespace: 'word_card')}${word.wrongCount}${tr('info.wrong_count_suffix', namespace: 'word_card')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

        const Spacer(),

        // 즐겨찾기 토글
        GestureDetector(
          onTap: _toggleFavorite,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: word.isFavorite
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              word.isFavorite ? Icons.star : Icons.star_border,
              color: word.isFavorite ? Colors.orange[600] : Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(VocabularyWord word) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 반응형 폰트 크기 계산
    double mainFontSize = 32;
    if (screenHeight < 500) {
      mainFontSize = 20;
    } else if (screenHeight < 600) {
      mainFontSize = 24;
    } else if (screenHeight < 700) {
      mainFontSize = 28;
    }
    
    // 화면 폭에 따른 추가 조정
    if (screenWidth < 400) {
      mainFontSize = mainFontSize * 0.8;
    }
    
    // 작은 화면 여부 판단
    final isSmallScreen = screenHeight < 600;
    
    if (isSmallScreen && _session.showDetails) {
      // 작은 화면 + 펼친 상태: 펼치기 내용만 전체 화면
      return Expanded(
        child: _buildDetailsContent(word),
      );
    }
    
    return Expanded(
      child: Column(
        children: [
          // 메인 단어 영역
          if (!_session.showDetails)
            // 기본 상태: 중앙 정렬
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 메인 단어
                    Text(
                      _getCurrentMainWord(word),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: mainFontSize,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 발음 (앞면에만 표시)
                    if (_session.currentSide == CardSide.front &&
                        word.targetPronunciation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '[${word.targetPronunciation}]',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              fontSize: mainFontSize * 0.5,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          if (_session.showDetails) ...[
            // 펼친 상태: 메인 단어 위로 이동
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 메인 단어
                  Text(
                    _getCurrentMainWord(word),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: mainFontSize,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 발음 (앞면에만 표시)
                  if (_session.currentSide == CardSide.front &&
                      word.targetPronunciation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '[${word.targetPronunciation}]',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: mainFontSize * 0.5,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // 구분선
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            
            // 상세 정보 내용
            Expanded(
              child: _buildDetailsContent(word),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsContent(VocabularyWord word) {
    final isTargetSide = _session.currentSide == CardSide.front;
    final description = isTargetSide ? word.targetDesc : word.referenceDesc;
    final example = isTargetSide ? word.targetEx : word.referenceEx;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isWideScreen = screenWidth > 600; // 600px 이상이면 가로 레이아웃
            
            if ((description != null && description.isNotEmpty) && 
                (example != null && example.isNotEmpty)) {
              // 둘 다 있을 때: 화면 크기에 따른 반응형 레이아웃
              if (isWideScreen) {
                // 넓은 화면: 가로 2열
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            tr('content.description_label', namespace: 'word_card'),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            tr('content.example_label', namespace: 'word_card'),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              '"$example"',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blue[800],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // 좁은 화면: 세로 배치
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 설명 섹션
                    Text(
                      tr('content.description_label', namespace: 'word_card'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // 예문 섹션
                    Text(
                      tr('content.example_label', namespace: 'word_card'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '"$example"',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue[800],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }
            }
            
            // 설명만 있을 때
            if ((description != null && description.isNotEmpty) && 
                (example == null || example.isEmpty)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tr('content.description_label', namespace: 'word_card'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }
            
            // 예문만 있을 때
            if ((description == null || description.isEmpty) && 
                (example != null && example.isNotEmpty)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tr('content.example_label', namespace: 'word_card'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '"$example"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.blue[800],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            
            // 둘 다 없을 때 (빈 컨테이너)
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleDetails,
        icon: const Icon(Icons.menu_book),
        label: Text(
          _session.showDetails
              ? tr('content.collapse_details', namespace: 'word_card')
              : tr('content.expand_details', namespace: 'word_card'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _session.showDetails ? Colors.grey[200] : Colors.blue[50],
          foregroundColor:
              _session.showDetails ? Colors.grey[700] : Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _getCurrentMainWord(VocabularyWord word) {
    return _session.currentSide == CardSide.front
        ? word.targetVoca
        : word.referenceVoca;
  }

  @override
  Widget build(BuildContext context) {
    // 언어 변경은 LanguageNotifier가 자동으로 처리

    if (_session.words.isEmpty) {
      return AppLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.library_books_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                tr('content.no_words_available', namespace: 'word_card'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _exitStudy,
                child: Text(tr('study.return_to_home', namespace: 'word_card')),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          debugPrint('⚠️ PopScope: 이미 pop됨');
          return;
        }

        debugPrint('🔄 PopScope 감지: StudyScreen 나가기 시작');
        debugPrint('📊 현재 세션 ID: $_sessionId');
        debugPrint('🕐 세션 시작 시간: $_sessionStartTime');

        _exitStudy();

        debugPrint('✅ PopScope 완료: StudyScreen 나가기 끝');
      },
      child: AppLayout(
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            return _handleKeyEvent(event)
                ? KeyEventResult.handled
                : KeyEventResult.ignored;
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final isVerySmallScreen = screenHeight < 400;
              final isSmallScreen = screenHeight < 600;
              
              return Column(
                children: [
                  // 학습 진행 상태 바 (작은 화면에서는 압축)
                  if (!isVerySmallScreen) _buildProgressBar(),
                  
                  if (isVerySmallScreen)
                    // 극소 화면에서는 진행바를 최소화
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${_session.currentIndex + 1}/${_session.words.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (_session.currentIndex + 1) / _session.words.length,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 메인 학습 영역 - 단어 카드 최우선
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                      child: Column(
                        children: [
                          // 단어 카드 - 최소 높이 보장
                          Expanded(
                            flex: isSmallScreen ? 8 : 6, // 작은 화면에서는 더 많은 비율 할당
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: isVerySmallScreen ? 200 : 300,
                              ),
                              child: _buildStudyCard(),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 8 : 16),

                          // 네비게이션 버튼들 (작은 화면에서는 압축)
                          if (!isVerySmallScreen)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _session.canGoPrevious ? _goToPrevious : null,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                    ),
                                    child: Text(
                                      tr('controls.previous', namespace: 'word_card'),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _flipCard,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                    ),
                                    child: Text(
                                      tr('controls.flip', namespace: 'word_card'),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _shuffleWords,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                    ),
                                    child: Text(
                                      tr('controls.shuffle', namespace: 'word_card'),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _goToNext,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                    ),
                                    child: Text(
                                      tr('controls.next', namespace: 'word_card'),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // 극소 화면에서는 간소화된 버튼
                          if (isVerySmallScreen)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: _session.canGoPrevious ? _goToPrevious : null,
                                  icon: const Icon(Icons.chevron_left),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: _flipCard,
                                  icon: const Icon(Icons.flip_to_back),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: _shuffleWords,
                                  icon: const Icon(Icons.shuffle),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: _goToNext,
                                  icon: const Icon(Icons.chevron_right),
                                  iconSize: 20,
                                ),
                              ],
                            ),

                          // 키보드 안내 (작은 화면에서는 숨김)
                          if (!isSmallScreen) ...[
                            const SizedBox(height: 8),
                            Text(
                              tr('controls.keyboard_guide', namespace: 'word_card'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
