import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/home/vocabulary_list/vocabulary_list_service.dart';
import '../../services/home/vocabulary_list/vocabulary_export_service.dart';
import '../../services/common/vocabulary_service.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../../utils/themes/colors.dart';
import '../dialogs/add_vocabulary_dialog.dart';

/// 📚 어휘집 목록 섹션 (ui-home.mdc 구조 준수)
/// 어휘집 선택, 관리, 액션 버튼들을 포함하는 완전한 섹션
class VocabularyListSection extends StatefulWidget {
  final Function(Set<String>)? onSelectionChanged;

  const VocabularyListSection({
    super.key,
    this.onSelectionChanged,
  });

  @override
  State<VocabularyListSection> createState() => _VocabularyListSectionState();
}

class _VocabularyListSectionState extends State<VocabularyListSection> {
  final VocabularyListService _listService = VocabularyListService.instance;
  final VocabularyExportService _exportService =
      VocabularyExportService.instance;

  StreamSubscription<VocabularyListState>? _stateSubscription;
  VocabularyListState? _currentState;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subscribeToState();
    _initializeData();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  /// 데이터 초기화
  void _initializeData() async {
    print('🔍 VocabularyListSection 데이터 초기화 시작');
    setState(() => _isLoading = true);
    
    try {
      await _listService.refreshVocabularyList();
      print('🔍 VocabularyListService 새로고침 완료');
      
      // 5초 후에도 상태가 업데이트되지 않으면 타임아웃 처리
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_currentState == null && mounted) {
        print('⚠️ 타임아웃: 상태가 업데이트되지 않아 강제로 초기 상태 설정');
        // 서비스에서 현재 상태 직접 가져오기
        final currentState = _listService.currentState;
        print('🔍 서비스에서 직접 가져온 상태: ${currentState.vocabularyFiles.length}개 어휘집');
        
        if (mounted) {
          setState(() => _currentState = currentState);
        }
      }
    } catch (e) {
      print('❌ VocabularyListSection 초기화 에러: $e');
      if (mounted) {
        setState(() => _currentState = VocabularyListState(
          vocabularyFiles: [],
          selectedFiles: {},
          isMultiSelectMode: false,
          selectedStats: VocabularyListStats.empty(),
          error: '어휘집 목록을 불러오는데 실패했습니다: $e',
        ));
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// 상태 변경 구독
  void _subscribeToState() {
    print('🔍 VocabularyListSection Stream 구독 시작');
    _stateSubscription = _listService.stateStream.listen(
      (state) {
        print(
            '🔍 VocabularyListSection 상태 변경: ${state.vocabularyFiles.length}개 어휘집, 에러: ${state.hasError}');
        print('🔍 상태 수신됨 - _currentState가 업데이트됩니다');
        
        if (mounted) {
          setState(() => _currentState = state);
        }

        // 어휘집 선택 변경을 부모에게 알림
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!(state.selectedFiles);
        }

        // 에러 처리
        if (state.hasError && mounted) {
          print('❌ VocabularyListSection 에러: ${state.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onError: (error) {
        print('❌ VocabularyListSection Stream 에러: $error');
        if (mounted) {
          setState(() => _currentState = VocabularyListState(
            vocabularyFiles: [],
            selectedFiles: {},
            isMultiSelectMode: false,
            selectedStats: VocabularyListStats.empty(),
            error: 'Stream 에러: $error',
          ));
        }
      },
      onDone: () {
        print('🔍 VocabularyListSection Stream 종료됨');
      },
    );
    print('🔍 VocabularyListSection Stream 구독 완료');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageNotifier.instance,
      builder: (context, _) {
        print(
            '🔍 VocabularyListSection build: _isLoading=$_isLoading, _currentState=${_currentState?.vocabularyFiles.length ?? 'null'}');
        
        if (_currentState != null) {
          print('🔍 상태 세부정보: 어휘집=${_currentState!.vocabularyFiles.length}개, 선택=${_currentState!.selectedFiles.length}개, 다중선택=${_currentState!.isMultiSelectMode}');
        }

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 데이터가 아직 로드되지 않았다면 로딩 표시
        if (_currentState == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('어휘집 목록을 불러오는 중...'),
              ],
            ),
          );
        }

    // 에러 상태 표시
    if (_currentState!.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _currentState!.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _currentState = null);
                _initializeData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E23),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 16),
            _buildVocabularyInfoGuide(),
            const SizedBox(height: 16),
            _buildSelectedStatsAndActions(),
            const SizedBox(height: 16),
            _buildVocabularyGrid(),
          ],
        );
      },
    );
  }

  /// 섹션 헤더 (UI 문서 스타일)
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          tr('section.title', namespace: 'home/vocabulary_list'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: _showHelpDialog,
          child: const Text(' ❓', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  /// 액션 버튼들 (세련된 배치)
  Widget _buildActionButtons() {
    final state = _currentState;
    if (state == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            _buildSelectionModeToggle(),
            const SizedBox(width: 10),
            _buildSelectAllButton(),
            const SizedBox(width: 10),
            _buildUnselectAllButton(),
            const SizedBox(width: 10),
            ..._buildConditionalButtons(),
          ],
        ),
      ),
    );
  }

  /// 조건부 버튼들 (조건에 맞을 때만 표시)
  List<Widget> _buildConditionalButtons() {
    final state = _currentState;
    if (state == null) return [];

    final List<Widget> buttons = [];
    final selectedFiles = state.selectedFiles.toList();

    // 삭제 버튼 (선택된 어휘집이 있을 때만)
    if (state.hasSelection) {
      buttons.addAll([
        _buildDeleteButton(),
        const SizedBox(width: 10),
      ]);
    }

    // 내보내기 버튼 (내보낼 수 있는 어휘집이 있을 때만)
    if (_exportService.canExport(selectedFiles)) {
      buttons.addAll([
        _buildExportButton(),
        const SizedBox(width: 10),
      ]);
    }

    // 틀린횟수 초기화 버튼 (초기화할 수 있는 어휘집이 있을 때만)
    if (_exportService.canResetWrongCounts(selectedFiles)) {
      buttons.addAll([
        _buildResetWrongCountsButton(),
        const SizedBox(width: 10),
      ]);
    }

    // 즐겨찾기 초기화 버튼 (초기화할 수 있는 어휘집이 있을 때만)
    if (_exportService.canResetFavorites(selectedFiles)) {
      buttons.addAll([
        _buildResetFavoritesButton(),
        const SizedBox(width: 10),
      ]);
    }

    // 마지막 SizedBox 제거
    if (buttons.isNotEmpty && buttons.last is SizedBox) {
      buttons.removeLast();
    }

    return buttons;
  }

  /// 선택된 어휘집 통계와 액션 버튼들을 함께 표시 (한 줄로 배치)
  Widget _buildSelectedStatsAndActions() {
    final state = _currentState;
    if (state == null) return const SizedBox.shrink();

    return Row(
      children: [
        // 선택된 어휘집 개수 (선택된 것이 있을 때만)
        if (state.hasSelection) ...[
          _buildSelectedStats(),
          const SizedBox(width: 16),
        ],
        // 액션 버튼들 (나머지 공간 차지)
        Expanded(child: _buildActionButtons()),
      ],
    );
  }

  /// 선택 모드 토글 버튼 (모던 스타일)
  Widget _buildSelectionModeToggle() {
    final state = _currentState;
    if (state == null) return const SizedBox.shrink();

    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: state.isMultiSelectMode 
            ? AppColors.primary
            : AppColors.textSecondary.withValues(alpha: 0.1),
        boxShadow: state.isMultiSelectMode ? AppShadows.button : AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _listService.toggleSelectionMode,
          borderRadius: BorderRadius.circular(12),
          splashColor: state.isMultiSelectMode 
              ? Colors.white.withValues(alpha: 0.2) 
              : AppColors.ripplePrimary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.isMultiSelectMode
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 18,
                  color: state.isMultiSelectMode 
                      ? Colors.white 
                      : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  state.isMultiSelectMode
                      ? tr('mode.multi_select', namespace: 'home/vocabulary_list')
                      : tr('mode.single_select', namespace: 'home/vocabulary_list'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: state.isMultiSelectMode 
                        ? Colors.white 
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 전체 선택 버튼 (프리미엄 스타일)
  Widget _buildSelectAllButton() {
    return _buildActionButton(
      onPressed: _listService.selectAll,
      icon: Icons.select_all_rounded,
      label: tr('actions.select_all', namespace: 'home/vocabulary_list'),
      color: AppColors.accent,
      isOutlined: true,
    );
  }

  /// 전체 해제 버튼 (프리미엄 스타일)
  Widget _buildUnselectAllButton() {
    return _buildActionButton(
      onPressed: _listService.unselectAll,
      icon: Icons.clear_rounded,
      label: tr('actions.unselect_all', namespace: 'home/vocabulary_list'),
      color: AppColors.textSecondary,
      isOutlined: true,
    );
  }

  /// 삭제 버튼 (프리미엄 스타일)
  Widget _buildDeleteButton() {
    return _buildActionButton(
      onPressed: _showDeleteConfirmDialog,
      icon: Icons.delete_rounded,
      label: tr('actions.delete_button', namespace: 'home/vocabulary_list'),
      color: AppColors.error,
    );
  }

  /// 내보내기 버튼 (프리미엄 스타일)
  Widget _buildExportButton() {
    return _buildActionButton(
      onPressed: _exportVocabularies,
      icon: Icons.file_download_rounded,
      label: tr('actions.export_button', namespace: 'home/vocabulary_list'),
      color: AppColors.accent,
    );
  }

  /// 틀린횟수 초기화 버튼 (프리미엄 스타일)
  Widget _buildResetWrongCountsButton() {
    return _buildActionButton(
      onPressed: _resetWrongCounts,
      icon: Icons.refresh_rounded,
      label: tr('actions.reset_wrong_counts_button', namespace: 'home/vocabulary_list'),
      color: AppColors.warning,
    );
  }

  /// 즐겨찾기 초기화 버튼 (프리미엄 스타일)
  Widget _buildResetFavoritesButton() {
    return _buildActionButton(
      onPressed: _resetFavorites,
      icon: Icons.star_border_rounded,
      label: tr('actions.reset_favorites_button', namespace: 'home/vocabulary_list'),
      color: AppColors.purple,
    );
  }

  /// 공통 액션 버튼 빌더 (통일된 프리미엄 스타일)
  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: !isOutlined ? color : null,
        border: isOutlined
            ? Border.all(
                color: color,
                width: 1.5,
              )
            : null,
        boxShadow: !isOutlined ? AppShadows.button : AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: isOutlined 
              ? color.withValues(alpha: 0.1) 
              : Colors.white.withValues(alpha: 0.2),
          highlightColor: isOutlined 
              ? color.withValues(alpha: 0.05) 
              : Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isOutlined ? color : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOutlined ? color : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 선택된 어휘집 개수 표시 (간단한 텍스트)
  Widget _buildSelectedStats() {
    final state = _currentState;
    if (state == null || !state.hasSelection) return const SizedBox.shrink();

    // 통계가 계산 중일 때 (빈 통계) 로딩 표시
    final stats = state.selectedStats;
    final isCalculating = stats.totalWords == 0 && 
                          stats.favoriteWords == 0 && 
                          stats.wrongWords == 0 && 
                          stats.wrongCount == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: isCalculating 
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              const SizedBox(width: 6),
              Text(
                '계산 중...',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          )
        : Text(
            '📝${stats.totalWords} ⭐${stats.favoriteWords} ❌${stats.wrongWords} 🔢${stats.wrongCount}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
    );
  }

  /// 어휘집 정보 가이드 (모던 디자인)
  Widget _buildVocabularyInfoGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.accent,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr('guide.vocab_info', namespace: 'home/vocabulary_list'),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  /// 어휘집 그리드 (6열)
  Widget _buildVocabularyGrid() {
    final state = _currentState;
    if (state == null) return const SizedBox.shrink();

    final vocabularies = state.vocabularyFiles;

    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 6;
        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return GridView.builder(
          key: ValueKey('vocab_grid_${vocabularies.length}_${vocabularies.map((v) => '${v.fileName}_${v.totalWords}_${v.favoriteWords}').join('_')}'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: cardWidth / 125, // 높이를 125px로 최적화
            crossAxisSpacing: 12, // 카드 간격 증가
            mainAxisSpacing: 12, // 카드 간격 증가
          ),
          itemCount: vocabularies.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAddVocabularyCard();
            }

            final vocabulary = vocabularies[index - 1];
            final isSelected =
                state.selectedFiles.contains(vocabulary.fileName);

            return _buildVocabularyCard(
              vocabulary: vocabulary,
              isSelected: isSelected,
              showSelection: state.isMultiSelectMode,
            );
          },
        );
      },
    );
  }

  /// 개별 어휘집 카드 (성능 최적화 버전)
  Widget _buildVocabularyCard({
    required VocabularyFileInfo vocabulary,
    required bool isSelected,
    required bool showSelection,
  }) {
    // 성능 최적화: AnimatedContainer 제거, Material/InkWell 최적화
    return GestureDetector(
      onTap: () {
        print('🔧 PERF: Card tap - immediate response');
        _listService.toggleVocabularySelection(vocabulary.fileName);
      },
      onLongPress: () => _listService.toggleVocabularySelection(vocabulary.fileName),
      child: Container(
        height: 125,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? AppShadows.cardSelected : AppShadows.card,
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (이름만 - 선택은 색깔과 테두리로 표시)
            Text(
              vocabulary.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 통계 정보 (2x2 그리드) - 고정 높이로 overflow 방지
            SizedBox(
              height: 50,
              child: _buildStatsGrid(vocabulary),
            ),
            const SizedBox(height: 4),
            // 날짜 (중앙 정렬)
            Center(
              child: Text(
                vocabulary.importedDateString,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2x2 그리드로 통계 정보 표시
  Widget _buildStatsGrid(VocabularyFileInfo vocabulary) {
    return Column(
      children: [
        // 첫 번째 행: 📝단어 + ⭐즐겨찾기
        SizedBox(
          height: 20,
          child: Row(
            children: [
              Expanded(child: _buildStatCell('📝', '${vocabulary.totalWords}', '단어')),
              const SizedBox(width: 4),
              Expanded(child: _buildStatCell('⭐', '${vocabulary.favoriteWords}', '즐겨찾기')),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 두 번째 행: ❌틀린단어 + 🔢틀린횟수
        SizedBox(
          height: 20,
          child: Row(
            children: [
              Expanded(child: _buildStatCell('❌', '${vocabulary.wrongWords}', '틀린단어')),
              const SizedBox(width: 4),
              Expanded(child: _buildStatCell('🔢', '${vocabulary.wrongCount}', '틀린횟수')),
            ],
          ),
        ),
      ],
    );
  }

  /// 그리드용 통계 셀 (텍스트 라벨 제거, 중앙 정렬)
  Widget _buildStatCell(String icon, String value, String label) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 새 어휘집 추가 카드 (세련된 디자인)
  Widget _buildAddVocabularyCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _showAddVocabularyDialog,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.ripplePrimary,
          highlightColor: AppColors.hoverPrimary,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primaryAlpha(0.03),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        color: AppColors.primaryAlpha(0.3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ...() {
                  final lines = tr('guide.add_new_vocab', namespace: 'home/vocabulary_list').split('\n');
                  return [
                    Text(
                      lines.isNotEmpty ? lines[0] : tr('guide.add_new_vocab', namespace: 'home/vocabulary_list'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lines.length > 1 ? lines[1] : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ];
                }(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== 액션 메서드들 =====

  /// 새 어휘집 추가 다이얼로그
  void _showAddVocabularyDialog() async {
    print('🔧 DEBUG: _showAddVocabularyDialog 호출됨');
    
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) {
          print('🔧 DEBUG: Dialog builder 호출됨');
          return const AddVocabularyDialog();
        },
      );

      print('🔧 DEBUG: Dialog 결과: $result');
      
      if (result == true) {
        print('🔧 DEBUG: 어휘집 목록 새로고침 시작');
        await _listService.refreshVocabularyList();
        print('🔧 DEBUG: 어휘집 목록 새로고침 완료');
        
        // 강제로 setState를 호출하여 UI 즉시 업데이트
        if (mounted) {
          setState(() {
            _currentState = _listService.currentState;
          });
          print('🔧 DEBUG: setState로 강제 UI 업데이트 완료');
          
          // 부모에게 선택 변경 알림 (필터 업데이트를 위해)
          if (widget.onSelectionChanged != null) {
            final currentSelectedFiles = _currentState?.selectedFiles ?? {};
            widget.onSelectionChanged!(currentSelectedFiles);
            print('🔧 DEBUG: 추가 후 onSelectionChanged 콜백 호출: ${currentSelectedFiles.length}개 선택');
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: AddVocabularyDialog 표시 중 오류: $e');
      print('❌ StackTrace: $stackTrace');
    }
  }

  /// 도움말 다이얼로그
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('dialog.help_title', namespace: 'home/vocabulary_list')),
        content: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Text(
              tr('dialog.help_content', namespace: 'home/vocabulary_list'),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('dialog.close')),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog() async {
    final state = _currentState;
    if (state == null || !state.hasSelection) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('dialog.delete_confirm_title', namespace: 'home/vocabulary_list')),
        content: Text(tr('dialog.delete_confirm_message', namespace: 'home/vocabulary_list', params: {'count': state.selectedCount})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('dialog.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr('actions.delete_button', namespace: 'home/vocabulary_list')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _listService.deleteSelectedVocabularies();
      if (success && mounted) {
        // 강제로 setState를 호출하여 UI 즉시 업데이트
        setState(() {
          _currentState = _listService.currentState;
        });
        print('🔧 DEBUG: 삭제 후 setState로 강제 UI 업데이트 완료');
        
        // 부모에게 선택 변경 알림 (필터 초기화를 위해)
        if (widget.onSelectionChanged != null) {
          final currentSelectedFiles = _currentState?.selectedFiles ?? {};
          widget.onSelectionChanged!(currentSelectedFiles);
          print('🔧 DEBUG: 삭제 후 onSelectionChanged 콜백 호출: ${currentSelectedFiles.length}개 선택');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('dialog.delete_success_message', namespace: 'home/vocabulary_list')),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 어휘집 내보내기
  void _exportVocabularies() async {
    final state = _currentState;
    if (state == null || !state.hasSelection) return;

    final success = await _exportService.exportVocabulariesToCSV(
      state.selectedFiles.toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('dialog.export_success_message', namespace: 'home/vocabulary_list')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// 틀린횟수 초기화
  void _resetWrongCounts() async {
    final state = _currentState;
    if (state == null || !state.hasSelection) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('dialog.reset_wrong_counts_title', namespace: 'home/vocabulary_list')),
        content: Text(tr('dialog.reset_wrong_counts_message', namespace: 'home/vocabulary_list', params: {'count': state.selectedCount})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('dialog.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(tr('actions.reset_button', namespace: 'home/vocabulary_list')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _exportService.resetWrongCounts(
        state.selectedFiles.toList(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('dialog.reset_wrong_counts_success', namespace: 'home/vocabulary_list')),
            backgroundColor: Colors.green,
          ),
        );
        await _listService.refreshVocabularyList();
      }
    }
  }

  /// 즐겨찾기 초기화
  void _resetFavorites() async {
    final state = _currentState;
    if (state == null || !state.hasSelection) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('dialog.reset_favorites_title', namespace: 'home/vocabulary_list')),
        content: Text(tr('dialog.reset_favorites_message', namespace: 'home/vocabulary_list', params: {'count': state.selectedCount})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('dialog.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
            child: Text(tr('actions.reset_button', namespace: 'home/vocabulary_list')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _exportService.resetFavorites(
        state.selectedFiles.toList(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('dialog.reset_favorites_success', namespace: 'home/vocabulary_list')),
            backgroundColor: Colors.green,
          ),
        );
        await _listService.refreshVocabularyList();
      }
    }
  }
}
