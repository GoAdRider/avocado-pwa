import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';
import '../models/favorite.dart';
import '../models/study_record.dart';
import '../models/word_stats.dart';
import '../models/daily_stats.dart';
import 'hive_service.dart';

class StudyService {
  static StudyService? _instance;
  static StudyService get instance => _instance ??= StudyService._internal();
  StudyService._internal();

  final HiveService _hiveService = HiveService.instance;

  /// 즐겨찾기 토글 (추가/제거)
  Future<bool> toggleFavorite(VocabularyWord word) async {
    try {
      final isCurrentlyFavorite = _hiveService.isFavorite(word.id);

      if (isCurrentlyFavorite) {
        // 즐겨찾기 제거
        await _hiveService.removeFavorite(word.id);
        return false; // 제거됨
      } else {
        // 즐겨찾기 추가
        await _hiveService.addFavorite(word.id, word.vocabularyFile);
        return true; // 추가됨
      }
    } catch (e) {
      throw Exception('즐겨찾기 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// 단어의 현재 즐겨찾기 상태 확인
  bool isFavorite(String wordId) {
    return _hiveService.isFavorite(wordId);
  }

  /// 학습 기록 저장
  Future<void> recordStudySession({
    required String wordId,
    required String vocabularyFile,
    required String studyMode, // 'card' or 'game'
    required bool isCorrect,
    String? gameType,
    int? score,
    String? hintType,
    int hintsUsed = 0,
    DateTime? sessionStart,
    DateTime? sessionEnd,
  }) async {
    try {
      // StudyRecord 생성 및 저장
      final studyRecord = StudyRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        wordId: wordId,
        vocabularyFile: vocabularyFile,
        studyDate: DateTime.now(),
        studyMode: studyMode,
        gameType: gameType,
        isCorrect: isCorrect,
        score: score,
        hintType: hintType,
        hintsUsed: hintsUsed,
        sessionStart: sessionStart,
        sessionEnd: sessionEnd,
      );

      await _hiveService.addStudyRecord(studyRecord);

      // addStudyRecord가 이미 WordStats와 DailyStats를 업데이트하므로
      // 별도 호출이 필요 없음
    } catch (e) {
      throw Exception('학습 기록 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// 학습 완료 처리
  Future<void> completeStudySession({
    required List<VocabularyWord> studiedWords,
    required String studyMode,
    int correctCount = 0,
    int wrongCount = 0,
    Duration? totalTime,
  }) async {
    try {
      // 각 단어별로 학습 기록 저장 (이미 개별적으로 저장되었을 수 있지만, 세션 완료 시 한번 더 기록)
      final sessionEnd = DateTime.now();
      final sessionStart = totalTime != null
          ? sessionEnd.subtract(totalTime)
          : sessionEnd.subtract(const Duration(minutes: 10)); // 기본값

      for (final word in studiedWords) {
        // 개별 단어 기록은 이미 recordStudySession에서 처리됨
        // 여기서는 세션 완료 이벤트만 기록할 수 있음
      }

      // 업적 시스템 업데이트 (추후 구현)
      await _updateAchievements(studiedWords.length, correctCount);
    } catch (e) {
      throw Exception('학습 세션 완료 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 업적 시스템 업데이트 (추후 구현)
  Future<void> _updateAchievements(
      int studiedWordCount, int correctCount) async {
    // TODO: 업적 시스템 구현
    // 예: 100개 단어 학습, 연속 7일 학습, 100% 정답률 등
  }

  /// 학습 가능한 단어 목록 조회 (필터링 적용)
  List<VocabularyWord> getStudyWords({
    required List<String> vocabularyFiles,
    List<String>? posFilters,
    List<String>? typeFilters,
    bool favoritesOnly = false,
    bool wrongWordsOnly = false,
  }) {
    List<VocabularyWord> words = [];

    // 선택된 어휘집들의 모든 단어 가져오기
    for (final vocabularyFile in vocabularyFiles) {
      final fileWords =
          _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
      words.addAll(fileWords);
    }

    // 즐겨찾기 필터 적용
    if (favoritesOnly) {
      words = words.where((word) => _hiveService.isFavorite(word.id)).toList();
    }

    // 틀린단어 필터 적용
    if (wrongWordsOnly) {
      words = words.where((word) {
        final stats = _hiveService.getWordStats(word.id);
        return stats?.isWrongWord == true;
      }).toList();
    }

    // 품사 필터 적용
    if (posFilters != null && posFilters.isNotEmpty) {
      words = words
          .where((word) => word.pos != null && posFilters.contains(word.pos!))
          .toList();
    }

    // 타입 필터 적용
    if (typeFilters != null && typeFilters.isNotEmpty) {
      words = words
          .where(
              (word) => word.type != null && typeFilters.contains(word.type!))
          .toList();
    }

    return words;
  }

  /// 학습 진행률 계산
  double calculateProgress(
      List<VocabularyWord> allWords, List<VocabularyWord> studiedWords) {
    if (allWords.isEmpty) return 0.0;
    return studiedWords.length / allWords.length;
  }

  /// 정답률 계산
  double calculateAccuracy(int correctCount, int totalAttempts) {
    if (totalAttempts == 0) return 0.0;
    return correctCount / totalAttempts;
  }

  /// 학습 세션 시작 기록
  Future<String> startStudySession({
    required List<VocabularyWord> words,
    required String studyMode,
    required List<String> vocabularyFiles,
  }) async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final sessionStart = DateTime.now();

    // 세션 시작 이벤트 기록 (필요시)
    // 향후 세션별 통계를 위해 사용할 수 있음

    return sessionId;
  }

  /// 학습 활동 기록 (카드 뒤집기, 이동 등)
  Future<void> recordStudyActivity({
    required String wordId,
    required String vocabularyFile,
    required String activityType, // 'flip', 'next', 'previous', 'view'
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 현재는 간단한 로깅만 수행
      // 향후 상세한 학습 패턴 분석을 위해 확장 가능
      print('Study Activity: $activityType for word $wordId');

      // 필요시 StudyRecord로 기록
      // await recordStudySession(
      //   wordId: wordId,
      //   vocabularyFile: vocabularyFile,
      //   studyMode: 'card',
      //   isCorrect: true, // 활동 자체는 성공으로 간주
      //   sessionStart: metadata?['sessionStart'],
      //   sessionEnd: DateTime.now(),
      // );
    } catch (e) {
      print('학습 활동 기록 실패: $e');
    }
  }

  /// 학습 세션 완료 처리 (향상된 버전)
  Future<Map<String, dynamic>> completeStudySessionEnhanced({
    required List<VocabularyWord> studiedWords,
    required String studyMode,
    required List<String> vocabularyFiles,
    String? sessionId,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    Map<String, int>? activityCounts, // 뒤집기, 이동 등 활동 통계
  }) async {
    try {
      final endTime = sessionEnd ?? DateTime.now();
      final startTime =
          sessionStart ?? endTime.subtract(const Duration(minutes: 10));
      final sessionDuration = endTime.difference(startTime);

      // 세션 완료 기록
      final sessionRecord = StudyRecord(
        id: '${sessionId ?? DateTime.now().millisecondsSinceEpoch}_session',
        wordId: 'session_complete',
        vocabularyFile: vocabularyFiles.join(','),
        studyDate: endTime,
        studyMode: studyMode,
        isCorrect: true,
        sessionStart: startTime,
        sessionEnd: endTime,
        hintsUsed: 0,
      );

      await _hiveService.addStudyRecord(sessionRecord);

      // 업적 시스템 업데이트
      await _updateAchievements(studiedWords.length, studiedWords.length);

      // 세션 통계 반환
      return {
        'sessionId': sessionId,
        'duration': sessionDuration.inMinutes,
        'wordsStudied': studiedWords.length,
        'vocabulariesUsed': vocabularyFiles.length,
        'activityCounts': activityCounts ?? {},
        'completedAt': endTime,
      };
    } catch (e) {
      throw Exception('학습 세션 완료 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 학습 모드별 색상 가져오기 (UI 로직을 서비스로 이동)
  Color getStudyModeColor(StudyMode mode) {
    switch (mode) {
      case StudyMode.cardStudy:
        return const Color(0xFF1976D2); // Colors.blue[700]
      case StudyMode.favoriteReview:
        return const Color(0xFFF57C00); // Colors.orange[700]
      case StudyMode.wrongWordsStudy:
        return const Color(0xFFD32F2F); // Colors.red[700]
      case StudyMode.urgentReview:
        return const Color(0xFFC62828); // Colors.red[800]
      case StudyMode.recommendedReview:
        return const Color(0xFFFFA000); // Colors.amber[700]
      case StudyMode.leisureReview:
        return const Color(0xFF388E3C); // Colors.green[700]
      case StudyMode.forgettingRisk:
        return const Color(0xFFB71C1C); // Colors.red[900]
    }
  }

  /// 학습 성과 요약 생성
  Map<String, dynamic> generateStudySessionSummary({
    required List<VocabularyWord> words,
    required String studyMode,
    DateTime? sessionStart,
    DateTime? sessionEnd,
  }) {
    final totalWords = words.length;
    final favoriteWords = words.where((word) => word.isFavorite).length;
    final wrongWords = words.where((word) => word.wrongCount > 0).length;
    final totalWrongCount =
        words.fold<int>(0, (sum, word) => sum + word.wrongCount);

    final sessionDuration = sessionEnd != null && sessionStart != null
        ? sessionEnd.difference(sessionStart)
        : null;

    return {
      'totalWords': totalWords,
      'favoriteWords': favoriteWords,
      'wrongWords': wrongWords,
      'totalWrongCount': totalWrongCount,
      'sessionDuration': sessionDuration?.inMinutes,
      'studyMode': studyMode,
      'completionRate': totalWords > 0 ? 100.0 : 0.0,
      'efficiency': sessionDuration != null && sessionDuration.inMinutes > 0
          ? totalWords / sessionDuration.inMinutes
          : null,
    };
  }
}
