import 'hive_service.dart';
import '../home/filter/filter_service.dart';

/// 어휘집 관련 비즈니스 로직을 담당하는 서비스
class VocabularyService {
  static VocabularyService? _instance;
  static VocabularyService get instance =>
      _instance ??= VocabularyService._internal();
  VocabularyService._internal();

  final HiveService _hiveService = HiveService.instance;
  final FilterService _filterService = FilterService.instance;

  /// 모든 어휘집 목록 가져오기
  List<String> getVocabularyFiles() {
    return _hiveService.getVocabularyFiles();
  }

  /// 특정 어휘집의 상세 정보 가져오기
  VocabularyFileInfo getVocabularyFileInfo(String vocabularyFile) {
    // 어휘집의 모든 단어들
    final words =
        _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);

    // 즐겨찾기 단어들
    final favorites = _hiveService.getFavorites(vocabularyFile: vocabularyFile);

    // 틀린 단어들과 틀린 횟수는 게임 모드 미제공으로 0으로 설정
    // final wrongWords = _hiveService.getWrongWords(vocabularyFile: vocabularyFile);
    // int totalWrongCount = 0;
    // for (final stats in wrongWords) {
    //   totalWrongCount += stats.wrongCount;
    // }

    return VocabularyFileInfo(
      fileName: vocabularyFile,
      totalWords: words.length,
      favoriteWords: favorites.length,
      wrongWords: 0, // 게임 모드 미제공으로 0 설정
      wrongCount: 0, // 게임 모드 미제공으로 0 설정
      importedDate:
          words.isNotEmpty ? words.first.importedDate : DateTime.now(),
    );
  }

  /// 모든 어휘집 정보 목록 가져오기
  List<VocabularyFileInfo> getAllVocabularyFileInfos() {
    final files = getVocabularyFiles();
    return files.map((file) => getVocabularyFileInfo(file)).toList();
  }

  /// 어휘집 삭제
  Future<void> deleteVocabularyFile(String vocabularyFile) async {
    await _hiveService.clearVocabularyData(vocabularyFile);
  }

  /// 특정 단어 삭제
  Future<bool> deleteVocabularyWord(String vocabularyFile, String wordId) async {
    try {
      await _hiveService.deleteVocabularyWord(wordId);
      return true;
    } catch (e) {
      print('❌ VocabularyService: 단어 삭제 오류: $e');
      return false;
    }
  }

  /// 선택된 어휘집들의 통계 정보 계산
  /// HomeScreen에서 사용하던 계산 로직을 서비스로 이동

  /// 선택된 어휘집들의 즐겨찾기 총 개수
  int getSelectedFavoriteCount(
      List<VocabularyFileInfo> vocabularyFiles, Set<String> selectedFiles) {
    if (selectedFiles.isEmpty) return 0;
    return vocabularyFiles
        .where((v) => selectedFiles.contains(v.fileName))
        .fold(0, (sum, v) => sum + v.favoriteWords);
  }

  /// 선택된 어휘집들의 틀린 단어 총 개수
  int getSelectedWrongCount(
      List<VocabularyFileInfo> vocabularyFiles, Set<String> selectedFiles) {
    if (selectedFiles.isEmpty) return 0;
    return vocabularyFiles
        .where((v) => selectedFiles.contains(v.fileName))
        .fold(0, (sum, v) => sum + v.wrongWords);
  }

  /// 선택된 어휘집들의 틀린 횟수 총합
  int getSelectedWrongCountTotal(
      List<VocabularyFileInfo> vocabularyFiles, Set<String> selectedFiles) {
    if (selectedFiles.isEmpty) return 0;
    return vocabularyFiles
        .where((v) => selectedFiles.contains(v.fileName))
        .fold(0, (sum, v) => sum + v.wrongCount);
  }

  /// 선택된 어휘집들의 총 단어 개수
  int getSelectedWordCount(
      List<VocabularyFileInfo> vocabularyFiles, Set<String> selectedFiles) {
    if (selectedFiles.isEmpty) return 0;
    return vocabularyFiles
        .where((v) => selectedFiles.contains(v.fileName))
        .fold(0, (sum, v) => sum + v.totalWords);
  }

  /// 필터가 적용된 단어 개수 계산 (실제 필터링 적용)
  int getFilteredWordCount({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    return _filterService.getFilteredWordCount(
      vocabularyFiles: vocabularyFiles,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
  }

  /// 필터가 적용된 즐겨찾기 개수 계산
  int getFilteredFavoriteCount({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    return _filterService.getFilteredFavoriteCount(
      vocabularyFiles: vocabularyFiles,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
  }

  /// 필터가 적용된 틀린 단어 개수 계산
  int getFilteredWrongWordsCount({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    return _filterService.getFilteredWrongWordsCount(
      vocabularyFiles: vocabularyFiles,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
  }

  /// 필터가 적용된 틀린 횟수 총합 계산
  int getFilteredWrongCountTotal({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    return _filterService.getFilteredWrongCountTotal(
      vocabularyFiles: vocabularyFiles,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
  }
}

/// 어휘집 파일 정보 클래스
class VocabularyFileInfo {
  final String fileName;
  final int totalWords;
  final int favoriteWords;
  final int wrongWords;
  final int wrongCount;
  final DateTime importedDate;

  VocabularyFileInfo({
    required this.fileName,
    required this.totalWords,
    required this.favoriteWords,
    required this.wrongWords,
    required this.wrongCount,
    required this.importedDate,
  });

  /// 표시용 파일명 (확장자 제거)
  String get displayName => fileName.replaceAll('.csv', '');

  /// 가져온 날짜 문자열
  String get importedDateString {
    return '${importedDate.year}.${importedDate.month.toString().padLeft(2, '0')}.${importedDate.day.toString().padLeft(2, '0')}';
  }
}
