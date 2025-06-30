import 'package:hive/hive.dart';

part 'study_progress.g.dart';

/// 학습 진행률 정보를 저장하는 모델
/// 특정 학습 세션(어휘집+설정 조합)의 진행 상태를 추적합니다.
@HiveType(typeId: 9)
class StudyProgress {
  @HiveField(0)
  final String sessionKey; // 세션 식별 키

  @HiveField(1)
  final int currentIndex; // 현재 진행 인덱스 (0부터 시작)

  @HiveField(2)
  final int totalWords; // 전체 단어 수

  @HiveField(3)
  final List<String> wordOrder; // 단어 순서 (섞기 상태 포함)

  @HiveField(4)
  final bool isShuffled; // 섞기 여부

  @HiveField(5)
  final DateTime lastStudyTime; // 마지막 학습 시간

  @HiveField(6)
  final String studyMode; // 학습 모드

  @HiveField(7)
  final String targetMode; // 표시 순서

  @HiveField(8)
  final List<String> vocabularyFiles; // 어휘집 파일들

  @HiveField(9)
  final List<String> posFilters; // 품사 필터

  @HiveField(10)
  final List<String> typeFilters; // 타입 필터

  StudyProgress({
    required this.sessionKey,
    required this.currentIndex,
    required this.totalWords,
    required this.wordOrder,
    required this.isShuffled,
    required this.lastStudyTime,
    required this.studyMode,
    required this.targetMode,
    required this.vocabularyFiles,
    required this.posFilters,
    required this.typeFilters,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progressRatio {
    if (totalWords == 0) return 0.0;
    return currentIndex / totalWords;
  }

  /// 진행률 퍼센트 (0 ~ 100)
  int get progressPercent {
    return (progressRatio * 100).round();
  }

  /// 첫 번째 카드인지 확인 (이어하기 다이얼로그 표시 여부 결정)
  bool get isAtStart {
    return currentIndex <= 0;
  }

  /// 마지막 카드인지 확인
  bool get isAtLastCard {
    return currentIndex >= totalWords - 1;
  }

  /// 학습 완료 여부
  bool get isCompleted {
    return currentIndex >= totalWords;
  }

  /// 진행률 텍스트 (예: "345/1020")
  String get progressText {
    final current = currentIndex + 1; // 1부터 시작하도록
    return '$current/$totalWords';
  }

  /// 새로운 진행률로 복사
  StudyProgress copyWith({
    String? sessionKey,
    int? currentIndex,
    int? totalWords,
    List<String>? wordOrder,
    bool? isShuffled,
    DateTime? lastStudyTime,
    String? studyMode,
    String? targetMode,
    List<String>? vocabularyFiles,
    List<String>? posFilters,
    List<String>? typeFilters,
  }) {
    return StudyProgress(
      sessionKey: sessionKey ?? this.sessionKey,
      currentIndex: currentIndex ?? this.currentIndex,
      totalWords: totalWords ?? this.totalWords,
      wordOrder: wordOrder ?? this.wordOrder,
      isShuffled: isShuffled ?? this.isShuffled,
      lastStudyTime: lastStudyTime ?? this.lastStudyTime,
      studyMode: studyMode ?? this.studyMode,
      targetMode: targetMode ?? this.targetMode,
      vocabularyFiles: vocabularyFiles ?? this.vocabularyFiles,
      posFilters: posFilters ?? this.posFilters,
      typeFilters: typeFilters ?? this.typeFilters,
    );
  }

  @override
  String toString() {
    return 'StudyProgress(sessionKey: $sessionKey, progress: $progressText, shuffled: $isShuffled)';
  }
}