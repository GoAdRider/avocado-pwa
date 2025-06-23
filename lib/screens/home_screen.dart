import 'package:flutter/material.dart';
import '../widgets/app_layout.dart';
import '../utils/strings/base_strings.dart';
import '../utils/strings/home_strings.dart';
import '../utils/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 상태 관리 변수들
  bool _isSelectionMode = false; // 최근 학습 기록 선택 모드
  bool _isVocabSingleSelect = true; // 어휘집 단일/다중 선택 모드

  // 선택된 항목들
  final Set<int> _selectedRecentRecords = {}; // 최근 학습 기록 선택
  Set<int> _selectedVocabSets = {}; // 어휘집 선택
  final Set<String> _selectedPOSFilters = {}; // 품사 필터 선택
  final Set<String> _selectedTypeFilters = {}; // 타입 필터 선택

  // 학습 모드 (라디오 버튼)
  String _studyMode = 'TargetVoca';

  // 어휘집 이름 편집 모드
  int _editingVocabIndex = -1;
  final TextEditingController _editController = TextEditingController();

  // 목표 설정 상태 변수들
  int _dailyNewWordsGoal = 20;
  int _dailyReviewWordsGoal = 10;
  int _dailyPerfectAnswersGoal = 12;
  int _weeklyGoal = 300;
  int _monthlyGoal = 1200;

  // 선택된 복습 타입을 추적하는 변수 추가 (클래스 상단에 추가할 변수)
  String _selectedReviewType = 'urgent'; // 기본값은 긴급 복습

  // 복습 데이터 맵
  Map<String, Map<String, String>> get _reviewData => {
        'urgent': {
          'emoji': '🔴',
          'title': HomeStrings.urgentReviewTitle,
          'count': '7${BaseStrings.wordsUnit}',
          'description': HomeStrings.urgentReviewDesc,
        },
        'recommended': {
          'emoji': '🟡',
          'title': HomeStrings.recommendedReviewTitle,
          'count': '12${BaseStrings.wordsUnit}',
          'description': HomeStrings.recommendedReviewDesc,
        },
        'preview': {
          'emoji': '🟢',
          'title': HomeStrings.previewReviewTitle,
          'count': '5${BaseStrings.wordsUnit}',
          'description': HomeStrings.previewReviewDesc,
        },
        'forgotten': {
          'emoji': '⚠️',
          'title': HomeStrings.forgottenReviewTitle,
          'count': '7${BaseStrings.wordsUnit}',
          'description': HomeStrings.forgottenReviewDesc,
        },
      };

  // 복습 타입별 색상 정보
  Map<String, Color> _getReviewColors(String reviewType) {
    switch (reviewType) {
      case 'urgent':
        return {
          'background': const Color(0xFFFFF5F5), // 매우 연한 로즈
          'border': const Color(0xFFEC4899), // 모던 핑크
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFFEC4899),
        };
      case 'recommended':
        return {
          'background': const Color(0xFFFEFCE8), // 매우 연한 골드
          'border': const Color(0xFFF59E0B), // 모던 앰버
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFFF59E0B),
        };
      case 'preview':
        return {
          'background': const Color(0xFFF0FDF4), // 매우 연한 에메랄드
          'border': const Color(0xFF10B981), // 모던 에메랄드
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFF10B981),
        };
      case 'forgotten':
        return {
          'background': const Color(0xFFFFF7ED), // 매우 연한 오렌지
          'border': const Color(0xFFEA580C), // 모던 오렌지
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFFEA580C),
        };
      default:
        return {
          'background': const Color(0xFFF8FAFC),
          'border': const Color(0xFF6366F1), // 모던 인디고
          'text': const Color(0xFF1F2937),
          'icon': const Color(0xFF6366F1),
        };
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LanguageProvider를 통해 언어 변경 감지
    LanguageProvider.of(context);

    return AppLayout(
      customQuote: BaseStrings.defaultQuote,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 24),
            _buildStudyStatus(),
            const SizedBox(height: 24),
            _buildSmartReview(),
            const SizedBox(height: 24),
            _buildRecentStudyRecords(),
            const SizedBox(height: 24),
            _buildVocabularySelection(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildStudyModeSelection(),
            const SizedBox(height: 24),
            _buildStudyMethodSelection(),
          ],
        ),
      ),
    );
  }

  // 제목 섹션
  Widget _buildTitle() {
    return Center(
      child: Text(
        HomeStrings.titleMain,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B8E23),
        ),
      ),
    );
  }

  // 나의 학습 현황
  Widget _buildStudyStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              HomeStrings.sectionStudyStatus,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // 오늘의 목표 링크버튼
            InkWell(
              onTap: () => _showTodaysGoalDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E23),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  HomeStrings.todaysGoal,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 상세통계 보기 링크버튼
            InkWell(
              onTap: () => print('상세통계 보기'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A2B8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  HomeStrings.detailedStats,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 통계 카드들
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalWords, '1,234${BaseStrings.wordsUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalFavorites, '45${BaseStrings.wordsUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalWrongWords, '0${BaseStrings.wordsUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalWrongCount, '0${BaseStrings.countUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(HomeStrings.averageAccuracy,
                    '85.2${BaseStrings.percentUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.studyStreak, '7${BaseStrings.daysUnit}')),
          ],
        ),
      ],
    );
  }

  // 통계 카드
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 스마트 복습
  Widget _buildSmartReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeStrings.smartReviewTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTabStyleReview(),
      ],
    );
  }

  // 새로운 탭 형태 복습 위젯
  Widget _buildTabStyleReview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // 좌측: 선택된 복습 항목 (큰 카드)
          Expanded(
            flex: 3,
            child: _buildMainReviewCard(_selectedReviewType),
          ),
          const SizedBox(width: 16),
          // 우측: 나머지 복습 항목들 (작은 탭들)
          Expanded(
            flex: 2,
            child: Column(
              children: _reviewData.entries
                  .where((entry) => entry.key != _selectedReviewType)
                  .map((entry) => _buildSmallReviewTab(entry.key, entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 메인 복습 카드 (좌측 큰 카드)
  Widget _buildMainReviewCard(String reviewType) {
    final data = _reviewData[reviewType]!;
    final colors = _getReviewColors(reviewType);
    final backgroundColor = colors['background']!;
    final borderColor = colors['border']!;
    final textColor = colors['text']!;

    return Material(
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: () => _handleReviewTap(reviewType),
        borderRadius: BorderRadius.circular(18),
        splashColor: borderColor.withOpacity(0.1),
        highlightColor: borderColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이모지와 제목
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        data['emoji']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['count']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 설명
              Text(
                data['description']!,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              // 시작 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      BaseStrings.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 작은 복습 탭 (우측 작은 탭들)
  Widget _buildSmallReviewTab(String reviewType, Map<String, String> data) {
    final colors = _getReviewColors(reviewType);
    final backgroundColor = colors['background']!;
    final borderColor = colors['border']!;
    final textColor = colors['text']!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedReviewType = reviewType;
            });
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: borderColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      data['emoji']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['count']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 14,
                    color: borderColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 복습 버튼 탭 처리
  void _handleReviewTap(String reviewType) {
    switch (reviewType) {
      case 'urgent':
        print('🔴 긴급 복습 시작 - 7개 단어');
        break;
      case 'recommended':
        print('🟡 권장 복습 시작 - 12개 단어');
        break;
      case 'preview':
        print('🟢 여유 복습 시작 - 5개 단어');
        break;
      case 'forgotten':
        print('⚠️ 망각 위험 단어 구조 시작 - 7개 단어');
        break;
    }
    // TODO: 실제 복습 화면으로 이동하는 로직 구현
  }

  // 최근 학습 기록
  Widget _buildRecentStudyRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              HomeStrings.sectionRecentStudy,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (!_isSelectionMode) ...[
              InkWell(
                onTap: () {
                  setState(() {
                    _isSelectionMode = true;
                    _selectedRecentRecords.clear();
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17A2B8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    HomeStrings.selectClear,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showDeleteAllDialog(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    HomeStrings.clearAll,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ] else ...[
              InkWell(
                onTap: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedRecentRecords.clear();
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C757D),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    BaseStrings.cancel,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _selectedRecentRecords.isEmpty
                    ? null
                    : () => _deleteSelectedRecords(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedRecentRecords.isEmpty
                        ? Colors.grey[400]
                        : const Color(0xFFDC3545),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    BaseStrings.confirmDelete,
                    style: TextStyle(
                        color: _selectedRecentRecords.isEmpty
                            ? Colors.grey[600]
                            : Colors.white,
                        fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              final isSelected = _selectedRecentRecords.contains(index);
              final items = ['TOPIK_4급 완성', 'TOPIK_5급 완성', 'Topik2 감정.csv'];
              final times = ['📅 2시간 전', '📅 1일 전', '📅 3일 전'];

              return Padding(
                padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                child: InkWell(
                  onTap: () {
                    if (_isSelectionMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedRecentRecords.remove(index);
                        } else {
                          _selectedRecentRecords.add(index);
                        }
                      });
                    } else {
                      print('${items[index]} 학습 재개');
                    }
                  },
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red[100] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? Colors.red : const Color(0xFFE0E0E0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                items[index],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _editRecordName(index, items[index]),
                              child: const Text('✏️',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          times[index],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 어휘집 선택
  Widget _buildVocabularySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              HomeStrings.sectionVocabSelection,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _showVocabSelectionHelp(),
              child: const Text(' ❓', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 선택된 어휘집 정보 표시
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            HomeStrings.selectedVocabInfo(
                count: int.parse(_getSelectedVocabCount()),
                favorites: 112,
                wrong: 0,
                wrongCount: 0),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        // 컨트롤 버튼들
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isVocabSingleSelect = !_isVocabSingleSelect;
                  if (_isVocabSingleSelect && _selectedVocabSets.length > 1) {
                    final first = _selectedVocabSets.first;
                    _selectedVocabSets.clear();
                    _selectedVocabSets.add(first);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isVocabSingleSelect
                      ? const Color(0xFF28A745)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _isVocabSingleSelect
                      ? HomeStrings.singleSelect
                      : HomeStrings.multiSelect,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _isVocabSingleSelect = false;
                  _selectedVocabSets = {0, 1, 2, 3, 4, 5};
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A2B8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  BaseStrings.selectAll,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedVocabSets.clear();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  BaseStrings.deselectAll,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            InkWell(
              onTap: _selectedVocabSets.isNotEmpty
                  ? () => _showDeleteVocabDialog()
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedVocabSets.isNotEmpty
                      ? const Color(0xFFDC3545)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  BaseStrings.delete,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            InkWell(
              onTap: _selectedVocabSets.isNotEmpty ? () => print('내보내기') : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedVocabSets.isNotEmpty
                      ? const Color(0xFF6B8E23)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  BaseStrings.export,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            InkWell(
              onTap: _selectedVocabSets.isNotEmpty
                  ? () => _showResetWrongCountDialog()
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedVocabSets.isNotEmpty
                      ? const Color(0xFFFFC107)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  HomeStrings.resetWrongCount,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            InkWell(
              onTap: _selectedVocabSets.isNotEmpty
                  ? () => _showResetFavoriteDialog()
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedVocabSets.isNotEmpty
                      ? const Color(0xFF9ACD32)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  HomeStrings.resetFavorites,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          HomeStrings.vocabInfoGuide,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        // 어휘집 카드들 (6열 그리드)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            _buildAddVocabCard(),
            ..._buildVocabCards(),
          ],
        ),
      ],
    );
  }

  // 새 어휘집 추가 카드
  Widget _buildAddVocabCard() {
    return InkWell(
      onTap: () => _pickCSVFile(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('➕', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              HomeStrings.addNewVocab,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 어휘집 카드들
  List<Widget> _buildVocabCards() {
    final vocabSets = [
      {
        'name': 'TOPIK_4급완성',
        'words': '1234',
        'favorites': '45',
        'wrong': '0',
        'wrongCount': '0',
        'date': '2시간 전'
      },
      {
        'name': 'TOPIK_5급완성',
        'words': '567',
        'favorites': '23',
        'wrong': '0',
        'wrongCount': '0',
        'date': '1일 전'
      },
      {
        'name': 'TOPIK_6급완성',
        'words': '890',
        'favorites': '67',
        'wrong': '0',
        'wrongCount': '0',
        'date': '없음'
      },
      {
        'name': 'Topik2 감정.csv',
        'words': '123',
        'favorites': '12',
        'wrong': '0',
        'wrongCount': '0',
        'date': '3일 전'
      },
      {
        'name': 'Topik2 종합어휘',
        'words': '456',
        'favorites': '34',
        'wrong': '0',
        'wrongCount': '0',
        'date': '1주 전'
      },
    ];

    return List.generate(vocabSets.length, (index) {
      final isSelected = _selectedVocabSets.contains(index);
      final vocab = vocabSets[index];
      final isEditing = _editingVocabIndex == index;

      return InkWell(
        onTap: () {
          setState(() {
            if (_isVocabSingleSelect) {
              _selectedVocabSets.clear();
              _selectedVocabSets.add(index);
            } else {
              if (isSelected) {
                _selectedVocabSets.remove(index);
              } else {
                _selectedVocabSets.add(index);
              }
            }
          });
        },
        child: Container(
          height: 140, // 카드 높이 고정
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // 제목 영역 (중앙 정렬)
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: isEditing
                          ? Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _editController,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    onSubmitted: (value) =>
                                        _saveVocabName(index, value),
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _cancelVocabEdit(),
                                  child: const Text('❌',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _saveVocabName(
                                      index, _editController.text),
                                  child: const Text('✅',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ],
                            )
                          : Text(
                              vocab['name']!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                    ),
                    if (!isEditing)
                      InkWell(
                        onTap: () => _editVocabName(index, vocab['name']!),
                        child: const Text('✏️', style: TextStyle(fontSize: 14)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 2x2 정보 그리드
              Expanded(
                child: Column(
                  children: [
                    // 첫 번째 줄: 📝 단어수, ⭐ 즐겨찾기
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '📝 ${vocab['words']}개',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '⭐ ${vocab['favorites']}개',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 두 번째 줄: ❌ 틀린단어, 🔢 틀린횟수
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '❌ ${vocab['wrong']}개',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '🔢 ${vocab['wrongCount']}회',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 날짜 정보 (하단 중앙)
              Text(
                '📅 ${vocab['date']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  // 필터 섹션
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              HomeStrings.sectionPosTypeFilter,
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
                HomeStrings.filteredWords(
                    words: int.parse(_getFilteredWordCount()),
                    favorites: int.parse(_getFilteredFavoriteCount()),
                    wrong: int.parse(_getFilteredWrongCount()),
                    wrongCount: int.parse(_getFilteredWrongCountTotal())),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 품사 필터
        _buildFilterSection(
          HomeStrings.posFilter,
          ['명사(45)', '동사(23)', '형용사(12)', '부사(8)', '기타(5)'],
          _selectedPOSFilters,
          (filter) {
            setState(() {
              if (_selectedPOSFilters.contains(filter)) {
                _selectedPOSFilters.remove(filter);
              } else {
                _selectedPOSFilters.add(filter);
              }
            });
          },
        ),
        const SizedBox(height: 16),
        // 타입 필터
        _buildFilterSection(
          HomeStrings.typeFilter,
          ['기본어휘(78)', '고급어휘(34)', '관용구(12)', '속담(5)'],
          _selectedTypeFilters,
          (filter) {
            setState(() {
              if (_selectedTypeFilters.contains(filter)) {
                _selectedTypeFilters.remove(filter);
              } else {
                _selectedTypeFilters.add(filter);
              }
            });
          },
        ),
      ],
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
                setState(() {
                  selectedFilters.addAll(filters);
                });
              },
              child: Text(
                BaseStrings.selectAllFilter,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  selectedFilters.clear();
                });
              },
              child: Text(
                BaseStrings.deselectAllFilter,
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
            final isSelected = selectedFilters.contains(filter);
            return InkWell(
              onTap: () => onFilterTap(filter),
              onHover: (isHovering) {
                // 호버 효과는 웹에서만 작동
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
                  HomeStrings.selectedFilters,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                ...selectedFilters.map((filter) {
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
                          '#$filter',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => onFilterTap(filter),
                          child: const Text(
                            '❌',
                            style: TextStyle(fontSize: 10, color: Colors.white),
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
              HomeStrings.sectionStudyMode,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _showStudyModeHelp(),
              child: const Text(' ❓', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadioOption('TargetVoca', HomeStrings.targetVoca),
            const SizedBox(width: 32),
            _buildRadioOption('ReferenceVoca', HomeStrings.referenceVoca),
            const SizedBox(width: 32),
            _buildRadioOption('Random', HomeStrings.randomMode),
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
          HomeStrings.sectionLearningMethod,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStudyMethodButton(HomeStrings.cardStudy,
                    const Color(0xFF5A9FD4))), // 톤 다운된 파란색 - 기본 학습
            const SizedBox(width: 8),
            Expanded(
                child: _buildStudyMethodButton(HomeStrings.favoriteReview,
                    const Color(0xFF52B788))), // 톤 다운된 초록색 - 즐겨찾기
            const SizedBox(width: 8),
            Expanded(
                child: _buildStudyMethodButton(HomeStrings.gameStudy,
                    const Color(0xFF8E7CC3))), // 톤 다운된 보라색 - 게임
            const SizedBox(width: 8),
            Expanded(
                child: _buildStudyMethodButton(HomeStrings.wrongWordStudy,
                    const Color(0xFFE07A5F))), // 톤 다운된 주황색 - 틀린단어 (❌ 이모티콘과 구분)
          ],
        ),
      ],
    );
  }

  // 학습 방법 버튼
  Widget _buildStudyMethodButton(String text, Color color) {
    return InkWell(
      onTap: () => print('$text 선택'),
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

  // 유틸리티 메서드들
  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.clearAllTitle),
        content: Text(HomeStrings.clearAllMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('전체 삭제 실행');
            },
            child: Text(BaseStrings.yes,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedRecords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.deleteSelectedTitle),
        content: Text(
            HomeStrings.deleteSelectedMessage(_selectedRecentRecords.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('선택된 기록 삭제: $_selectedRecentRecords');
              setState(() {
                _selectedRecentRecords.clear();
                _isSelectionMode = false;
              });
            },
            child: Text(BaseStrings.confirmDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editRecordName(int index, String currentName) {
    _editController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.editNameTitle),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(labelText: HomeStrings.editNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('${_editController.text}로 이름 변경');
            },
            child: Text(BaseStrings.ok),
          ),
        ],
      ),
    );
  }

  void _editVocabName(int index, String currentName) {
    setState(() {
      _editingVocabIndex = index;
      _editController.text = currentName;
    });
  }

  void _saveVocabName(int index, String newName) {
    setState(() {
      _editingVocabIndex = -1;
    });
    print('어휘집 $index 이름을 $newName으로 변경');
  }

  void _cancelVocabEdit() {
    setState(() {
      _editingVocabIndex = -1;
    });
  }

  String _getSelectedVocabCount() {
    return _selectedVocabSets.length.toString();
  }

  // 필터된 단어 카운트 메서드들
  String _getFilteredWordCount() {
    // 임시로 기본값 반환 (나중에 실제 필터링 로직 구현)
    int baseCount = 2457; // 선택된 어휘집들의 총 단어 수
    if (_selectedPOSFilters.isEmpty && _selectedTypeFilters.isEmpty) {
      return baseCount.toString();
    }
    // 필터가 적용된 경우 감소된 수를 반환
    return (baseCount * 0.7).round().toString(); // 임시 계산
  }

  String _getFilteredFavoriteCount() {
    int baseCount = 112;
    if (_selectedPOSFilters.isEmpty && _selectedTypeFilters.isEmpty) {
      return baseCount.toString();
    }
    return (baseCount * 0.6).round().toString();
  }

  String _getFilteredWrongCount() {
    // 현재는 틀린 단어가 0개
    return "0";
  }

  String _getFilteredWrongCountTotal() {
    // 현재는 틀린 횟수가 0회
    return "0";
  }

  // 어휘집 삭제 확인 다이얼로그
  void _showDeleteVocabDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.deleteVocabTitle),
        content:
            Text(HomeStrings.deleteVocabMessage(_selectedVocabSets.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('어휘집 ${_selectedVocabSets.length}개 삭제 실행');
              setState(() {
                _selectedVocabSets.clear();
              });
            },
            child: Text(BaseStrings.confirmDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 틀린횟수 초기화 확인 다이얼로그
  void _showResetWrongCountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.resetWrongCountTitle),
        content:
            Text(HomeStrings.resetWrongCountMessage(_selectedVocabSets.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('틀린횟수 초기화 실행');
            },
            child: Text(BaseStrings.confirmReset,
                style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  // 즐겨찾기 초기화 확인 다이얼로그
  void _showResetFavoriteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.resetFavoritesTitle),
        content:
            Text(HomeStrings.resetFavoritesMessage(_selectedVocabSets.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('즐겨찾기 초기화 실행');
            },
            child: Text(BaseStrings.confirmReset,
                style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // CSV 파일 선택
  void _pickCSVFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.addVocabTitle),
        content: Text(HomeStrings.addVocabMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('CSV 파일 선택 실행');
              // TODO: 실제 파일 선택 구현
            },
            child: Text(BaseStrings.fileSelect,
                style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // 어휘집 선택 도움말
  void _showVocabSelectionHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.vocabSelectionHelpTitle),
        content: SingleChildScrollView(
          child: Text(
            HomeStrings.vocabSelectionHelpContent,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.ok),
          ),
        ],
      ),
    );
  }

  // 위주 학습 설정 도움말
  void _showStudyModeHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.studyModeHelpTitle),
        content: SingleChildScrollView(
          child: Text(
            HomeStrings.studyModeHelpContent,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(BaseStrings.ok),
          ),
        ],
      ),
    );
  }

  // 오늘의 목표 다이얼로그
  void _showTodaysGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.todaysGoalTitle),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 목표 달성도 섹션
                Text(
                  HomeStrings.goalProgressTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 신규학습 프로그레스
                _buildGoalProgress(
                  label: HomeStrings.newWordsGoal,
                  current: 16,
                  target: _dailyNewWordsGoal,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),

                // 복습완료 프로그레스
                _buildGoalProgress(
                  label: HomeStrings.reviewWordsGoal,
                  current: 6,
                  target: _dailyReviewWordsGoal,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),

                // 완벽정답 프로그레스
                _buildGoalProgress(
                  label: HomeStrings.perfectAnswersGoal,
                  current: 12,
                  target: _dailyPerfectAnswersGoal,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                // 오늘의 요약
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HomeStrings.todaysSummary(
                          newWords: 16,
                          reviewWords: 6,
                          totalWords: 22,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        HomeStrings.streakInfo(
                          current: 5,
                          best: 12,
                          next: 6,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        HomeStrings.weeklyProgress(
                          current: 89,
                          target: _weeklyGoal,
                          percent: ((89 / _weeklyGoal) * 100).round(),
                        ),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.purple),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        HomeStrings.monthlyProgress(
                          current: 267,
                          target: _monthlyGoal,
                          percent: ((267 / _monthlyGoal) * 100).round(),
                        ),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showGoalSettingsDialog();
            },
            child: Text(HomeStrings.goalSettings),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(HomeStrings.goalClose),
          ),
        ],
      ),
    );
  }

  // 목표 프로그레스 위젯
  Widget _buildGoalProgress({
    required String label,
    required int current,
    required int target,
    required Color color,
  }) {
    double progress = current / target;
    int percent = (progress * 100).round();
    bool isCompleted = current >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: $current/$target${BaseStrings.wordsUnit} ($percent%)',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              isCompleted
                  ? HomeStrings.goalCompleted
                  : HomeStrings.goalAchievementMessage(target - current),
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress > 1.0 ? 1.0 : progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            isCompleted ? Colors.green : color,
          ),
        ),
      ],
    );
  }

  // 목표 설정 다이얼로그
  void _showGoalSettingsDialog() {
    // 현재 목표값들을 임시 변수로 복사
    int tempDailyNewWords = _dailyNewWordsGoal;
    int tempDailyReviewWords = _dailyReviewWordsGoal;
    int tempDailyPerfectAnswers = _dailyPerfectAnswersGoal;
    int tempWeeklyGoal = _weeklyGoal;
    int tempMonthlyGoal = _monthlyGoal;

    // TextEditingController들 생성
    final newWordsController =
        TextEditingController(text: tempDailyNewWords.toString());
    final reviewWordsController =
        TextEditingController(text: tempDailyReviewWords.toString());
    final perfectAnswersController =
        TextEditingController(text: tempDailyPerfectAnswers.toString());
    final weeklyController =
        TextEditingController(text: tempWeeklyGoal.toString());
    final monthlyController =
        TextEditingController(text: tempMonthlyGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(HomeStrings.goalSettingsTitle),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 일일 목표 섹션
                Text(
                  HomeStrings.dailyGoalSection,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 일일 신규 학습 목표
                _buildGoalInput(
                  label: HomeStrings.dailyNewWords,
                  controller: newWordsController,
                  onChanged: (value) {
                    tempDailyNewWords =
                        int.tryParse(value) ?? tempDailyNewWords;
                  },
                ),
                const SizedBox(height: 8),

                // 일일 복습 완료 목표
                _buildGoalInput(
                  label: HomeStrings.dailyReviewWords,
                  controller: reviewWordsController,
                  onChanged: (value) {
                    tempDailyReviewWords =
                        int.tryParse(value) ?? tempDailyReviewWords;
                  },
                ),
                const SizedBox(height: 8),

                // 일일 완벽 정답 목표
                _buildGoalInput(
                  label:
                      '${HomeStrings.dailyPerfectAnswers}\n${HomeStrings.perfectAnswersDesc}',
                  controller: perfectAnswersController,
                  onChanged: (value) {
                    tempDailyPerfectAnswers =
                        int.tryParse(value) ?? tempDailyPerfectAnswers;
                  },
                ),
                const SizedBox(height: 16),

                // 주간/월간 목표 섹션
                Text(
                  HomeStrings.weeklyGoalLabel,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 주간 목표
                _buildGoalInput(
                  label:
                      '${HomeStrings.weeklyGoalLabel}\n${HomeStrings.weeklyMonthlyGoalDesc}',
                  controller: weeklyController,
                  onChanged: (value) {
                    tempWeeklyGoal = int.tryParse(value) ?? tempWeeklyGoal;
                  },
                ),
                const SizedBox(height: 8),

                // 월간 목표
                _buildGoalInput(
                  label:
                      '${HomeStrings.monthlyGoalLabel}\n${HomeStrings.weeklyMonthlyGoalDesc}',
                  controller: monthlyController,
                  onChanged: (value) {
                    tempMonthlyGoal = int.tryParse(value) ?? tempMonthlyGoal;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Controller들 정리
              newWordsController.dispose();
              reviewWordsController.dispose();
              perfectAnswersController.dispose();
              weeklyController.dispose();
              monthlyController.dispose();
              Navigator.pop(context);
            },
            child: Text(BaseStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              // 입력 유효성 검사
              if (tempDailyNewWords < 1 ||
                  tempDailyReviewWords < 1 ||
                  tempDailyPerfectAnswers < 1 ||
                  tempWeeklyGoal < 1 ||
                  tempMonthlyGoal < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(HomeStrings.goalValidationError),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 목표값들 저장
              setState(() {
                _dailyNewWordsGoal = tempDailyNewWords;
                _dailyReviewWordsGoal = tempDailyReviewWords;
                _dailyPerfectAnswersGoal = tempDailyPerfectAnswers;
                _weeklyGoal = tempWeeklyGoal;
                _monthlyGoal = tempMonthlyGoal;
              });

              // Controller들 정리
              newWordsController.dispose();
              reviewWordsController.dispose();
              perfectAnswersController.dispose();
              weeklyController.dispose();
              monthlyController.dispose();

              Navigator.pop(context);

              // 성공 메시지
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(BaseStrings.saveSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(HomeStrings.goalSave,
                style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // 목표 입력 필드 위젯
  Widget _buildGoalInput({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixText: HomeStrings.goalUnitWords,
              suffixStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
