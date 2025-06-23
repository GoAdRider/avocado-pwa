import 'package:hive/hive.dart';

part 'daily_stats.g.dart';

@HiveType(typeId: 5)
class DailyStats extends HiveObject {
  @HiveField(0)
  String date; // YYYY-MM-DD 형식

  @HiveField(1)
  int studiedWords;

  @HiveField(2)
  int correctAnswers;

  @HiveField(3)
  int wrongAnswers;

  @HiveField(4)
  int studyTimeMinutes;

  @HiveField(5)
  int streakDays;

  DailyStats({
    required this.date,
    this.studiedWords = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.studyTimeMinutes = 0,
    this.streakDays = 0,
  });

  DailyStats copyWith({
    String? date,
    int? studiedWords,
    int? correctAnswers,
    int? wrongAnswers,
    int? studyTimeMinutes,
    int? streakDays,
  }) {
    return DailyStats(
      date: date ?? this.date,
      studiedWords: studiedWords ?? this.studiedWords,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      studyTimeMinutes: studyTimeMinutes ?? this.studyTimeMinutes,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  /// 총 답안 수
  int get totalAnswers => correctAnswers + wrongAnswers;

  /// 정답률 (0-100%)
  double get accuracyRate {
    if (totalAnswers == 0) return 0.0;
    return (correctAnswers / totalAnswers) * 100;
  }

  /// 학습 시간 (시간:분 형식)
  String get formattedStudyTime {
    final hours = studyTimeMinutes ~/ 60;
    final minutes = studyTimeMinutes % 60;
    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }

  /// DateTime으로 변환
  DateTime get dateTime => DateTime.parse(date);

  /// 오늘인지 확인
  bool get isToday {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return date == todayString;
  }

  @override
  String toString() {
    return 'DailyStats(date: $date, studiedWords: $studiedWords, correctAnswers: $correctAnswers, wrongAnswers: $wrongAnswers, studyTimeMinutes: $studyTimeMinutes, streakDays: $streakDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyStats && other.date == date;
  }

  @override
  int get hashCode => date.hashCode;

  /// 오늘 날짜의 DailyStats 생성
  static DailyStats createToday() {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return DailyStats(date: dateString);
  }
}
