import 'dart:async';
import '../../common/vocabulary_service.dart';
import '../../common/hive_service.dart';
import '../../common/daily_study_time_service.dart';

/// 학습 현황 통계를 담는 데이터 클래스
class StudyStatusStats {
  final int totalWords;
  final int totalFavorites;
  final int totalWrongWords;  // 게임 모드 미제공으로 0 유지
  final int totalWrongCount; // 게임 모드 미제공으로 0 유지
  final double averageAccuracy; // 게임 모드 미제공으로 0.0 유지
  final int studyStreak;

  const StudyStatusStats({
    this.totalWords = 0,
    this.totalFavorites = 0,
    this.totalWrongWords = 0,
    this.totalWrongCount = 0,
    this.averageAccuracy = 0.0,
    this.studyStreak = 0,
  });

  StudyStatusStats copyWith({
    int? totalWords,
    int? totalFavorites,
    int? totalWrongWords,
    int? totalWrongCount,
    double? averageAccuracy,
    int? studyStreak,
  }) {
    return StudyStatusStats(
      totalWords: totalWords ?? this.totalWords,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalWrongWords: totalWrongWords ?? this.totalWrongWords,
      totalWrongCount: totalWrongCount ?? this.totalWrongCount,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      studyStreak: studyStreak ?? this.studyStreak,
    );
  }
}

/// 학습 현황 서비스
class StudyStatusService {
  static StudyStatusService? _instance;
  static StudyStatusService get instance => _instance ??= StudyStatusService._internal();
  StudyStatusService._internal();

  final VocabularyService _vocabularyService = VocabularyService.instance;
  final HiveService _hiveService = HiveService.instance;
  final DailyStudyTimeService _dailyTimeService = DailyStudyTimeService.instance;

  // 상태 변경 알림을 위한 StreamController
  final StreamController<StudyStatusStats> _statsController =
      StreamController<StudyStatusStats>.broadcast();

  StudyStatusStats _currentStats = const StudyStatusStats();

  /// 현재 통계
  StudyStatusStats get currentStats => _currentStats;

  /// 상태 변경 스트림
  Stream<StudyStatusStats> get statsStream => _statsController.stream;

  /// 통계 새로고침
  Future<void> refreshStats() async {
    try {
      print('🔍 StudyStatusService: 통계 새로고침 시작');
      
      final vocabularyFiles = _vocabularyService.getAllVocabularyFileInfos();
      
      int totalWords = 0;
      int totalFavorites = 0;
      
      // 모든 어휘집의 통계 합산
      for (final fileInfo in vocabularyFiles) {
        totalWords += fileInfo.totalWords;
        totalFavorites += fileInfo.favoriteWords;
      }
      
      // 연속 학습일 계산 (RecentStudyService에서 가져올 수 있지만 일단 간단히 구현)
      int studyStreak = await _calculateStudyStreak();
      
      final newStats = StudyStatusStats(
        totalWords: totalWords,
        totalFavorites: totalFavorites,
        totalWrongWords: 0, // 게임 모드 미제공
        totalWrongCount: 0, // 게임 모드 미제공
        averageAccuracy: 0.0, // 게임 모드 미제공
        studyStreak: studyStreak,
      );
      
      _currentStats = newStats;
      _statsController.add(newStats);
      
      print('🔍 StudyStatusService: 통계 업데이트 완료 - 총 $totalWords개 단어, $totalFavorites개 즐겨찾기');
    } catch (e) {
      print('❌ StudyStatusService: 통계 새로고침 오류: $e');
    }
  }

  /// 연속 학습일 계산 (당일 누적 시간 기반)
  Future<int> _calculateStudyStreak() async {
    try {
      final box = _hiveService.generalBox;
      final now = DateTime.now();
      int streak = 0;
      bool foundTodayStudy = false;
      
      // 오늘부터 거꾸로 계산하여 연속된 학습일 찾기
      for (int i = 0; i < 30; i++) { // 최대 30일까지 확인
        final checkDate = now.subtract(Duration(days: i));
        final dateKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        final boxKey = 'daily_study_times:$dateKey';
        
        // 해당 날짜의 학습 시간 조회
        final studySeconds = box.get(boxKey, defaultValue: 0) as int;
        final studyDuration = Duration(seconds: studySeconds);
        
        // 1분 이상 학습했는지 확인
        bool hasStudyOnDate = studyDuration.inMinutes >= 1;
        
        if (hasStudyOnDate) {
          streak++;
          if (i == 0) foundTodayStudy = true; // 오늘 학습한 경우
        } else {
          // 학습이 없는 날이면 연속 끊김
          break;
        }
      }
      
      // 오늘 학습했지만 streak가 0이면 최소 1일
      if (foundTodayStudy && streak == 0) {
        streak = 1;
      }
      
      return streak;
    } catch (e) {
      print('❌ StudyStatusService: 연속 학습일 계산 오류: $e');
      return 0;
    }
  }

  /// 어휘집 변경 시 통계 업데이트 (외부에서 호출)
  void notifyVocabularyChanged() {
    refreshStats();
  }

  /// 학습 완료 시 통계 업데이트 (외부에서 호출)
  void notifyStudyCompleted() {
    refreshStats();
  }

  void dispose() {
    _statsController.close();
  }
}