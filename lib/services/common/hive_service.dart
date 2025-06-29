import 'package:hive_flutter/hive_flutter.dart';
import '../../models/vocabulary_word.dart';
import '../../models/quote.dart';
import '../../models/favorite.dart';
import '../../models/word_stats.dart';
import '../../models/study_record.dart';
import '../../models/daily_stats.dart';
import '../../models/achievement.dart';
import '../../models/personal_record.dart';
import '../dialogs/daily_goals_service.dart';

class HiveService {
  static const String _vocabularyWordsBox = 'vocabulary_words';
  static const String _quotesBox = 'quotes';
  static const String _favoritesBox = 'favorites';
  static const String _wordStatsBox = 'word_stats';
  static const String _studyRecordsBox = 'study_records';
  static const String _dailyStatsBox = 'daily_stats';
  static const String _achievementsBox = 'achievements';
  static const String _personalRecordsBox = 'personal_records';
  static const String _temporaryDeleteBox = 'temporary_delete';

  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._internal();
  HiveService._internal();

  /// Hive 초기화
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // 어댑터 등록
    Hive.registerAdapter(VocabularyWordAdapter());
    Hive.registerAdapter(QuoteAdapter());
    Hive.registerAdapter(FavoriteAdapter());
    Hive.registerAdapter(WordStatsAdapter());
    Hive.registerAdapter(StudyRecordAdapter());
    Hive.registerAdapter(DailyStatsAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(PersonalRecordAdapter());

    // 박스 열기
    await _openBoxes();

    // 기본 데이터 초기화
    await _initializeDefaultData();
    
    // DailyGoalsService 초기화
    await DailyGoalsService.instance.initialize();
  }

  /// 모든 박스 열기
  static Future<void> _openBoxes() async {
    await Hive.openBox<VocabularyWord>(_vocabularyWordsBox);
    await Hive.openBox<Quote>(_quotesBox);
    await Hive.openBox<Favorite>(_favoritesBox);
    await Hive.openBox<WordStats>(_wordStatsBox);
    await Hive.openBox<StudyRecord>(_studyRecordsBox);
    await Hive.openBox<DailyStats>(_dailyStatsBox);
    await Hive.openBox<Achievement>(_achievementsBox);
    await Hive.openBox<PersonalRecord>(_personalRecordsBox);
    await Hive.openBox(_temporaryDeleteBox); // String key-value 저장용
  }

  /// 기본 데이터 초기화
  static Future<void> _initializeDefaultData() async {
    // 기본 업적 생성 (없을 때만)
    final achievementBox = Hive.box<Achievement>(_achievementsBox);
    if (achievementBox.isEmpty) {
      final defaultAchievements = Achievement.createDefaultAchievements();
      for (final achievement in defaultAchievements) {
        await achievementBox.put(achievement.id, achievement);
      }
    }

    // 기본 개인 기록 생성 (없을 때만)
    final personalRecordBox = Hive.box<PersonalRecord>(_personalRecordsBox);
    if (personalRecordBox.isEmpty) {
      final defaultRecords = PersonalRecord.createDefaultRecords();
      for (final record in defaultRecords) {
        await personalRecordBox.put(record.gameType, record);
      }
    }
  }

  /// 박스 가져오기
  Box<VocabularyWord> get vocabularyWordsBox =>
      Hive.box<VocabularyWord>(_vocabularyWordsBox);
  Box<Quote> get quotesBox => Hive.box<Quote>(_quotesBox);
  Box<Favorite> get favoritesBox => Hive.box<Favorite>(_favoritesBox);
  Box<WordStats> get wordStatsBox => Hive.box<WordStats>(_wordStatsBox);
  Box<StudyRecord> get studyRecordsBox =>
      Hive.box<StudyRecord>(_studyRecordsBox);
  Box<DailyStats> get dailyStatsBox => Hive.box<DailyStats>(_dailyStatsBox);
  Box<Achievement> get achievementsBox =>
      Hive.box<Achievement>(_achievementsBox);
  Box<PersonalRecord> get personalRecordsBox =>
      Hive.box<PersonalRecord>(_personalRecordsBox);
  Box get temporaryDeleteBox => Hive.box(_temporaryDeleteBox);

  // =========================
  // VocabularyWord 관련 메서드
  // =========================

  /// 어휘 추가
  Future<void> addVocabularyWord(VocabularyWord word) async {
    await vocabularyWordsBox.put(word.id, word);
  }

  /// 어휘 목록 가져오기
  List<VocabularyWord> getVocabularyWords({String? vocabularyFile}) {
    if (vocabularyFile != null) {
      return vocabularyWordsBox.values
          .where((word) => word.vocabularyFile == vocabularyFile)
          .toList();
    }
    return vocabularyWordsBox.values.toList();
  }

  /// 어휘 삭제
  Future<void> deleteVocabularyWord(String id) async {
    await vocabularyWordsBox.delete(id);
  }

  /// 어휘집별 단어 삭제
  Future<void> deleteVocabularyWords(String vocabularyFile) async {
    final wordsToDelete = vocabularyWordsBox.values
        .where((word) => word.vocabularyFile == vocabularyFile)
        .map((word) => word.id)
        .toList();

    for (final id in wordsToDelete) {
      await vocabularyWordsBox.delete(id);
    }
  }

  /// 어휘집 목록 가져오기
  List<String> getVocabularyFiles() {
    final vocabularyFiles = <String>{};
    for (final word in vocabularyWordsBox.values) {
      vocabularyFiles.add(word.vocabularyFile);
    }
    return vocabularyFiles.toList()..sort();
  }

  /// 어휘집 존재 여부 확인
  bool vocabularyFileExists(String vocabularyFile) {
    return vocabularyWordsBox.values
        .any((word) => word.vocabularyFile == vocabularyFile);
  }

  // =========================
  // Quote 관련 메서드
  // =========================

  /// 명언 추가
  Future<void> addQuote(Quote quote) async {
    await quotesBox.put(quote.id, quote);
  }

  /// 랜덤 명언 가져오기
  Quote? getRandomQuote() {
    final quotes = quotesBox.values.toList();
    if (quotes.isEmpty) return null;
    quotes.shuffle();
    return quotes.first;
  }

  /// 모든 명언 가져오기
  List<Quote> getAllQuotes() {
    return quotesBox.values.toList();
  }

  // =========================
  // Favorite 관련 메서드
  // =========================

  /// 즐겨찾기 추가
  Future<void> addFavorite(String wordId, String vocabularyFile) async {
    final favorite = Favorite(
      wordId: wordId,
      vocabularyFile: vocabularyFile,
    );
    await favoritesBox.put(wordId, favorite);
  }

  /// 즐겨찾기 제거
  Future<void> removeFavorite(String wordId) async {
    await favoritesBox.delete(wordId);
  }

  /// 즐겨찾기 여부 확인
  bool isFavorite(String wordId) {
    return favoritesBox.containsKey(wordId);
  }

  /// 즐겨찾기 목록 가져오기
  List<Favorite> getFavorites({String? vocabularyFile}) {
    if (vocabularyFile != null) {
      return favoritesBox.values
          .where((favorite) => favorite.vocabularyFile == vocabularyFile)
          .toList();
    }
    return favoritesBox.values.toList();
  }

  // =========================
  // WordStats 관련 메서드
  // =========================

  /// 단어 통계 가져오기
  WordStats? getWordStats(String wordId) {
    return wordStatsBox.get(wordId);
  }

  /// 단어 통계 업데이트
  Future<void> updateWordStats(
      String wordId, String vocabularyFile, bool isCorrect) async {
    WordStats stats = wordStatsBox.get(wordId) ??
        WordStats(
          wordId: wordId,
          vocabularyFile: vocabularyFile,
        );

    if (isCorrect) {
      stats.markAsCorrect();
    } else {
      stats.markAsWrong();
    }

    await wordStatsBox.put(wordId, stats);
  }

  /// 틀린 단어 목록 가져오기
  List<WordStats> getWrongWords({String? vocabularyFile}) {
    if (vocabularyFile != null) {
      return wordStatsBox.values
          .where((stats) =>
              stats.isWrongWord && stats.vocabularyFile == vocabularyFile)
          .toList();
    }
    return wordStatsBox.values.where((stats) => stats.isWrongWord).toList();
  }

  // =========================
  // StudyRecord 관련 메서드
  // =========================

  /// 학습 기록 추가
  Future<void> addStudyRecord(StudyRecord record) async {
    await studyRecordsBox.put(record.id, record);

    // WordStats 업데이트
    await updateWordStats(
        record.wordId, record.vocabularyFile, record.isCorrect);

    // DailyStats 업데이트
    await _updateDailyStats(record);
  }

  /// 학습 기록 가져오기
  List<StudyRecord> getStudyRecords({
    String? vocabularyFile,
    String? studyMode,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return studyRecordsBox.values.where((record) {
      if (vocabularyFile != null && record.vocabularyFile != vocabularyFile) {
        return false;
      }
      if (studyMode != null && record.studyMode != studyMode) {
        return false;
      }
      if (startDate != null && record.studyDate.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && record.studyDate.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// 특정 어휘집과 관련된 모든 학습 기록 삭제
  Future<void> deleteStudyRecordsByVocabularyFile(String vocabularyFile) async {
    final recordsToDelete = studyRecordsBox.values
        .where((record) => record.vocabularyFile == vocabularyFile)
        .toList();
    
    for (final record in recordsToDelete) {
      await studyRecordsBox.delete(record.id);
      print('🗑️ StudyRecord 삭제: ${record.id} (어휘집: $vocabularyFile)');
    }
    
    print('🗑️ 어휘집 $vocabularyFile 관련 StudyRecord ${recordsToDelete.length}개 삭제 완료');
  }

  // =========================
  // DailyStats 관련 메서드
  // =========================

  /// 일별 통계 업데이트
  Future<void> _updateDailyStats(StudyRecord record) async {
    final dateString =
        '${record.studyDate.year}-${record.studyDate.month.toString().padLeft(2, '0')}-${record.studyDate.day.toString().padLeft(2, '0')}';

    DailyStats stats =
        dailyStatsBox.get(dateString) ?? DailyStats(date: dateString);

    stats.studiedWords++;
    if (record.isCorrect) {
      stats.correctAnswers++;
    } else {
      stats.wrongAnswers++;
    }

    // 세션 시간이 있으면 추가
    if (record.sessionTimeMinutes != null) {
      stats.studyTimeMinutes += record.sessionTimeMinutes!;
    }

    await dailyStatsBox.put(dateString, stats);
  }

  /// 오늘 통계 가져오기
  DailyStats getTodayStats() {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return dailyStatsBox.get(dateString) ?? DailyStats(date: dateString);
  }

  /// 연속 학습일 계산
  Future<int> calculateStreakDays() async {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      // 최대 1년까지 확인
      final date = today.subtract(Duration(days: i));
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final stats = dailyStatsBox.get(dateString);
      if (stats != null && stats.studiedWords > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // =========================
  // Achievement 관련 메서드
  // =========================

  /// 업적 진행도 업데이트
  Future<void> updateAchievementProgress(
      String achievementType, int currentValue) async {
    final achievement = achievementsBox.get(achievementType);
    if (achievement != null) {
      achievement.updateProgress(currentValue);
      await achievementsBox.put(achievementType, achievement);
    }
  }

  /// 완료된 업적 가져오기
  List<Achievement> getCompletedAchievements() {
    return achievementsBox.values
        .where((achievement) => achievement.isCompleted)
        .toList();
  }

  /// 진행 중인 업적 가져오기
  List<Achievement> getInProgressAchievements() {
    return achievementsBox.values
        .where((achievement) => !achievement.isCompleted)
        .toList();
  }

  // =========================
  // PersonalRecord 관련 메서드
  // =========================

  /// 개인 기록 업데이트
  Future<bool> updatePersonalRecord(String gameType, int score,
      {String? wordId, String? vocabularyFile}) async {
    PersonalRecord? record = personalRecordsBox.get(gameType);

    if (record == null) {
      record = PersonalRecord(
          gameType: gameType,
          highScore: score,
          wordId: wordId,
          vocabularyFile: vocabularyFile);
      await personalRecordsBox.put(gameType, record);
      return true; // 첫 기록은 신기록
    }

    if (record.isNewRecord(score)) {
      record.updateRecord(score,
          wordId: wordId, vocabularyFile: vocabularyFile);
      await personalRecordsBox.put(gameType, record);
      return true; // 신기록
    }

    return false; // 신기록 아님
  }

  /// 개인 기록 가져오기
  PersonalRecord? getPersonalRecord(String gameType) {
    return personalRecordsBox.get(gameType);
  }

  /// 모든 개인 기록 가져오기
  List<PersonalRecord> getAllPersonalRecords() {
    return personalRecordsBox.values.toList();
  }

  // =========================
  // 유틸리티 메서드
  // =========================

  /// 모든 데이터 초기화 (위험!)
  Future<void> clearAllData() async {
    await vocabularyWordsBox.clear();
    await quotesBox.clear();
    await favoritesBox.clear();
    await wordStatsBox.clear();
    await studyRecordsBox.clear();
    await dailyStatsBox.clear();
    await achievementsBox.clear();
    await personalRecordsBox.clear();

    // 기본 데이터 재생성
    await _initializeDefaultData();
  }

  /// 특정 어휘집 관련 데이터만 삭제
  Future<void> clearVocabularyData(String vocabularyFile) async {
    // 단어 삭제
    await deleteVocabularyWords(vocabularyFile);

    // 즐겨찾기 삭제
    final favoritesToDelete = favoritesBox.values
        .where((favorite) => favorite.vocabularyFile == vocabularyFile)
        .map((favorite) => favorite.wordId)
        .toList();
    for (final wordId in favoritesToDelete) {
      await favoritesBox.delete(wordId);
    }

    // 단어 통계 삭제
    final statsToDelete = wordStatsBox.values
        .where((stats) => stats.vocabularyFile == vocabularyFile)
        .map((stats) => stats.wordId)
        .toList();
    for (final wordId in statsToDelete) {
      await wordStatsBox.delete(wordId);
    }

    // 학습 기록 삭제
    final recordsToDelete = studyRecordsBox.values
        .where((record) => record.vocabularyFile == vocabularyFile)
        .map((record) => record.id)
        .toList();
    for (final id in recordsToDelete) {
      await studyRecordsBox.delete(id);
    }
  }

  /// 특정 어휘집의 WordStats만 삭제
  Future<void> clearWordStats({String? vocabularyFile}) async {
    if (vocabularyFile != null) {
      final statsToDelete = wordStatsBox.values
          .where((stats) => stats.vocabularyFile == vocabularyFile)
          .map((stats) => stats.wordId)
          .toList();
      for (final wordId in statsToDelete) {
        await wordStatsBox.delete(wordId);
      }
    } else {
      await wordStatsBox.clear();
    }
  }

  /// 특정 어휘집의 Favorites만 삭제
  Future<void> clearFavorites({String? vocabularyFile}) async {
    if (vocabularyFile != null) {
      final favoritesToDelete = favoritesBox.values
          .where((favorite) => favorite.vocabularyFile == vocabularyFile)
          .map((favorite) => favorite.wordId)
          .toList();
      for (final wordId in favoritesToDelete) {
        await favoritesBox.delete(wordId);
      }
    } else {
      await favoritesBox.clear();
    }
  }

  /// 특정 어휘집의 틀린횟수 초기화 (별칭 메서드)
  Future<void> resetWrongCounts(String vocabularyFile) async {
    await clearWordStats(vocabularyFile: vocabularyFile);
  }

  /// 특정 어휘집의 즐겨찾기 초기화 (별칭 메서드)
  Future<void> resetFavorites(String vocabularyFile) async {
    await clearFavorites(vocabularyFile: vocabularyFile);
  }

  /// 데이터베이스 통계
  Map<String, int> getDatabaseStats() {
    return {
      'vocabularyWords': vocabularyWordsBox.length,
      'quotes': quotesBox.length,
      'favorites': favoritesBox.length,
      'wordStats': wordStatsBox.length,
      'studyRecords': studyRecordsBox.length,
      'dailyStats': dailyStatsBox.length,
      'achievements': achievementsBox.length,
      'personalRecords': personalRecordsBox.length,
    };
  }
}
