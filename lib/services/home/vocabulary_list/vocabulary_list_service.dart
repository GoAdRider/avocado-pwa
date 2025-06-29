import 'dart:async';
import '../../common/vocabulary_service.dart';
import '../../common/hive_service.dart';
import '../filter/filter_service.dart';
import '../../../utils/i18n/simple_i18n.dart';

/// 어휘집 목록 섹션의 UI 로직을 담당하는 서비스
/// 선택 관리, 액션 처리, 상태 관리 등을 포함
class VocabularyListService {
  static VocabularyListService? _instance;
  static VocabularyListService get instance =>
      _instance ??= VocabularyListService._internal();
  VocabularyListService._internal();

  final VocabularyService _vocabularyService = VocabularyService.instance;
  final HiveService _hiveService = HiveService.instance;
  final FilterService _filterService = FilterService.instance;

  // 선택 상태 관리
  Set<String> _selectedVocabularyFiles = <String>{};
  bool _isMultiSelectMode = false;
  List<VocabularyFileInfo> _vocabularyFiles = [];

  // 상태 변경 알림을 위한 StreamController
  final StreamController<VocabularyListState> _stateController =
      StreamController<VocabularyListState>.broadcast();
  

  // ===== Getters =====

  /// 현재 선택된 어휘집들
  Set<String> get selectedVocabularyFiles => Set.from(_selectedVocabularyFiles);

  /// 다중선택 모드 여부
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// 어휘집 목록
  List<VocabularyFileInfo> get vocabularyFiles => List.from(_vocabularyFiles);

  /// 상태 변경 스트림
  Stream<VocabularyListState> get stateStream => _stateController.stream;

  /// 현재 상태 직접 조회 (Stream이 동작하지 않을 때 사용)
  VocabularyListState get currentState {
    return VocabularyListState(
      vocabularyFiles: _vocabularyFiles,
      selectedFiles: _selectedVocabularyFiles,
      isMultiSelectMode: _isMultiSelectMode,
      selectedStats: getSelectedStats(),
    );
  }

  // ===== 데이터 로딩 =====

  /// 어휘집 목록 새로고침
  Future<void> refreshVocabularyList() async {
    try {
      print('🔍 VocabularyListService refreshVocabularyList 시작');
      
      // FilterService 캐시 초기화 (중요!)
      _filterService.clearCache();
      
      _vocabularyFiles = _vocabularyService.getAllVocabularyFileInfos();
      print('🔍 어휘집 로드 완료: ${_vocabularyFiles.length}개');

      // 삭제된 어휘집이 선택되어 있다면 제거
      _selectedVocabularyFiles.removeWhere((fileName) =>
          !_vocabularyFiles.any((info) => info.fileName == fileName));

      _emitState();
      print('🔍 상태 방출 완료 - StreamController에 상태 추가됨');
      
      // 스트림에 리스너가 있는지 확인
      print('🔍 StreamController hasListener: ${_stateController.hasListener}');
    } catch (e) {
      print('❌ VocabularyListService 에러: $e');
      _emitState(error: e.toString());
    }
  }

  // ===== 선택 관리 =====

  /// 선택 모드 토글
  void toggleSelectionMode() {
    _isMultiSelectMode = !_isMultiSelectMode;
    if (!_isMultiSelectMode) {
      // 단일선택 모드로 변경 시 첫 번째만 남기고 나머지 해제
      if (_selectedVocabularyFiles.length > 1) {
        final first = _selectedVocabularyFiles.first;
        _selectedVocabularyFiles.clear();
        _selectedVocabularyFiles.add(first);
      }
    }
    _emitState();
  }

  /// 어휘집 선택/해제 (최적화: 즉시 UI 업데이트, 지연 통계 계산)
  void toggleVocabularySelection(String fileName) {
    final stopwatch = Stopwatch()..start();
    print('🔧 PERF: toggleVocabularySelection started for $fileName');
    
    if (_selectedVocabularyFiles.contains(fileName)) {
      _selectedVocabularyFiles.remove(fileName);
    } else {
      if (!_isMultiSelectMode) {
        _selectedVocabularyFiles.clear();
      }
      _selectedVocabularyFiles.add(fileName);
    }
    
    // 모든 캐시 무효화
    _cachedStats = null;
    _cachedSelection = null;
    _cachedState = null;
    
    // 즉시 상태 방출 (빠른 UI 업데이트)
    _emitStateImmediate();
    
    stopwatch.stop();
    print('🔧 PERF: toggleVocabularySelection completed - ${stopwatch.elapsedMilliseconds}ms');
  }

  /// 전체 선택
  void selectAll() {
    _isMultiSelectMode = true;
    _selectedVocabularyFiles =
        _vocabularyFiles.map((info) => info.fileName).toSet();
    
    // 모든 캐시 무효화
    _cachedStats = null;
    _cachedSelection = null;
    _cachedState = null;
    
    _emitState();
  }

  /// 전체 해제
  void unselectAll() {
    _selectedVocabularyFiles.clear();
    
    // 모든 캐시 무효화
    _cachedStats = null;
    _cachedSelection = null;
    _cachedState = null;
    
    _emitState();
  }

  // ===== 통계 계산 =====

  // 통계 캐시 (성능 최적화)
  VocabularyListStats? _cachedStats;
  Set<String>? _cachedSelection;
  
  // 상태 객체 캐시 (객체 생성 최소화)
  VocabularyListState? _cachedState;

  /// 선택된 어휘집들의 통계 정보 (캐싱 적용)
  VocabularyListStats getSelectedStats() {
    final stopwatch = Stopwatch()..start();
    
    if (_selectedVocabularyFiles.isEmpty) {
      print('🔧 PERF: getSelectedStats (empty) - ${stopwatch.elapsedMilliseconds}ms');
      return VocabularyListStats.empty();
    }

    // 캐시 확인: 선택이 변경되지 않았으면 캐시된 값 반환
    if (_cachedStats != null && 
        _cachedSelection != null &&
        _cachedSelection!.length == _selectedVocabularyFiles.length &&
        _cachedSelection!.every(_selectedVocabularyFiles.contains)) {
      print('🔧 PERF: getSelectedStats (cached) - ${stopwatch.elapsedMilliseconds}ms');
      return _cachedStats!;
    }

    print('🔧 PERF: getSelectedStats (computing) for ${_selectedVocabularyFiles.length} files...');

    // 새로운 통계 계산 (한 번에 모든 통계 계산)
    final stats = _computeStatsEfficiently();

    // 캐시 업데이트 (Set 복사 최소화)
    _cachedStats = stats;
    _cachedSelection = {..._selectedVocabularyFiles}; // spread 연산자 사용

    stopwatch.stop();
    print('🔧 PERF: getSelectedStats (computed) - ${stopwatch.elapsedMilliseconds}ms');
    return stats;
  }

  /// 효율적인 통계 계산 (한 번의 순회로 모든 값 계산)
  VocabularyListStats _computeStatsEfficiently() {
    int totalWords = 0;
    int favoriteWords = 0;
    int wrongWords = 0;
    int wrongCount = 0;

    // 선택된 파일들만 순회
    for (final fileInfo in _vocabularyFiles) {
      if (_selectedVocabularyFiles.contains(fileInfo.fileName)) {
        totalWords += fileInfo.totalWords;
        favoriteWords += fileInfo.favoriteWords;
        wrongWords += fileInfo.wrongWords;
        wrongCount += fileInfo.wrongCount;
      }
    }

    return VocabularyListStats(
      totalWords: totalWords,
      favoriteWords: favoriteWords,
      wrongWords: wrongWords,
      wrongCount: wrongCount,
    );
  }

  // ===== 액션 처리 =====

  /// 선택된 어휘집들 삭제
  Future<bool> deleteSelectedVocabularies() async {
    if (_selectedVocabularyFiles.isEmpty) return false;

    try {
      for (final fileName in _selectedVocabularyFiles) {
        // 개별 파일 캐시 무효화 (성능 최적화)
        _filterService.clearCacheForFile(fileName);
        await _vocabularyService.deleteVocabularyFile(fileName);
      }

      _selectedVocabularyFiles.clear();
      await refreshVocabularyList();
      
      // 삭제 후 강제로 상태 발행 (UI 즉시 업데이트를 위해)
      _emitStateImmediately();
      print('🔧 DEBUG: 삭제 후 강제 상태 발행 완료');
      
      return true;
    } catch (e) {
      _emitState(error: tr('errors.error_delete_vocabulary', namespace: 'home/vocabulary_list', params: {'error': e.toString()}));
      return false;
    }
  }

  /// 선택된 어휘집들의 틀린횟수 초기화
  Future<bool> resetWrongCounts() async {
    if (_selectedVocabularyFiles.isEmpty) return false;

    try {
      for (final fileName in _selectedVocabularyFiles) {
        await _hiveService.resetWrongCounts(fileName);
      }

      await refreshVocabularyList();
      return true;
    } catch (e) {
      _emitState(error: tr('errors.error_reset_wrong_counts', namespace: 'home/vocabulary_list', params: {'error': e.toString()}));
      return false;
    }
  }

  /// 선택된 어휘집들의 즐겨찾기 초기화
  Future<bool> resetFavorites() async {
    if (_selectedVocabularyFiles.isEmpty) return false;

    try {
      for (final fileName in _selectedVocabularyFiles) {
        await _hiveService.resetFavorites(fileName);
      }

      await refreshVocabularyList();
      return true;
    } catch (e) {
      _emitState(error: tr('errors.error_reset_favorites', namespace: 'home/vocabulary_list', params: {'error': e.toString()}));
      return false;
    }
  }

  // ===== 내부 메서드 =====

  /// 상태 변경 알림 (즉시 업데이트)
  void _emitState({String? error}) {
    // 모든 상태 변경을 즉시 처리
    _emitStateImmediately(error: error);
  }


  /// 즉시 상태 전송 (빠른 UI 반응을 위한 경량 버전)
  void _emitStateImmediate() {
    print('🔧 PERF: Immediate state emit (fast UI update)');
    
    // 경량 상태 객체 (통계 계산 생략)
    final quickState = VocabularyListState(
      vocabularyFiles: _vocabularyFiles,
      selectedFiles: _selectedVocabularyFiles,
      isMultiSelectMode: _isMultiSelectMode,
      selectedStats: VocabularyListStats.empty(), // 빈 통계로 즉시 반응
    );
    
    _stateController.add(quickState);
    
    // 50ms 후 정확한 통계로 업데이트 (빠른 반응성)
    Timer(const Duration(milliseconds: 50), () {
      if (_selectedVocabularyFiles.isNotEmpty) {
        print('🔧 PERF: Fast stats calculation starting...');
        _emitStateImmediately();
      }
    });
  }

  /// 즉시 상태 전송 (변경 시에만 이벤트 발생)
  void _emitStateImmediately({String? error}) {
    // 현재 상태 확인
    final currentFiles = _selectedVocabularyFiles;
    final currentMode = _isMultiSelectMode;
    
    // 이전 상태와 동일한지 확인 (중복 이벤트 방지)
    if (_cachedState != null && 
        error == null &&
        _cachedState!.selectedFiles.length == currentFiles.length &&
        _cachedState!.isMultiSelectMode == currentMode) {
      
      // Set 내용이 동일한지 빠른 확인
      bool sameSelection = true;
      for (final file in currentFiles) {
        if (!_cachedState!.selectedFiles.contains(file)) {
          sameSelection = false;
          break;
        }
      }
      
      if (sameSelection) {
        print('🔧 PERF: State unchanged, skipping emit');
        return; // 동일한 상태면 이벤트 발생 안함
      }
    }
    
    print('🔧 PERF: State changed, emitting new state');
    
    final state = VocabularyListState(
      vocabularyFiles: _vocabularyFiles,
      selectedFiles: currentFiles,
      isMultiSelectMode: currentMode,
      selectedStats: getSelectedStats(),
      error: error,
    );
    
    // 캐시 업데이트 (에러가 없을 때만)
    if (error == null) {
      _cachedState = state;
    }
    
    _stateController.add(state);
  }

  /// 리소스 정리
  void dispose() {
    _stateController.close();
  }
}

/// 어휘집 목록 상태 클래스
class VocabularyListState {
  final List<VocabularyFileInfo> vocabularyFiles;
  final Set<String> selectedFiles;
  final bool isMultiSelectMode;
  final VocabularyListStats selectedStats;
  final String? error;

  VocabularyListState({
    required this.vocabularyFiles,
    required this.selectedFiles,
    required this.isMultiSelectMode,
    required this.selectedStats,
    this.error,
  });

  bool get hasError => error != null;
  bool get hasSelection => selectedFiles.isNotEmpty;
  int get selectedCount => selectedFiles.length;
}

/// 어휘집 통계 정보 클래스
class VocabularyListStats {
  final int totalWords;
  final int favoriteWords;
  final int wrongWords;
  final int wrongCount;

  VocabularyListStats({
    required this.totalWords,
    required this.favoriteWords,
    required this.wrongWords,
    required this.wrongCount,
  });

  factory VocabularyListStats.empty() {
    return VocabularyListStats(
      totalWords: 0,
      favoriteWords: 0,
      wrongWords: 0,
      wrongCount: 0,
    );
  }

  /// 통계 요약 문자열 (UI 표시용)
  String get summaryText {
    return '📝$totalWords${tr('units.words')} '
        '⭐$favoriteWords${tr('units.words')} '
        '❌$wrongWords${tr('units.words')} '
        '🔢$wrongCount${tr('units.count')}';
  }
}
