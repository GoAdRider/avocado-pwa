import 'package:flutter/material.dart';
import '../widgets/common/app_layout.dart';
import '../widgets/home/vocabulary_list_section.dart';
import '../widgets/home/study_status_section.dart';
import '../widgets/home/forgetting_curve_review_section.dart';
import '../widgets/home/recent_study_section.dart';
import '../services/common/vocabulary_service.dart';
import '../services/home/filter/filter_service.dart';
import '../services/home/vocabulary_list/vocabulary_list_service.dart';
import '../services/home/study_status/study_status_service.dart';
import '../services/common/study_progress_service.dart';
import '../utils/i18n/simple_i18n.dart';
import '../models/vocabulary_word.dart';
import '../models/study_progress.dart';
import 'study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // 홈 스크롤 컨트롤러 (static으로 외부에서 접근 가능)
  static final ScrollController _scrollController = ScrollController();
  
  /// 홈 화면 최상단으로 스크롤 (로고 버튼에서 호출)
  static void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // 서비스
  final VocabularyService _vocabularyService = VocabularyService.instance;
  final FilterService _filterService = FilterService.instance;
  final StudyStatusService _studyStatusService = StudyStatusService.instance;

  // 선택된 항목들
  final Set<String> _selectedVocabFiles = {}; // 어휘집 파일명 선택
  final Set<String> _selectedPOSFilters = {}; // 품사 필터 선택
  final Set<String> _selectedTypeFilters = {}; // 타입 필터 선택
  
  // 성능 최적화: 선택적 리빌드를 위한 ValueNotifier
  late final ValueNotifier<Set<String>> _selectedVocabNotifier;
  late final ValueNotifier<Set<String>> _selectedPOSNotifier;
  late final ValueNotifier<Set<String>> _selectedTypeNotifier;

  // 학습 모드 (라디오 버튼)
  String _studyMode = 'TargetVoca';

  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // ValueNotifier 초기화
    _selectedVocabNotifier = ValueNotifier(Set.from(_selectedVocabFiles));
    _selectedPOSNotifier = ValueNotifier(Set.from(_selectedPOSFilters));
    _selectedTypeNotifier = ValueNotifier(Set.from(_selectedTypeFilters));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _editController.dispose();
    
    // ValueNotifier 정리
    _selectedVocabNotifier.dispose();
    _selectedPOSNotifier.dispose();
    _selectedTypeNotifier.dispose();
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 HomeScreen 앱 상태 변경: $state');
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 데이터 새로고침
      debugPrint('🔄 앱 포그라운드 복귀 - 강제 새로고침');
      _forceRefreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🔄 HomeScreen didChangeDependencies 호출 - 즉시 새로고침');
    // 화면이 다시 보여질 때마다 최근 학습 기록 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RecentStudySectionController.refresh();
    });
  }

  /// 강제 데이터 새로고침 (학습 완료 후 호출)
  void _forceRefreshData() async {
    debugPrint('🔄 강제 데이터 새로고침 시작 - 모든 섹션 새로고침');
    
    try {
      // 최근 학습 기록 새로고침 (RecentStudySection 통해)
      RecentStudySectionController.refresh();
      
      // 어휘집 목록 완전 강제 새로고침 (학습 완료 후 즉각 업데이트)
      await VocabularyListService.instance.forceCompleteRefresh();
      
      debugPrint('🔄 모든 섹션 데이터 새로고침 완료');
      
      // UI 강제 업데이트
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('🔄 데이터 새로고침 중 오류: $e');
      // 개별적으로 다시 시도
      RecentStudySectionController.refresh();
      VocabularyListService.instance.refreshVocabularyList().catchError((e) {
        debugPrint('🔄 어휘집 목록 새로고침 실패: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 언어 변경은 LanguageNotifier가 자동으로 처리

    // 홈화면이 다시 빌드될 때마다 최근 학습 기록 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 마지막 데이터 로드 시간과 현재 시간을 비교하여 필요시 새로고침
      _checkAndRefreshIfNeeded();
    });

    return AppLayout(
      customQuote: tr('footer.default_quote'),
      child: SingleChildScrollView(
        controller: HomeScreen._scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 24),
            const StudyStatusSection(),
            const SizedBox(height: 24),
            const SmartReviewSection(),
            const SizedBox(height: 24),
            RecentStudySection(
              key: RecentStudySectionController.key,
              onStudyCompleted: () async {
                debugPrint('🔄 RecentStudySection에서 학습 완료 알림 받음');
                // 짧은 지연 후 새로고침 (Hive 데이터 쓰기 완료 대기)
                await Future.delayed(const Duration(milliseconds: 100));
                _forceRefreshData();
                // 학습 현황 서비스에 학습 완료 알림
                _studyStatusService.notifyStudyCompleted();
              },
              selectedPOSFilters: _selectedPOSFilters,
              selectedTypeFilters: _selectedTypeFilters,
              studyMode: _studyMode,
            ),
            const SizedBox(height: 24),
            VocabularyListSection(
              onSelectionChanged: (selectedFiles) {
                // setState 없이 즉시 업데이트 (성능 최적화)
                if (_selectedVocabFiles.length != selectedFiles.length || 
                    !_selectedVocabFiles.every(selectedFiles.contains)) {
                  
                  print('🔧 PERF: Updating vocab selection without setState');
                  
                  // 내부 Set 업데이트
                  _selectedVocabFiles.clear();
                  _selectedVocabFiles.addAll(selectedFiles);
                  
                  // 어휘집 선택이 변경되면 필터도 초기화
                  _selectedPOSFilters.clear();
                  _selectedTypeFilters.clear();
                  
                  // ValueNotifier로 선택적 업데이트
                  _selectedVocabNotifier.value = Set.from(selectedFiles);
                  _selectedPOSNotifier.value = Set.from(_selectedPOSFilters);
                  _selectedTypeNotifier.value = Set.from(_selectedTypeFilters);
                  
                  print('🔧 PERF: Filters cleared due to vocab selection change');
                }
              },
            ),
            const SizedBox(height: 24),
            // 필터 섹션: 어휘집/필터 선택 변경 시에만 리빌드
            ListenableBuilder(
              listenable: LanguageNotifier.instance,
              builder: (context, _) {
                return ValueListenableBuilder<Set<String>>(
                  valueListenable: _selectedVocabNotifier,
                  builder: (context, selectedVocabs, child) {
                    return ValueListenableBuilder<Set<String>>(
                      valueListenable: _selectedPOSNotifier,
                      builder: (context, selectedPOS, child) {
                        return ValueListenableBuilder<Set<String>>(
                          valueListenable: _selectedTypeNotifier,
                          builder: (context, selectedTypes, child) {
                            print('🔧 PERF: Rebuilding filters section (optimized)');
                            return _buildFilters();
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: LanguageNotifier.instance,
              builder: (context, _) => _buildStudyModeSelection(),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: LanguageNotifier.instance,
              builder: (context, _) => _buildStudyMethodSelection(),
            ),
          ],
        ),
      ),
    );
  }

  /// 필요시 데이터 새로고침 확인
  DateTime? _lastRefreshTime;
  void _checkAndRefreshIfNeeded() {
    final now = DateTime.now();

    // 마지막 새로고침 후 500ms가 지났거나 처음 로드라면 새로고침 (더 빠른 반응)
    if (_lastRefreshTime == null ||
        now.difference(_lastRefreshTime!).inMilliseconds > 500) {
      _lastRefreshTime = now;
      debugPrint('🔄 홈화면 자동 새로고침 (마지막: $_lastRefreshTime)');
      
      // 최근 학습 기록만 즉시 새로고침 (성능 최적화)
      RecentStudySectionController.refresh();
    }
  }

  // 제목 섹션
  Widget _buildTitle() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Color(0xFFFFD700), size: 28),
          const SizedBox(width: 12),
          Text(
            tr('main.title'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B8E23),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.star, color: Color(0xFFFFD700), size: 28),
        ],
      ),
    );
  }

  // 필터 섹션
  Widget _buildFilters() {
    // 선택된 어휘집들을 기반으로 품사/타입 정보 가져오기
    final selectedFiles = _selectedVocabFiles.toList();

    if (selectedFiles.isEmpty) {
      return _buildEmptyFiltersSection();
    }

    // 선택된 필터에서 실제 값 추출 (괄호와 개수 제거)
    final selectedPosValues =
        _selectedPOSFilters.map((filter) => filter.split('(')[0]).toList();
    final selectedTypeValues =
        _selectedTypeFilters.map((filter) => filter.split('(')[0]).toList();

    // 상호 필터링을 고려한 개수 계산
    Map<String, int> positionCounts;
    Map<String, int> typeCounts;

    if (selectedTypeValues.isNotEmpty) {
      // 타입 필터가 선택된 경우: 해당 타입에 맞는 품사들의 개수 계산
      positionCounts = _filterService.getPositionCountsWithTypeFilter(
          selectedFiles, selectedTypeValues);
      // 모든 가능한 품사 목록을 가져와서 0개인 것도 표시
      final allPositions =
          _filterService.getAllPositionsForFiles(selectedFiles);
      for (final pos in allPositions) {
        positionCounts.putIfAbsent(pos, () => 0);
      }
    } else {
      // 타입 필터가 선택되지 않은 경우: 전체 품사 개수
      positionCounts = _filterService.getPositionCountsForFiles(selectedFiles);
    }

    if (selectedPosValues.isNotEmpty) {
      // 품사 필터가 선택된 경우: 해당 품사에 맞는 타입들의 개수 계산
      typeCounts = _filterService.getTypeCountsWithPositionFilter(
          selectedFiles, selectedPosValues);
      // 모든 가능한 타입 목록을 가져와서 0개인 것도 표시
      final allTypes = _filterService.getAllTypesForFiles(selectedFiles);
      for (final type in allTypes) {
        typeCounts.putIfAbsent(type, () => 0);
      }
    } else {
      // 품사 필터가 선택되지 않은 경우: 전체 타입 개수
      typeCounts = _filterService.getTypeCountsForFiles(selectedFiles);
    }

    // 품사 목록 생성 (품사명(개수) 형태) - UI 표시용으로 변환
    final positionFilters = positionCounts.entries
        .map((entry) =>
            '${_filterService.cleanupPositionForUI(entry.key)}(${entry.value})')
        .toList()
      ..sort();

    // 타입 목록 생성 (타입명(개수) 형태) - UI 표시용으로 변환
    final typeFilters = typeCounts.entries
        .map((entry) =>
            '${_filterService.cleanupTypeForUI(entry.key)}(${entry.value})')
        .toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr('section.title', namespace: 'home/filter'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tr('stats.filtered_words', namespace: 'home/filter', params: {
                    'words': int.parse(_getFilteredWordCount()),
                    'favorites': int.parse(_getFilteredFavoriteCount()),
                    'wrong': int.parse(_getFilteredWrongCount()),
                    'wrongCount': int.parse(_getFilteredWrongCountTotal())
                }),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 품사 필터
        _buildFilterSection(
          tr('ui.pos_filter', namespace: 'home/filter'),
          positionFilters,
          _selectedPOSFilters,
          (filter) {
            print('🔧 PERF: POS filter clicked - immediate response');
            final filterName = filter.split('(')[0];

            // 같은 이름의 기존 필터 찾기
            final existingFilter = _selectedPOSFilters.firstWhere(
              (selected) => selected.split('(')[0] == filterName,
              orElse: () => '',
            );

            if (existingFilter.isNotEmpty) {
              // 기존 필터가 있으면 제거 (토글 OFF)
              _selectedPOSFilters.remove(existingFilter);
            } else {
              // 기존 필터가 없으면 새로 추가 (토글 ON)
              _selectedPOSFilters.add(filter);
            }

            // ValueNotifier로 선택적 업데이트 (setState 제거)
            _selectedPOSNotifier.value = Set.from(_selectedPOSFilters);
          },
        ),
        const SizedBox(height: 16),
        // 타입 필터
        _buildFilterSection(
          tr('ui.type_filter', namespace: 'home/filter'),
          typeFilters,
          _selectedTypeFilters,
          (filter) {
            print('🔧 PERF: Type filter clicked - immediate response');
            final filterName = filter.split('(')[0];

            // 같은 이름의 기존 필터 찾기
            final existingFilter = _selectedTypeFilters.firstWhere(
              (selected) => selected.split('(')[0] == filterName,
              orElse: () => '',
            );

            if (existingFilter.isNotEmpty) {
              // 기존 필터가 있으면 제거 (토글 OFF)
              _selectedTypeFilters.remove(existingFilter);
            } else {
              // 기존 필터가 없으면 새로 추가 (토글 ON)
              _selectedTypeFilters.add(filter);
            }

            // ValueNotifier로 선택적 업데이트 (setState 제거)
            _selectedTypeNotifier.value = Set.from(_selectedTypeFilters);
          },
        ),
      ],
    );
  }

  // 어휘집 미선택 시 전체 필터 섹션
  Widget _buildEmptyFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr('section.title', namespace: 'home/filter'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tr('stats.filtered_words', namespace: 'home/filter', params: {
                    'words': 0,
                    'favorites': 0,
                    'wrong': 0,
                    'wrongCount': 0
                }),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNoSelectionMessage(tr('ui.pos_filter', namespace: 'home/filter')),
        const SizedBox(height: 16),
        _buildNoSelectionMessage(tr('ui.type_filter', namespace: 'home/filter')),
      ],
    );
  }

  // 어휘집 미선택 시 메시지
  Widget _buildNoSelectionMessage(String filterType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            tr('ui.no_selection_guide', namespace: 'home/filter', params: {'filter_type': filterType}),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr('ui.filter_select_vocab_first', namespace: 'home/filter'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 필터 섹션 빌더
  Widget _buildFilterSection(
    String title,
    List<String> filters,
    Set<String> selectedFilters,
    Function(String) onFilterTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            InkWell(
              onTap: () {
                print('🔧 PERF: Select all filters - no setState');
                selectedFilters.addAll(filters);
                
                // 적절한 ValueNotifier 업데이트
                if (selectedFilters == _selectedPOSFilters) {
                  _selectedPOSNotifier.value = Set.from(_selectedPOSFilters);
                } else if (selectedFilters == _selectedTypeFilters) {
                  _selectedTypeNotifier.value = Set.from(_selectedTypeFilters);
                }
              },
              child: Text(
                tr('actions.select_all_filter'),
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                print('🔧 PERF: Deselect all filters - no setState');
                selectedFilters.clear();
                
                // 적절한 ValueNotifier 업데이트
                if (selectedFilters == _selectedPOSFilters) {
                  _selectedPOSNotifier.value = Set.from(_selectedPOSFilters);
                } else if (selectedFilters == _selectedTypeFilters) {
                  _selectedTypeNotifier.value = Set.from(_selectedTypeFilters);
                }
              },
              child: Text(
                tr('actions.deselect_all_filter'),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((filter) {
            // 순수 필터 이름 추출 (개수 괄호 제거)
            final filterName = filter.split('(')[0];

            // 선택된 필터 중에서 같은 이름이 있는지 확인
            final isSelected = selectedFilters
                .any((selected) => selected.split('(')[0] == filterName);

            return GestureDetector(
              onTap: () {
                debugPrint('🔽 필터 버튼 클릭: $filter, 현재 선택됨: $isSelected');
                onFilterTap(filter);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF28A745) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF28A745)
                        : const Color(0xFF007BFF),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  '#$filter',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (selectedFilters.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Text(
                  tr('ui.selected_filters', namespace: 'home/filter'),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                ...selectedFilters.map((filter) {
                  // 순수 필터 이름만 추출 (개수 괄호 제거)
                  final filterName = filter.split('(')[0];

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F42C1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#$filterName',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => onFilterTap(filter),
                          child: const Icon(
                            Icons.close,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  // 위주 학습 설정 (라디오 버튼)
  Widget _buildStudyModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr('section.study_mode', namespace: 'home/study_status'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _showStudyModeHelp(),
              child: const Icon(Icons.help, size: 20, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadioOption('TargetVoca', tr('study_mode.target_voca', namespace: 'home/study_status')),
            const SizedBox(width: 32),
            _buildRadioOption('ReferenceVoca', tr('study_mode.reference_voca', namespace: 'home/study_status')),
            const SizedBox(width: 32),
            _buildRadioOption('Random', tr('study_mode.random_mode', namespace: 'home/study_status')),
          ],
        ),
      ],
    );
  }

  // 라디오 버튼 옵션
  Widget _buildRadioOption(String value, String label) {
    final isSelected = _studyMode == value;
    return InkWell(
      onTap: () {
        setState(() {
          _studyMode = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6B8E23), width: 2),
              color: isSelected ? const Color(0xFF6B8E23) : Colors.white,
            ),
            child: isSelected
                ? const Icon(Icons.circle, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // 학습 방법 선택
  Widget _buildStudyMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('section.learning_method', namespace: 'home/study_status'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStudyMethodButton(tr('learning_method.card_study', namespace: 'home/study_status'),
                    const Color(0xFF5A9FD4))), // 톤 다운된 파란색 - 기본 학습
            const SizedBox(width: 8),
            Expanded(
                child: _buildStudyMethodButton(tr('learning_method.favorite_review', namespace: 'home/study_status'),
                    const Color(0xFF52B788))), // 톤 다운된 초록색 - 즐겨찾기
            const SizedBox(width: 8),
            Expanded(
                child: _buildStudyMethodButton(tr('learning_method.game_study', namespace: 'home/study_status'),
                    const Color(0xFF8E7CC3))), // 톤 다운된 보라색 - 게임
            const SizedBox(width: 8),
            Expanded(
                child: _buildStudyMethodButton(tr('learning_method.wrong_word_study', namespace: 'home/study_status'),
                    const Color(0xFFE07A5F))), // 톤 다운된 주황색 - 틀린단어 (❌ 이모티콘과 구분)
          ],
        ),
      ],
    );
  }

  // 학습 방법 버튼
  Widget _buildStudyMethodButton(String text, Color color) {
    return InkWell(
      onTap: () => _handleStudyMethodTap(text),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, // 모든 버튼 흰색 텍스트
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // 학습 방법 버튼 탭 처리
  void _handleStudyMethodTap(String methodText) {
    // 선택된 어휘집이 있는지 확인
    if (_selectedVocabFiles.isEmpty) {
      _showNoVocabularySelectedDialog();
      return;
    }

    if (methodText == tr('learning_method.card_study', namespace: 'home/study_status')) {
      _startCardStudy();
    } else if (methodText == tr('learning_method.favorite_review', namespace: 'home/study_status')) {
      _startFavoriteReview();
    } else if (methodText == tr('learning_method.game_study', namespace: 'home/study_status')) {
      _showComingSoonDialog(tr('status.game_feature_coming_soon'));
    } else if (methodText == tr('learning_method.wrong_word_study', namespace: 'home/study_status')) {
      _showComingSoonDialog(tr('status.game_feature_coming_soon'));
    }
  }

  // 구현 예정 다이얼로그
  void _showComingSoonDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.construction, color: Colors.orange),
              const SizedBox(width: 8),
              Text(tr('status.coming_soon')),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('dialog.ok')),
            ),
          ],
        );
      },
    );
  }

  // 어휘집 미선택 알림 다이얼로그
  void _showNoVocabularySelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(tr('errors.no_vocab_selected_title', namespace: 'home/vocabulary_list')),
            ],
          ),
          content: Text(tr('errors.no_vocab_selected_message', namespace: 'home/vocabulary_list')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('dialog.ok')),
            ),
          ],
        );
      },
    );
  }

  // 기본 단어카드 학습 시작
  void _startCardStudy() async {
    final words = _getFilteredWordsForStudy();
    if (words.isEmpty) {
      _showNoWordsFoundDialog();
      return;
    }

    // 진행률 확인을 위한 세션 키 생성
    final posFilters = _selectedPOSFilters.map((filter) => filter.split('(')[0]).toList();
    final typeFilters = _selectedTypeFilters.map((filter) => filter.split('(')[0]).toList();
    
    final progressSessionKey = StudyProgressService.createSessionKey(
      vocabularyFiles: _selectedVocabFiles.toList(),
      studyMode: 'card',
      targetMode: _studyMode,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
    
    final progressService = StudyProgressService.instance;
    final existingProgress = progressService.getProgress(progressSessionKey);
    
    // 진행률이 있고 첫 번째도 마지막도 아닌 중간 지점이면 다이얼로그 표시
    if (existingProgress != null && !existingProgress.isAtStart && !existingProgress.isAtLastCard) {
      _showContinueStudyDialog(
        existingProgress, 
        words, 
        progressSessionKey, 
        StudyMode.cardStudy, 
        _selectedVocabFiles.toList(), 
        _studyMode, 
        posFilters, 
        typeFilters
      );
    } else {
      // 진행률이 없거나 첫 번째/마지막이면 바로 시작
      if (existingProgress != null && existingProgress.isAtLastCard) {
        progressService.clearProgress(progressSessionKey);
      }
      
      await _startStudySession(StudyMode.cardStudy, words, posFilters, typeFilters);
    }
  }

  // 학습 세션 시작 공통 함수
  Future<void> _startStudySession(StudyMode mode, List<VocabularyWord> words, List<String> posFilters, List<String> typeFilters) async {
    debugPrint('📚 학습 시작: ${mode.toString()}');
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/study'),
        builder: (context) => StudyScreen(
          key: StudyScreenController.key,
          mode: mode,
          words: words,
          vocabularyFiles: _selectedVocabFiles.toList(),
          studyModePreference: _studyMode,
          posFilters: posFilters,
          typeFilters: typeFilters,
        ),
      ),
    );

    // 학습 완료 후 돌아왔을 때 무조건 데이터 새로고침
    debugPrint('🏠 학습에서 홈으로 돌아옴');
    _forceRefreshData();
  }

  // 홈 화면에서 이어하기 다이얼로그 표시
  void _showContinueStudyDialog(StudyProgress progress, List<VocabularyWord> words, String progressSessionKey, StudyMode studyMode, List<String> vocabularyFiles, String targetMode, List<String> posFilters, List<String> typeFilters) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.play_circle_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Text(tr('continue_study.title', namespace: 'word_card')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('continue_study.message', namespace: 'word_card')),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 ${tr('continue_study.progress', namespace: 'word_card')}: ${progress.progressText}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('📅 ${tr('continue_study.last_study', namespace: 'word_card')}: ${_formatProgressDate(progress.lastStudyTime)}'),
                    if (progress.isShuffled)
                      Text('🔀 ${tr('continue_study.shuffled', namespace: 'word_card')}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 취소 - 아무것도 하지 않음
              },
              child: Text(tr('continue_study.cancel', namespace: 'word_card')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 처음부터 시작 (진행률 삭제)
                StudyProgressService.instance.clearProgress(progressSessionKey);
                await _startStudySession(studyMode, words, posFilters, typeFilters);
              },
              child: Text(tr('continue_study.start_over', namespace: 'word_card')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 이어하기 (진행률 복원)
                final progressService = StudyProgressService.instance;
                final orderedWords = progressService.restoreWordOrder(words, progress);
                
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: '/study'),
                    builder: (context) => StudyScreen(
                      key: StudyScreenController.key,
                      mode: studyMode,
                      words: orderedWords,
                      vocabularyFiles: vocabularyFiles,
                      studyModePreference: targetMode,
                      posFilters: posFilters,
                      typeFilters: typeFilters,
                    ),
                  ),
                );
                
                // 학습 완료 후 새로고침
                _forceRefreshData();
              },
              child: Text(tr('continue_study.continue', namespace: 'word_card')),
            ),
          ],
        );
      },
    );
  }

  // 진행률 날짜 포맷팅
  String _formatProgressDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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

  // 즐겨찾기 복습 시작
  void _startFavoriteReview() async {
    final words = _getFilteredWordsForStudy(favoritesOnly: true);
    if (words.isEmpty) {
      _showNoWordsFoundDialog(isFavorites: true);
      return;
    }

    // 진행률 확인을 위한 세션 키 생성
    final posFilters = _selectedPOSFilters.map((filter) => filter.split('(')[0]).toList();
    final typeFilters = _selectedTypeFilters.map((filter) => filter.split('(')[0]).toList();
    
    final progressSessionKey = StudyProgressService.createSessionKey(
      vocabularyFiles: _selectedVocabFiles.toList(),
      studyMode: 'favorites',
      targetMode: _studyMode,
      posFilters: posFilters,
      typeFilters: typeFilters,
    );
    
    final progressService = StudyProgressService.instance;
    final existingProgress = progressService.getProgress(progressSessionKey);
    
    // 진행률이 있고 첫 번째도 마지막도 아닌 중간 지점이면 다이얼로그 표시
    if (existingProgress != null && !existingProgress.isAtStart && !existingProgress.isAtLastCard) {
      _showContinueStudyDialog(
        existingProgress, 
        words, 
        progressSessionKey, 
        StudyMode.favoriteReview, 
        _selectedVocabFiles.toList(), 
        _studyMode, 
        posFilters, 
        typeFilters
      );
    } else {
      // 진행률이 없거나 첫 번째/마지막이면 바로 시작
      if (existingProgress != null && existingProgress.isAtLastCard) {
        progressService.clearProgress(progressSessionKey);
      }
      
      await _startStudySession(StudyMode.favoriteReview, words, posFilters, typeFilters);
    }
  }

  // 필터링된 단어 목록 가져오기 (학습용)
  List<VocabularyWord> _getFilteredWordsForStudy({bool favoritesOnly = false}) {
    // FilterService를 통해 필터링된 단어들 가져오기
    final selectedPosValues =
        _selectedPOSFilters.map((filter) => filter.split('(')[0]).toList();
    final selectedTypeValues =
        _selectedTypeFilters.map((filter) => filter.split('(')[0]).toList();

    return _filterService.getFilteredWords(
      vocabularyFiles: _selectedVocabFiles.toList(),
      posFilters: selectedPosValues.isNotEmpty ? selectedPosValues : null,
      typeFilters: selectedTypeValues.isNotEmpty ? selectedTypeValues : null,
      favoritesOnly: favoritesOnly,
    );
  }

  // 단어 없음 알림 다이얼로그
  void _showNoWordsFoundDialog({bool isFavorites = false}) {
    final title = isFavorites
        ? tr('errors.no_favorites_found_title', namespace: 'home/vocabulary_list')
        : tr('errors.no_words_found_title', namespace: 'home/vocabulary_list');
    final message = isFavorites
        ? tr('errors.no_favorites_found_message', namespace: 'home/vocabulary_list')
        : tr('errors.no_words_found_message', namespace: 'home/vocabulary_list');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('dialog.ok')),
            ),
          ],
        );
      },
    );
  }

  // 필터된 단어 카운트 메서드들 (서비스 사용)
  String _getFilteredWordCount() {
    final selectedFiles =
        _selectedVocabFiles.isNotEmpty ? _selectedVocabFiles.toList() : null;

    final count = _vocabularyService.getFilteredWordCount(
      vocabularyFiles: selectedFiles,
      posFilters: _selectedPOSFilters,
      typeFilters: _selectedTypeFilters,
    );
    return count.toString();
  }

  String _getFilteredFavoriteCount() {
    final selectedFiles =
        _selectedVocabFiles.isNotEmpty ? _selectedVocabFiles.toList() : null;

    final count = _vocabularyService.getFilteredFavoriteCount(
      vocabularyFiles: selectedFiles,
      posFilters: _selectedPOSFilters,
      typeFilters: _selectedTypeFilters,
    );
    return count.toString();
  }

  String _getFilteredWrongCount() {
    final selectedFiles =
        _selectedVocabFiles.isNotEmpty ? _selectedVocabFiles.toList() : null;

    final count = _vocabularyService.getFilteredWrongWordsCount(
      vocabularyFiles: selectedFiles,
      posFilters: _selectedPOSFilters,
      typeFilters: _selectedTypeFilters,
    );
    return count.toString();
  }

  String _getFilteredWrongCountTotal() {
    final selectedFiles =
        _selectedVocabFiles.isNotEmpty ? _selectedVocabFiles.toList() : null;

    final count = _vocabularyService.getFilteredWrongCountTotal(
      vocabularyFiles: selectedFiles,
      posFilters: _selectedPOSFilters,
      typeFilters: _selectedTypeFilters,
    );
    return count.toString();
  }

  // 위주 학습 설정 도움말
  void _showStudyModeHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('help.title', namespace: 'home/study_status')),
        content: SingleChildScrollView(
          child: Text(
            tr('help.content', namespace: 'home/study_status'),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('dialog.ok')),
          ),
        ],
      ),
    );
  }

}