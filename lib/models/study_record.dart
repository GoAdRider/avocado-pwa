import 'package:hive/hive.dart';

part 'study_record.g.dart';

@HiveType(typeId: 4)
class StudyRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String wordId;

  @HiveField(2)
  String vocabularyFile;

  @HiveField(3)
  DateTime studyDate;

  @HiveField(4)
  String studyMode; // 'card' or 'game'

  @HiveField(5)
  String? gameType; // 'lightning', 'timing', 'puzzle', 'challenge'

  @HiveField(6)
  bool isCorrect;

  @HiveField(7)
  int? score;

  @HiveField(8)
  String? hintType; // 'beginner', 'intermediate', 'advanced', null

  @HiveField(9)
  int hintsUsed; // 0-5

  @HiveField(10)
  DateTime? sessionStart;

  @HiveField(11)
  DateTime? sessionEnd;

  @HiveField(12)
  List<String>? posFilters; // 품사 필터

  @HiveField(13)
  List<String>? typeFilters; // 어휘 타입 필터

  @HiveField(14)
  String? targetMode; // 위주 학습 설정 ('TargetVoca', 'ReferenceVoca', 'Random')

  StudyRecord({
    required this.id,
    required this.wordId,
    required this.vocabularyFile,
    DateTime? studyDate,
    required this.studyMode,
    this.gameType,
    required this.isCorrect,
    this.score,
    this.hintType,
    this.hintsUsed = 0,
    this.sessionStart,
    this.sessionEnd,
    this.posFilters,
    this.typeFilters,
    this.targetMode,
  }) : studyDate = studyDate ?? DateTime.now();

  StudyRecord copyWith({
    String? id,
    String? wordId,
    String? vocabularyFile,
    DateTime? studyDate,
    String? studyMode,
    String? gameType,
    bool? isCorrect,
    int? score,
    String? hintType,
    int? hintsUsed,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    List<String>? posFilters,
    List<String>? typeFilters,
    String? targetMode,
  }) {
    return StudyRecord(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      vocabularyFile: vocabularyFile ?? this.vocabularyFile,
      studyDate: studyDate ?? this.studyDate,
      studyMode: studyMode ?? this.studyMode,
      gameType: gameType ?? this.gameType,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      hintType: hintType ?? this.hintType,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: sessionEnd ?? this.sessionEnd,
      posFilters: posFilters ?? this.posFilters,
      typeFilters: typeFilters ?? this.typeFilters,
      targetMode: targetMode ?? this.targetMode,
    );
  }

  /// 세션 시간 계산 (분 단위)
  int? get sessionTimeMinutes {
    if (sessionStart == null || sessionEnd == null) return null;
    return sessionEnd!.difference(sessionStart!).inMinutes;
  }

  /// 게임 기록인지 확인
  bool get isGameRecord => studyMode == 'game' && gameType != null;

  /// 카드 학습 기록인지 확인
  bool get isCardRecord => studyMode == 'card';

  /// 힌트를 사용했는지 확인
  bool get usedHints => hintsUsed > 0;

  @override
  String toString() {
    return 'StudyRecord(id: $id, wordId: $wordId, vocabularyFile: $vocabularyFile, studyDate: $studyDate, studyMode: $studyMode, gameType: $gameType, isCorrect: $isCorrect, score: $score, hintType: $hintType, hintsUsed: $hintsUsed, posFilters: $posFilters, typeFilters: $typeFilters, targetMode: $targetMode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
