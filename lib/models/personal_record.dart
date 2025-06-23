import 'package:hive/hive.dart';

part 'personal_record.g.dart';

@HiveType(typeId: 7)
class PersonalRecord extends HiveObject {
  @HiveField(0)
  String gameType; // 'lightning', 'timing', 'puzzle', 'challenge'

  @HiveField(1)
  int highScore;

  @HiveField(2)
  DateTime achievedDate;

  @HiveField(3)
  String? wordId;

  @HiveField(4)
  String? vocabularyFile;

  PersonalRecord({
    required this.gameType,
    required this.highScore,
    DateTime? achievedDate,
    this.wordId,
    this.vocabularyFile,
  }) : achievedDate = achievedDate ?? DateTime.now();

  PersonalRecord copyWith({
    String? gameType,
    int? highScore,
    DateTime? achievedDate,
    String? wordId,
    String? vocabularyFile,
  }) {
    return PersonalRecord(
      gameType: gameType ?? this.gameType,
      highScore: highScore ?? this.highScore,
      achievedDate: achievedDate ?? this.achievedDate,
      wordId: wordId ?? this.wordId,
      vocabularyFile: vocabularyFile ?? this.vocabularyFile,
    );
  }

  /// 신기록인지 확인
  bool isNewRecord(int newScore) {
    return newScore > highScore;
  }

  /// 신기록 업데이트
  void updateRecord(int newScore, {String? wordId, String? vocabularyFile}) {
    if (isNewRecord(newScore)) {
      highScore = newScore;
      achievedDate = DateTime.now();
      if (wordId != null) this.wordId = wordId;
      if (vocabularyFile != null) this.vocabularyFile = vocabularyFile;
    }
  }

  /// 게임 타입별 이름
  String get gameTypeName {
    switch (gameType) {
      case 'lightning':
        return '⚡ Lightning';
      case 'timing':
        return '⏰ Timing';
      case 'puzzle':
        return '🧩 Puzzle';
      case 'challenge':
        return '🎯 Challenge';
      default:
        return gameType;
    }
  }

  /// 게임 타입별 아이콘
  String get icon {
    switch (gameType) {
      case 'lightning':
        return '⚡';
      case 'timing':
        return '⏰';
      case 'puzzle':
        return '🧩';
      case 'challenge':
        return '🎯';
      default:
        return '🎮';
    }
  }

  /// 달성일 포맷 (상대 시간)
  String get relativeAchievedDate {
    final now = DateTime.now();
    final difference = now.difference(achievedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 점수 등급
  String get scoreGrade {
    if (highScore >= 1000) return 'S+';
    if (highScore >= 800) return 'S';
    if (highScore >= 600) return 'A';
    if (highScore >= 400) return 'B';
    if (highScore >= 200) return 'C';
    return 'D';
  }

  /// 등급별 색상
  String get gradeColor {
    switch (scoreGrade) {
      case 'S+':
        return '#FF6B6B'; // 빨간색
      case 'S':
        return '#4ECDC4'; // 청록색
      case 'A':
        return '#45B7D1'; // 파란색
      case 'B':
        return '#96CEB4'; // 초록색
      case 'C':
        return '#FECA57'; // 노란색
      case 'D':
        return '#A0A0A0'; // 회색
      default:
        return '#A0A0A0';
    }
  }

  @override
  String toString() {
    return 'PersonalRecord(gameType: $gameType, highScore: $highScore, achievedDate: $achievedDate, wordId: $wordId, vocabularyFile: $vocabularyFile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalRecord && other.gameType == gameType;
  }

  @override
  int get hashCode => gameType.hashCode;

  /// 게임 타입별 기본 기록 생성
  static List<PersonalRecord> createDefaultRecords() {
    return [
      PersonalRecord(gameType: 'lightning', highScore: 0),
      PersonalRecord(gameType: 'timing', highScore: 0),
      PersonalRecord(gameType: 'puzzle', highScore: 0),
      PersonalRecord(gameType: 'challenge', highScore: 0),
    ];
  }
}
