class VocabularyWord {
  final String id;
  final String vocabularyFile;
  final String? pos;
  final String? type;
  final String targetVoca;
  final String? targetPronunciation;
  final String referenceVoca;
  final String? targetDesc;
  final String? referenceDesc;
  final String? targetEx;
  final String? referenceEx;
  final bool isFavorite;
  final int wrongCount;
  final DateTime? lastStudyDate;

  VocabularyWord({
    required this.id,
    required this.vocabularyFile,
    this.pos,
    this.type,
    required this.targetVoca,
    this.targetPronunciation,
    required this.referenceVoca,
    this.targetDesc,
    this.referenceDesc,
    this.targetEx,
    this.referenceEx,
    this.isFavorite = false,
    this.wrongCount = 0,
    this.lastStudyDate,
  });

  VocabularyWord copyWith({
    String? id,
    String? vocabularyFile,
    String? pos,
    String? type,
    String? targetVoca,
    String? targetPronunciation,
    String? referenceVoca,
    String? targetDesc,
    String? referenceDesc,
    String? targetEx,
    String? referenceEx,
    bool? isFavorite,
    int? wrongCount,
    DateTime? lastStudyDate,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      vocabularyFile: vocabularyFile ?? this.vocabularyFile,
      pos: pos ?? this.pos,
      type: type ?? this.type,
      targetVoca: targetVoca ?? this.targetVoca,
      targetPronunciation: targetPronunciation ?? this.targetPronunciation,
      referenceVoca: referenceVoca ?? this.referenceVoca,
      targetDesc: targetDesc ?? this.targetDesc,
      referenceDesc: referenceDesc ?? this.referenceDesc,
      targetEx: targetEx ?? this.targetEx,
      referenceEx: referenceEx ?? this.referenceEx,
      isFavorite: isFavorite ?? this.isFavorite,
      wrongCount: wrongCount ?? this.wrongCount,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}

// 학습 모드 열거형
enum StudyMode {
  cardStudy,
  favoriteReview,
  wrongWordsStudy,
  urgentReview,
  recommendedReview,
  leisureReview,
  forgettingRisk,
}

// 카드 면 열거형 (앞면/뒷면)
enum CardSide {
  front, // TargetVoca 면
  back, // ReferenceVoca 면
}

// 학습 세션 데이터
class StudySession {
  final StudyMode mode;
  final List<VocabularyWord> words;
  final List<String> vocabularyFiles;
  final int currentIndex;
  final CardSide currentSide;
  final bool showDetails;

  StudySession({
    required this.mode,
    required this.words,
    required this.vocabularyFiles,
    this.currentIndex = 0,
    this.currentSide = CardSide.front,
    this.showDetails = false,
  });

  StudySession copyWith({
    StudyMode? mode,
    List<VocabularyWord>? words,
    List<String>? vocabularyFiles,
    int? currentIndex,
    CardSide? currentSide,
    bool? showDetails,
  }) {
    return StudySession(
      mode: mode ?? this.mode,
      words: words ?? this.words,
      vocabularyFiles: vocabularyFiles ?? this.vocabularyFiles,
      currentIndex: currentIndex ?? this.currentIndex,
      currentSide: currentSide ?? this.currentSide,
      showDetails: showDetails ?? this.showDetails,
    );
  }

  VocabularyWord? get currentWord {
    if (currentIndex >= 0 && currentIndex < words.length) {
      return words[currentIndex];
    }
    return null;
  }

  double get progress {
    if (words.isEmpty) return 0.0;
    return (currentIndex + 1) / words.length;
  }

  int get progressPercent {
    return (progress * 100).round();
  }

  bool get isCompleted {
    return currentIndex >= words.length;
  }

  bool get canGoNext {
    return currentIndex < words.length - 1;
  }

  bool get canGoPrevious {
    return currentIndex > 0;
  }
}
