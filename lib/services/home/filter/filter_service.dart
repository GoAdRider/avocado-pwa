import '../../../models/vocabulary_word.dart';
import '../../../utils/i18n/simple_i18n.dart';
import '../../common/hive_service.dart';

/// 필터링 관련 비즈니스 로직을 담당하는 서비스 (성능 최적화)
class FilterService {
  static FilterService? _instance;
  static FilterService get instance => _instance ??= FilterService._internal();
  FilterService._internal();

  final HiveService _hiveService = HiveService.instance;
  
  // 성능 최적화: 메모리 캐시
  final Map<String, List<VocabularyWord>> _wordCache = {};
  final Map<String, Map<String, int>> _posCountCache = {};
  final Map<String, Map<String, int>> _typeCountCache = {};
  
  // 캐시 키 생성 헬퍼
  String _makeCacheKey(List<String> files, [List<String>? filters]) {
    final filesKey = files.join('|');
    final filtersKey = filters?.join(',') ?? '';
    return '$filesKey#$filtersKey';
  }
  
  /// 캐시 무효화 (어휘집 변경 시 호출)
  void clearCache() {
    print('🔧 PERF: Clearing FilterService cache');
    _wordCache.clear();
    _posCountCache.clear();
    _typeCountCache.clear();
  }
  
  /// 특정 파일의 캐시만 무효화
  void clearCacheForFile(String fileName) {
    print('🔧 PERF: Clearing cache for file: $fileName');
    _wordCache.remove(fileName);
    
    // 해당 파일을 포함하는 모든 캐시 항목 제거
    _posCountCache.removeWhere((key, value) => key.contains(fileName));
    _typeCountCache.removeWhere((key, value) => key.contains(fileName));
  }

  // 상수 정의 (언어 독립적)
  static const String noPosInfo = '__NO_POS__';
  static const String noTypeInfo = '__NO_TYPE__';

  /// 어휘집별 품사(POS) 목록 가져오기
  List<String> getPositionsForFile(String vocabularyFile) {
    final words =
        _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
    final positions = <String>{};

    for (final word in words) {
      final pos =
          (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : noPosInfo;
      positions.add(pos);
    }

    return positions.toList()..sort();
  }

  /// 어휘집별 타입(Type) 목록 가져오기
  List<String> getTypesForFile(String vocabularyFile) {
    final words =
        _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
    final types = <String>{};

    for (final word in words) {
      final type = (word.type != null && word.type!.isNotEmpty)
          ? word.type!
          : noTypeInfo;
      types.add(type);
    }

    return types.toList()..sort();
  }

  /// 여러 어휘집에서 품사 목록 가져오기
  List<String> getPositionsForFiles(List<String> vocabularyFiles) {
    final positions = <String>{};

    for (final file in vocabularyFiles) {
      positions.addAll(getPositionsForFile(file));
    }

    return positions.toList()..sort();
  }

  /// 여러 어휘집에서 타입 목록 가져오기
  List<String> getTypesForFiles(List<String> vocabularyFiles) {
    final types = <String>{};

    for (final file in vocabularyFiles) {
      types.addAll(getTypesForFile(file));
    }

    return types.toList()..sort();
  }

  /// 어휘집별 품사별 단어 개수 가져오기
  Map<String, int> getPositionCountsForFile(String vocabularyFile) {
    final words =
        _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
    final positionCounts = <String, int>{};

    for (final word in words) {
      final pos = (word.pos != null && word.pos!.isNotEmpty)
          ? word.pos!
          : noPosInfo; // 빈 POS를 상수로 처리
      positionCounts[pos] = (positionCounts[pos] ?? 0) + 1;
    }

    return positionCounts;
  }

  /// 어휘집별 타입별 단어 개수 가져오기
  Map<String, int> getTypeCountsForFile(String vocabularyFile) {
    final words =
        _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
    final typeCounts = <String, int>{};

    for (final word in words) {
      final type = (word.type != null && word.type!.isNotEmpty)
          ? word.type!
          : noTypeInfo; // 빈 Type을 상수로 처리
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    return typeCounts;
  }

  /// 여러 어휘집에서 품사별 단어 개수 가져오기
  Map<String, int> getPositionCountsForFiles(List<String> vocabularyFiles) {
    final positionCounts = <String, int>{};

    for (final file in vocabularyFiles) {
      final fileCounts = getPositionCountsForFile(file);
      for (final entry in fileCounts.entries) {
        positionCounts[entry.key] =
            (positionCounts[entry.key] ?? 0) + entry.value;
      }
    }

    return positionCounts;
  }

  /// 여러 어휘집에서 타입별 단어 개수 가져오기
  Map<String, int> getTypeCountsForFiles(List<String> vocabularyFiles) {
    final typeCounts = <String, int>{};

    for (final file in vocabularyFiles) {
      final fileCounts = getTypeCountsForFile(file);
      for (final entry in fileCounts.entries) {
        typeCounts[entry.key] = (typeCounts[entry.key] ?? 0) + entry.value;
      }
    }

    return typeCounts;
  }

  /// 선택된 타입 필터에 기반하여 품사별 단어 개수 가져오기 (캐싱 최적화)
  Map<String, int> getPositionCountsWithTypeFilter(
    List<String> vocabularyFiles,
    List<String> selectedTypes,
  ) {
    if (vocabularyFiles.isEmpty) return {};
    
    final cacheKey = _makeCacheKey(vocabularyFiles, selectedTypes);
    
    // 캐시에서 확인
    if (_posCountCache.containsKey(cacheKey)) {
      print('🔧 PERF: Position counts cache hit');
      return _posCountCache[cacheKey]!;
    }
    
    print('🔧 PERF: Position counts cache miss - computing...');
    final stopwatch = Stopwatch()..start();

    // 단어들을 캐시에서 가져오거나 로드
    List<VocabularyWord> allWords = [];
    for (final file in vocabularyFiles) {
      if (_wordCache.containsKey(file)) {
        allWords.addAll(_wordCache[file]!);
      } else {
        final words = _hiveService.getVocabularyWords(vocabularyFile: file);
        _wordCache[file] = words;
        allWords.addAll(words);
      }
    }

    // 선택된 타입으로 필터링
    final filteredWords = allWords.where((word) {
      if (selectedTypes.isEmpty) return true;
      final wordType = (word.type != null && word.type!.isNotEmpty)
          ? word.type!
          : noTypeInfo;
      return selectedTypes.contains(wordType);
    }).toList();

    // 품사별 개수 계산
    final positionCounts = <String, int>{};
    for (final word in filteredWords) {
      final pos =
          (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : noPosInfo;
      positionCounts[pos] = (positionCounts[pos] ?? 0) + 1;
    }

    // 결과 캐싱
    _posCountCache[cacheKey] = positionCounts;
    
    stopwatch.stop();
    print('🔧 PERF: Position counts computed in ${stopwatch.elapsedMilliseconds}ms');
    return positionCounts;
  }

  /// 선택된 품사 필터에 기반하여 타입별 단어 개수 가져오기 (캐싱 최적화)
  Map<String, int> getTypeCountsWithPositionFilter(
    List<String> vocabularyFiles,
    List<String> selectedPositions,
  ) {
    if (vocabularyFiles.isEmpty) return {};
    
    final cacheKey = _makeCacheKey(vocabularyFiles, selectedPositions);
    
    // 캐시에서 확인
    if (_typeCountCache.containsKey(cacheKey)) {
      print('🔧 PERF: Type counts cache hit');
      return _typeCountCache[cacheKey]!;
    }
    
    print('🔧 PERF: Type counts cache miss - computing...');
    final stopwatch = Stopwatch()..start();

    // 단어들을 캐시에서 가져오거나 로드
    List<VocabularyWord> allWords = [];
    for (final file in vocabularyFiles) {
      if (_wordCache.containsKey(file)) {
        allWords.addAll(_wordCache[file]!);
      } else {
        final words = _hiveService.getVocabularyWords(vocabularyFile: file);
        _wordCache[file] = words;
        allWords.addAll(words);
      }
    }

    // 선택된 품사로 필터링
    final filteredWords = allWords.where((word) {
      if (selectedPositions.isEmpty) return true;
      final wordPos =
          (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : noPosInfo;
      return selectedPositions.contains(wordPos);
    }).toList();

    // 타입별 개수 계산
    final typeCounts = <String, int>{};
    for (final word in filteredWords) {
      final type = (word.type != null && word.type!.isNotEmpty)
          ? word.type!
          : noTypeInfo;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // 결과 캐싱
    _typeCountCache[cacheKey] = typeCounts;
    
    stopwatch.stop();
    print('🔧 PERF: Type counts computed in ${stopwatch.elapsedMilliseconds}ms');
    return typeCounts;
  }

  /// 모든 가능한 품사 목록 가져오기 (선택된 어휘집들 기준)
  List<String> getAllPositionsForFiles(List<String> vocabularyFiles) {
    final positions = <String>{};
    for (final file in vocabularyFiles) {
      positions.addAll(getPositionsForFile(file));
    }
    return positions.toList()..sort();
  }

  /// 모든 가능한 타입 목록 가져오기 (선택된 어휘집들 기준)
  List<String> getAllTypesForFiles(List<String> vocabularyFiles) {
    final types = <String>{};
    for (final file in vocabularyFiles) {
      types.addAll(getTypesForFile(file));
    }
    return types.toList()..sort();
  }

  /// 필터링된 단어 목록 가져오기
  List<VocabularyWord> getFilteredWords({
    List<String>? vocabularyFiles,
    List<String>? posFilters,
    List<String>? typeFilters,
    bool favoritesOnly = false,
    bool wrongWordsOnly = false,
  }) {
    List<VocabularyWord> allWords = [];

    // 어휘집별로 단어 수집
    if (vocabularyFiles != null && vocabularyFiles.isNotEmpty) {
      for (final file in vocabularyFiles) {
        allWords.addAll(_hiveService.getVocabularyWords(vocabularyFile: file));
      }
    } else {
      // 모든 어휘집에서 가져오기
      allWords = _hiveService.getVocabularyWords();
    }

    // 필터링 적용
    return allWords.where((word) {
      // 품사 필터
      if (posFilters != null && posFilters.isNotEmpty) {
        final wordPos = (word.pos != null && word.pos!.isNotEmpty)
            ? word.pos!
            : noPosInfo;
        // UI에서 전달받은 필터 값을 내부 상수로 변환해서 비교
        final convertedPosFilters = convertUIFiltersToService(posFilters);
        if (!convertedPosFilters.contains(wordPos)) {
          return false;
        }
      }

      // 타입 필터
      if (typeFilters != null && typeFilters.isNotEmpty) {
        final wordType = (word.type != null && word.type!.isNotEmpty)
            ? word.type!
            : noTypeInfo;
        // UI에서 전달받은 필터 값을 내부 상수로 변환해서 비교
        final convertedTypeFilters = convertUIFiltersToService(typeFilters);
        if (!convertedTypeFilters.contains(wordType)) {
          return false;
        }
      }

      // 즐겨찾기 필터
      if (favoritesOnly) {
        if (!_hiveService.isFavorite(word.id)) {
          return false;
        }
      }

      // 틀린 단어 필터
      if (wrongWordsOnly) {
        final stats = _hiveService.getWordStats(word.id);
        if (stats == null || !stats.isWrongWord) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// 필터링된 단어 통계 정보 가져오기
  FilteredWordsInfo getFilteredWordsInfo({
    List<String>? vocabularyFiles,
    List<String>? posFilters,
    List<String>? typeFilters,
    bool favoritesOnly = false,
    bool wrongWordsOnly = false,
  }) {
    final filteredWords = getFilteredWords(
      vocabularyFiles: vocabularyFiles,
      posFilters: posFilters,
      typeFilters: typeFilters,
      favoritesOnly: favoritesOnly,
      wrongWordsOnly: wrongWordsOnly,
    );

    int favoriteCount = 0;
    int wrongWordCount = 0;
    int totalWrongCount = 0;

    for (final word in filteredWords) {
      if (_hiveService.isFavorite(word.id)) {
        favoriteCount++;
      }

      final stats = _hiveService.getWordStats(word.id);
      if (stats != null && stats.isWrongWord) {
        wrongWordCount++;
        totalWrongCount += stats.wrongCount.toInt();
      }
    }

    return FilteredWordsInfo(
      totalWords: filteredWords.length,
      favoriteWords: favoriteCount,
      wrongWords: wrongWordCount,
      wrongCount: totalWrongCount,
    );
  }

  /// UI 필터 값에서 순수 값 추출 (괄호와 개수 제거)
  List<String> _extractPureValues(Set<String>? filterValues) {
    if (filterValues == null) return [];
    return filterValues
        .map((filter) => filter.split('(')[0]) // "명사(123)" -> "명사"
        .toList();
  }

  /// 필터가 적용된 단어 개수 계산 (실제 필터링 적용)
  int getFilteredWordCount({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    final filteredInfo = getFilteredWordsInfo(
      vocabularyFiles: vocabularyFiles,
      posFilters: _extractPureValues(posFilters),
      typeFilters: _extractPureValues(typeFilters),
    );
    return filteredInfo.totalWords;
  }

  /// 필터가 적용된 즐겨찾기 개수 계산
  int getFilteredFavoriteCount({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    final filteredInfo = getFilteredWordsInfo(
      vocabularyFiles: vocabularyFiles,
      posFilters: _extractPureValues(posFilters),
      typeFilters: _extractPureValues(typeFilters),
    );
    return filteredInfo.favoriteWords;
  }

  /// 필터가 적용된 틀린 단어 개수 계산
  int getFilteredWrongWordsCount({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    final filteredInfo = getFilteredWordsInfo(
      vocabularyFiles: vocabularyFiles,
      posFilters: _extractPureValues(posFilters),
      typeFilters: _extractPureValues(typeFilters),
    );
    return filteredInfo.wrongWords;
  }

  /// 필터가 적용된 틀린 횟수 총합 계산
  int getFilteredWrongCountTotal({
    List<String>? vocabularyFiles,
    Set<String>? posFilters,
    Set<String>? typeFilters,
  }) {
    final filteredInfo = getFilteredWordsInfo(
      vocabularyFiles: vocabularyFiles,
      posFilters: _extractPureValues(posFilters),
      typeFilters: _extractPureValues(typeFilters),
    );
    return filteredInfo.wrongCount;
  }

  /// UI에서 표시할 품사 텍스트 정리 (언어별 변환)
  String cleanupPositionForUI(String position) {
    if (position == noPosInfo) {
      return tr('ui.pos_not_available', namespace: 'home/filter');
    }
    return position;
  }

  /// UI에서 표시할 타입 텍스트 정리 (언어별 변환)
  String cleanupTypeForUI(String type) {
    if (type == noTypeInfo) {
      return tr('ui.type_not_available', namespace: 'home/filter');
    }
    return type;
  }

  /// 필터 목록을 UI용으로 정리 (내부 상수를 UI 문자열로 변환)
  List<String> cleanupFiltersForUI(List<String> filters) {
    final posNotAvailable = tr('ui.pos_not_available', namespace: 'home/filter');
    final typeNotAvailable = tr('ui.type_not_available', namespace: 'home/filter');
    
    return filters.map((filter) {
      if (filter == noPosInfo) {
        return posNotAvailable;
      } else if (filter == noTypeInfo) {
        return typeNotAvailable;
      }
      return filter;
    }).toList();
  }

  /// UI 필터를 서비스 상수로 변환 (UI 문자열을 내부 상수로 변환)
  List<String> convertUIFiltersToService(List<String> uiFilters) {
    final posNotAvailable = tr('ui.pos_not_available', namespace: 'home/filter');
    final typeNotAvailable = tr('ui.type_not_available', namespace: 'home/filter');
    
    return uiFilters.map((filter) {
      if (filter == posNotAvailable) {
        return noPosInfo;
      } else if (filter == typeNotAvailable) {
        return noTypeInfo;
      }
      return filter;
    }).toList();
  }
}

/// 필터링된 단어 정보 클래스
class FilteredWordsInfo {
  final int totalWords;
  final int favoriteWords;
  final int wrongWords;
  final int wrongCount;

  FilteredWordsInfo({
    required this.totalWords,
    required this.favoriteWords,
    required this.wrongWords,
    required this.wrongCount,
  });
}
