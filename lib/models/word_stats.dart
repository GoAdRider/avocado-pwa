import 'package:hive/hive.dart';

part 'word_stats.g.dart';

@HiveType(typeId: 3)
class WordStats extends HiveObject {
  @HiveField(0)
  String wordId;

  @HiveField(1)
  String vocabularyFile;

  @HiveField(2)
  int wrongCount;

  @HiveField(3)
  bool isWrongWord;

  @HiveField(4)
  int correctCount;

  @HiveField(5)
  DateTime? lastStudyDate;

  WordStats({
    required this.wordId,
    required this.vocabularyFile,
    this.wrongCount = 0,
    this.isWrongWord = false,
    this.correctCount = 0,
    this.lastStudyDate,
  });

  WordStats copyWith({
    String? wordId,
    String? vocabularyFile,
    int? wrongCount,
    bool? isWrongWord,
    int? correctCount,
    DateTime? lastStudyDate,
  }) {
    return WordStats(
      wordId: wordId ?? this.wordId,
      vocabularyFile: vocabularyFile ?? this.vocabularyFile,
      wrongCount: wrongCount ?? this.wrongCount,
      isWrongWord: isWrongWord ?? this.isWrongWord,
      correctCount: correctCount ?? this.correctCount,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  /// 정답률 계산 (0-100%)
  double get accuracyRate {
    final total = correctCount + wrongCount;
    if (total == 0) return 0.0;
    return (correctCount / total) * 100;
  }

  /// 틀린 단어로 업데이트
  void markAsWrong() {
    wrongCount++;
    isWrongWord = true;
    lastStudyDate = DateTime.now();
  }

  /// 정답으로 업데이트
  void markAsCorrect() {
    correctCount++;
    lastStudyDate = DateTime.now();
  }

  @override
  String toString() {
    return 'WordStats(wordId: $wordId, vocabularyFile: $vocabularyFile, wrongCount: $wrongCount, isWrongWord: $isWrongWord, correctCount: $correctCount, lastStudyDate: $lastStudyDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordStats && other.wordId == wordId;
  }

  @override
  int get hashCode => wordId.hashCode;
}
