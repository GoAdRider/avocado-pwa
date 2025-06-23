import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 6)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String achievementType; // 'words_100', 'streak_7', 'words_1000', etc.

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime achievedDate;

  @HiveField(5)
  int targetValue;

  @HiveField(6)
  int currentValue;

  @HiveField(7)
  bool isCompleted;

  Achievement({
    required this.id,
    required this.achievementType,
    required this.title,
    required this.description,
    DateTime? achievedDate,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
  }) : achievedDate = achievedDate ?? DateTime.now();

  Achievement copyWith({
    String? id,
    String? achievementType,
    String? title,
    String? description,
    DateTime? achievedDate,
    int? targetValue,
    int? currentValue,
    bool? isCompleted,
  }) {
    return Achievement(
      id: id ?? this.id,
      achievementType: achievementType ?? this.achievementType,
      title: title ?? this.title,
      description: description ?? this.description,
      achievedDate: achievedDate ?? this.achievedDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// 진행률 (0-100%)
  double get progressPercent {
    if (targetValue == 0) return 0.0;
    final progress = (currentValue / targetValue) * 100;
    return progress > 100 ? 100.0 : progress;
  }

  /// 달성까지 남은 값
  int get remainingValue {
    final remaining = targetValue - currentValue;
    return remaining > 0 ? remaining : 0;
  }

  /// 업적 완료 체크 및 업데이트
  void updateProgress(int newValue) {
    currentValue = newValue;
    if (currentValue >= targetValue && !isCompleted) {
      isCompleted = true;
      achievedDate = DateTime.now();
    }
  }

  /// 업적 타입별 아이콘
  String get icon {
    switch (achievementType) {
      case 'words_100':
      case 'words_500':
      case 'words_1000':
        return '📚';
      case 'streak_7':
      case 'streak_30':
      case 'streak_100':
        return '🔥';
      case 'accuracy_90':
      case 'accuracy_95':
        return '🎯';
      case 'games_10':
      case 'games_50':
        return '🎮';
      case 'favorites_50':
      case 'favorites_100':
        return '⭐';
      default:
        return '🏆';
    }
  }

  /// 업적 색상
  String get color {
    if (isCompleted) return '#FFD700'; // 금색
    if (progressPercent >= 75) return '#C0C0C0'; // 은색
    if (progressPercent >= 50) return '#CD7F32'; // 동색
    return '#999999'; // 회색
  }

  @override
  String toString() {
    return 'Achievement(id: $id, achievementType: $achievementType, title: $title, description: $description, targetValue: $targetValue, currentValue: $currentValue, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 기본 업적들 생성
  static List<Achievement> createDefaultAchievements() {
    return [
      // 단어 학습 업적
      Achievement(
        id: 'words_100',
        achievementType: 'words_100',
        title: '첫 걸음',
        description: '100개 단어 학습하기',
        targetValue: 100,
      ),
      Achievement(
        id: 'words_500',
        achievementType: 'words_500',
        title: '어휘력 확장',
        description: '500개 단어 학습하기',
        targetValue: 500,
      ),
      Achievement(
        id: 'words_1000',
        achievementType: 'words_1000',
        title: '단어 마스터',
        description: '1000개 단어 학습하기',
        targetValue: 1000,
      ),

      // 연속 학습 업적
      Achievement(
        id: 'streak_7',
        achievementType: 'streak_7',
        title: '한 주 완주',
        description: '7일 연속 학습하기',
        targetValue: 7,
      ),
      Achievement(
        id: 'streak_30',
        achievementType: 'streak_30',
        title: '한 달 도전',
        description: '30일 연속 학습하기',
        targetValue: 30,
      ),

      // 정확도 업적
      Achievement(
        id: 'accuracy_90',
        achievementType: 'accuracy_90',
        title: '정확한 학습',
        description: '정답률 90% 달성하기',
        targetValue: 90,
      ),
    ];
  }
}
