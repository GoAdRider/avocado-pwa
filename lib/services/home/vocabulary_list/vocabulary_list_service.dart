import 'dart:async';
import '../../common/vocabulary_service.dart';
import '../../common/hive_service.dart';
import '../../../utils/strings/base_strings.dart';
import '../../../utils/strings/home_strings.dart';

/// 어휘집 목록 섹션의 UI 로직을 담당하는 서비스
/// 선택 관리, 액션 처리, 상태 관리 등을 포함
class VocabularyListService {
  static VocabularyListService? _instance;
  static VocabularyListService get instance =>
      _instance ??= VocabularyListService._internal();
  VocabularyListService._internal();

  final VocabularyService _vocabularyService = VocabularyService.instance;
  final HiveService _hiveService = HiveService.instance;

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

  /// 어휘집 선택/해제
  void toggleVocabularySelection(String fileName) {
    if (_selectedVocabularyFiles.contains(fileName)) {
      _selectedVocabularyFiles.remove(fileName);
    } else {
      if (!_isMultiSelectMode) {
        _selectedVocabularyFiles.clear();
      }
      _selectedVocabularyFiles.add(fileName);
    }
    _emitState();
  }

  /// 전체 선택
  void selectAll() {
    _isMultiSelectMode = true;
    _selectedVocabularyFiles =
        _vocabularyFiles.map((info) => info.fileName).toSet();
    _emitState();
  }

  /// 전체 해제
  void unselectAll() {
    _selectedVocabularyFiles.clear();
    _emitState();
  }

  // ===== 통계 계산 =====

  /// 선택된 어휘집들의 통계 정보
  VocabularyListStats getSelectedStats() {
    if (_selectedVocabularyFiles.isEmpty) {
      return VocabularyListStats.empty();
    }

    return VocabularyListStats(
      totalWords: _vocabularyService.getSelectedWordCount(
          _vocabularyFiles, _selectedVocabularyFiles),
      favoriteWords: _vocabularyService.getSelectedFavoriteCount(
          _vocabularyFiles, _selectedVocabularyFiles),
      wrongWords: _vocabularyService.getSelectedWrongCount(
          _vocabularyFiles, _selectedVocabularyFiles),
      wrongCount: _vocabularyService.getSelectedWrongCountTotal(
          _vocabularyFiles, _selectedVocabularyFiles),
    );
  }

  // ===== 액션 처리 =====

  /// 선택된 어휘집들 삭제
  Future<bool> deleteSelectedVocabularies() async {
    if (_selectedVocabularyFiles.isEmpty) return false;

    try {
      for (final fileName in _selectedVocabularyFiles) {
        await _vocabularyService.deleteVocabularyFile(fileName);
      }

      _selectedVocabularyFiles.clear();
      await refreshVocabularyList();
      return true;
    } catch (e) {
      _emitState(error: HomeStrings.errorDeleteVocabulary(e.toString()));
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
      _emitState(error: HomeStrings.errorResetWrongCounts(e.toString()));
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
      _emitState(error: HomeStrings.errorResetFavorites(e.toString()));
      return false;
    }
  }

  // ===== 내부 메서드 =====

  /// 상태 변경 알림
  void _emitState({String? error}) {
    final state = VocabularyListState(
      vocabularyFiles: _vocabularyFiles,
      selectedFiles: _selectedVocabularyFiles,
      isMultiSelectMode: _isMultiSelectMode,
      selectedStats: getSelectedStats(),
      error: error,
    );
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
    return '📝$totalWords${BaseStrings.wordsUnit} '
        '⭐$favoriteWords${BaseStrings.wordsUnit} '
        '❌$wrongWords${BaseStrings.wordsUnit} '
        '🔢$wrongCount${BaseStrings.countUnit}';
  }
}
