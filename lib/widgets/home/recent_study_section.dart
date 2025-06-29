import 'package:flutter/material.dart';
import '../../services/home/recent_study/recent_study_service.dart';
import '../../services/common/hive_service.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../../models/vocabulary_word.dart';
import '../../screens/study_screen.dart';
import '../../services/home/filter/filter_service.dart';

class RecentStudySection extends StatefulWidget {
  final Function? onStudyCompleted; // 학습 완료 시 콜백
  final Set<String> selectedPOSFilters; // 현재 선택된 품사 필터
  final Set<String> selectedTypeFilters; // 현재 선택된 어휘 타입 필터
  final String studyMode; // 현재 위주 학습 설정

  const RecentStudySection({
    super.key,
    this.onStudyCompleted,
    this.selectedPOSFilters = const {},
    this.selectedTypeFilters = const {},
    this.studyMode = 'TargetVoca',
  });

  @override
  State<RecentStudySection> createState() => RecentStudySectionState();
}

// Global key를 통해 외부에서 새로고침 가능하도록 하는 static 메서드
class RecentStudySectionController {
  static final GlobalKey<RecentStudySectionState> _key = GlobalKey<RecentStudySectionState>();
  
  static GlobalKey<RecentStudySectionState> get key => _key;
  
  static void refresh() {
    _key.currentState?._loadRecentStudyRecords();
  }
}

class RecentStudySectionState extends State<RecentStudySection> {
  final RecentStudyService _recentStudyService = RecentStudyService.instance;

  // 상태 변수들
  bool _isSelectionMode = false;
  final Set<int> _selectedRecentRecords = {};
  final List<RecentStudyInfo> _recentStudyRecords = [];
  final TextEditingController _editController = TextEditingController();

  // 현재 설정들은 widget에서 전달받음

  @override
  void initState() {
    super.initState();
    _loadRecentStudyRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🔄 RecentStudySection didChangeDependencies 호출 - 새로고침');
    // 화면이 다시 보여질 때마다 최근 학습 기록 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecentStudyRecords();
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  /// 최근 학습 기록 불러오기
  void _loadRecentStudyRecords() async {
    try {
      final recentRecords =
          await _recentStudyService.getRecentStudyRecords(maxCount: 10);
      setState(() {
        _recentStudyRecords.clear();
        _recentStudyRecords.addAll(recentRecords);
      });
    } catch (e) {
      debugPrint('최근 학습 기록 로드 실패: $e');
    }
  }

  /// 학습 재개 (최근학습기록 카드 클릭 시) - 필터 적용 및 다중 어휘집 지원
  void _resumeStudy(RecentStudyInfo info) async {
    try {
      // getResumeConfig에서 StudyMode 가져오기
      final config = _recentStudyService.getResumeConfig(info);
      final studyMode = config['studyMode'] as StudyMode;
      final targetMode = config['targetMode'] as String;

      // 다중 어휘집 처리
      List<String> vocabularyFiles;
      if (info.vocabularyFile.contains(',')) {
        vocabularyFiles = info.vocabularyFile.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
      } else {
        vocabularyFiles = [info.vocabularyFile];
      }

      debugPrint('📚 학습 재개 시작: $vocabularyFiles');
      debugPrint('📚 필터 - 품사: ${info.posFilters}, 타입: ${info.typeFilters}');

      // 필터 정보 처리 (UI 형태에서 실제 값만 추출)
      List<String>? posFilters;
      List<String>? typeFilters;
      
      if (info.posFilters.isNotEmpty) {
        posFilters = info.posFilters.map((filter) => filter.split('(')[0].trim()).toList();
      }
      
      if (info.typeFilters.isNotEmpty) {
        typeFilters = info.typeFilters.map((filter) => filter.split('(')[0].trim()).toList();
      }

      // 학습 모드에 따라 적절한 단어 목록 가져오기 (필터 적용)
      List<VocabularyWord> words;
      final filterService = FilterService.instance;

      switch (studyMode) {
        case StudyMode.favoriteReview:
          // 즐겨찾기 단어만 가져오기 (필터 적용)
          words = filterService.getFilteredWords(
            vocabularyFiles: vocabularyFiles,
            posFilters: posFilters,
            typeFilters: typeFilters,
            favoritesOnly: true,
          );
          debugPrint('📚 즐겨찾기 학습 재개: ${words.length}개 단어');
          break;

        case StudyMode.wrongWordsStudy:
          // 틀린 단어만 가져오기 (필터 적용)
          words = _getWrongWordsForStudy(vocabularyFiles, posFilters, typeFilters);
          debugPrint('📚 틀린단어 학습 재개: ${words.length}개 단어');
          break;

        case StudyMode.urgentReview:
        case StudyMode.recommendedReview:
        case StudyMode.leisureReview:
        case StudyMode.forgettingRisk:
          // 복습 대상 단어만 가져오기 (필터 적용)
          words = _getReviewWordsForStudy(vocabularyFiles, posFilters, typeFilters, info.studyMode);
          debugPrint('📚 ${info.studyMode} 학습 재개: ${words.length}개 단어');
          break;

        case StudyMode.cardStudy:
          // 일반 단어카드 학습 (필터 적용)
          words = filterService.getFilteredWords(
            vocabularyFiles: vocabularyFiles,
            posFilters: posFilters,
            typeFilters: typeFilters,
            favoritesOnly: false,
          );
          debugPrint('📚 일반 학습 재개: ${words.length}개 단어');
          break;
      }

      if (words.isEmpty) {
        _showNoWordsFoundDialog();
        return;
      }

      debugPrint('📚 학습 재개: ${info.vocabularyFile} (${studyMode.toString()})');

      // 학습 화면으로 이동
      await Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/study'),
          builder: (context) => StudyScreen(
            key: StudyScreenController.key,
            mode: studyMode,
            words: words,
            vocabularyFiles: vocabularyFiles,
            studyModePreference: targetMode,
            posFilters: posFilters ?? [],
            typeFilters: typeFilters ?? [],
          ),
        ),
      );

      // 학습 완료 후 돌아왔을 때 데이터 새로고침
      debugPrint('🏠 학습에서 돌아옴 - 최근학습기록 새로고침');
      _loadRecentStudyRecords();

      // 부모에게 알림
      if (widget.onStudyCompleted != null) {
        widget.onStudyCompleted!();
      }
    } catch (e) {
      debugPrint('학습 재개 실패: $e');
      _showErrorDialog('학습 재개 실패', '해당 어휘집을 불러올 수 없습니다.\n오류: $e');
    }
  }

  void _showNoWordsFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('학습할 단어 없음'),
          ],
        ),
        content: const Text('선택한 조건에 맞는 학습할 단어가 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('dialog.ok')),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
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
      ),
    );
  }

  /// 최근 학습 기록 툴팁 메시지 생성
  String _buildRecentStudyTooltipMessage(RecentStudyInfo info) {
    return _recentStudyService.buildRecentStudyTooltipMessage(
      info,
      currentStudyMode: widget.studyMode,
      selectedPOSFilters: widget.selectedPOSFilters,
      selectedTypeFilters: widget.selectedTypeFilters,
    );
  }

  /// 틀린단어 목록 가져오기 (필터 적용)
  List<VocabularyWord> _getWrongWordsForStudy(List<String> vocabularyFiles, List<String>? posFilters, List<String>? typeFilters) {
    final List<VocabularyWord> result = [];
    final hiveService = HiveService.instance;
    
    for (final vocabularyFile in vocabularyFiles) {
      // 해당 어휘집의 틀린단어 통계 가져오기
      final wrongWordStats = hiveService.getWrongWords(vocabularyFile: vocabularyFile);
      final wrongWordIds = wrongWordStats.map((stats) => stats.wordId).toSet();
      
      if (wrongWordIds.isEmpty) continue;
      
      // 해당 어휘집의 모든 단어 가져오기
      final allWords = hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
      
      // 틀린단어 중에서 필터 조건에 맞는 단어만 필터링
      for (final word in allWords) {
        // 틀린단어가 아니면 제외
        if (!wrongWordIds.contains(word.id)) continue;
        
        // 품사 필터 체크
        bool matchesPos = true;
        if (posFilters != null && posFilters.isNotEmpty) {
          final wordPos = (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : FilterService.noPosInfo;
          matchesPos = posFilters.contains(wordPos);
        }
        
        // 타입 필터 체크
        bool matchesType = true;
        if (typeFilters != null && typeFilters.isNotEmpty) {
          final wordType = (word.type != null && word.type!.isNotEmpty) ? word.type! : FilterService.noTypeInfo;
          matchesType = typeFilters.contains(wordType);
        }
        
        if (matchesPos && matchesType) {
          result.add(word);
        }
      }
    }
    
    return result;
  }

  /// 복습 대상 단어 목록 가져오기 (필터 적용)
  List<VocabularyWord> _getReviewWordsForStudy(List<String> vocabularyFiles, List<String>? posFilters, List<String>? typeFilters, String reviewType) {
    final List<VocabularyWord> result = [];
    final hiveService = HiveService.instance;
    final now = DateTime.now();
    
    for (final vocabularyFile in vocabularyFiles) {
      // 해당 어휘집의 단어 통계 가져오기
      final allWordStats = hiveService.wordStatsBox.values
          .where((stats) => stats.vocabularyFile == vocabularyFile && stats.lastStudyDate != null)
          .toList();
      
      if (allWordStats.isEmpty) continue;
      
      // 해당 어휘집의 모든 단어 가져오기
      final allWords = hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
      final wordMap = {for (var word in allWords) word.id: word};
      
      // 복습 타입별로 필터링
      Set<String> reviewWordIds = {};
      
      for (final stats in allWordStats) {
        final daysSinceLastStudy = now.difference(stats.lastStudyDate!).inDays;
        bool needsReview = false;
        
        switch (reviewType) {
          case 'urgent_review':
            final totalAttempts = stats.correctCount + stats.wrongCount;
            final accuracy = totalAttempts > 0 ? (stats.correctCount / totalAttempts) : 0.0;
            needsReview = daysSinceLastStudy >= 7 && accuracy < 0.6;
            break;
          case 'recommended_review':
            needsReview = daysSinceLastStudy >= 3 && daysSinceLastStudy < 7;
            break;
          case 'leisure_review':
            final totalAttempts2 = stats.correctCount + stats.wrongCount;
            final accuracy2 = totalAttempts2 > 0 ? (stats.correctCount / totalAttempts2) : 0.0;
            needsReview = daysSinceLastStudy >= 1 && daysSinceLastStudy < 3 && accuracy2 >= 0.8;
            break;
          case 'forgetting_risk':
            needsReview = daysSinceLastStudy >= 10 && stats.wrongCount > stats.correctCount;
            break;
        }
        
        if (needsReview) {
          reviewWordIds.add(stats.wordId);
        }
      }
      
      // 필터 조건에 맞는 복습 대상 단어만 필터링
      for (final wordId in reviewWordIds) {
        final word = wordMap[wordId];
        if (word == null) continue;
        
        // 품사 필터 체크
        bool matchesPos = true;
        if (posFilters != null && posFilters.isNotEmpty) {
          final wordPos = (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : FilterService.noPosInfo;
          matchesPos = posFilters.contains(wordPos);
        }
        
        // 타입 필터 체크
        bool matchesType = true;
        if (typeFilters != null && typeFilters.isNotEmpty) {
          final wordType = (word.type != null && word.type!.isNotEmpty) ? word.type! : FilterService.noTypeInfo;
          matchesType = typeFilters.contains(wordType);
        }
        
        if (matchesPos && matchesType) {
          result.add(word);
        }
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageNotifier.instance,
      builder: (context, _) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('section.title', namespace: 'home/recent_study'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recentStudyRecords.isNotEmpty) ...[
                Row(
                  children: [
                    if (!_isSelectionMode) ...[
                      // 선택지우기 버튼
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSelectionMode = true;
                            _selectedRecentRecords.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF28A745),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tr('actions.select_clear', namespace: 'home/recent_study'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 전체지우기 버튼
                      InkWell(
                        onTap: _showDeleteAllDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC3545),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tr('actions.clear_all', namespace: 'home/recent_study'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ] else ...[
                      // 선택 모드일 때 취소 버튼
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSelectionMode = false;
                            _selectedRecentRecords.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tr('actions.cancel_selection', namespace: 'home/recent_study'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      if (_selectedRecentRecords.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        // 선택된 항목 삭제 버튼
                        InkWell(
                          onTap: _deleteSelectedRecords,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC3545),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tr('dialog.confirm_delete'),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),


        // 최근 학습 기록 목록
        if (_recentStudyRecords.isEmpty)
          _buildEmptyRecentRecords()
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recentStudyRecords.length,
              itemBuilder: (context, index) {
                final info = _recentStudyRecords[index];
                return _buildRecentStudyCard(info, index);
              },
            ),
          ),
      ],
        );
      },
    );
  }

  Widget _buildEmptyRecentRecords() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 6),
            Text(
              tr('status.no_recent_study', namespace: 'home/recent_study'),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              tr('status.start_study_to_see_records', namespace: 'home/recent_study'),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStudyCard(RecentStudyInfo info, int index) {
    final isSelected = _selectedRecentRecords.contains(index);

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? const Color(0xFFE53E3E) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
          ),
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
                _resumeStudy(info);
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                setState(() {
                  _isSelectionMode = true;
                  _selectedRecentRecords.add(index);
                });
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Tooltip(
              message: _buildRecentStudyTooltipMessage(info),
              waitDuration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 첫 번째 줄: 학습 모드
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStudyModeColor(info.studyModeText, isSelected),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStudyModeDisplayText(info.studyModeText),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),

                    // 두 번째 줄: 어휘집명과 편집 버튼
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            info.vocabularyFile.replaceAll('.csv', ''),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFFE53E3E)
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_isSelectionMode)
                          GestureDetector(
                            onTap: () {
                              debugPrint('✏️ 어휘집 이름 편집 버튼 클릭');
                              _startEditingVocabularyName(info);
                            },
                            child: Text(
                              '✏️',
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? const Color(0xFFE53E3E)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),

                    // 세 번째 줄: 마지막 학습 시간
                    Center(
                      child: Text(
                        '📅 ${_formatDate(info.lastStudyDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFFE53E3E)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 학습 모드별 색상 반환
  Color _getStudyModeColor(String studyModeText, bool isSelected) {
    if (isSelected) {
      return const Color(0xFFE53E3E);
    }
    
    switch (studyModeText) {
      case '단어카드':
        return const Color(0xFF3B82F6); // 파란색 (학습방법 선택 버튼 색상과 통일)
      case '즐겨찾기':
        return const Color(0xFF10B981); // 에메랄드 (학습방법 선택 버튼 색상과 통일)
      case '틀린단어':
        return const Color(0xFFEF4444); // 빨간색 (학습방법 선택 버튼 색상과 통일)
      case '긴급복습':
        return const Color(0xFFEC4899); // 모던 핑크 (망각곡선 섹션과 동일)
      case '권장복습':
        return const Color(0xFFF59E0B); // 모던 앰버 (망각곡선 섹션과 동일)
      case '여유복습':
        return const Color(0xFF10B981); // 모던 에메랄드 (망각곡선 섹션과 동일)
      case '망각위험':
        return const Color(0xFFEA580C); // 모던 오렌지 (망각곡선 섹션과 동일)
      default:
        return const Color(0xFF6B7280); // 회색
    }
  }

  // 학습 모드 표시 텍스트 변환
  String _getStudyModeDisplayText(String studyModeText) {
    switch (studyModeText) {
      case '단어카드':
        return '📖 단어카드';
      case '즐겨찾기':
        return '⭐ 즐겨찾기';
      case '틀린단어':
        return '❌ 틀린단어';
      case '긴급복습':
        return '🔥 긴급복습';
      case '권장복습':
        return '🟡 권장복습';
      case '여유복습':
        return '🟢 여유복습';
      case '망각위험':
        return '⚠️ 망각위험';
      default:
        return studyModeText;
    }
  }

  // 어휘집 이름 편집 시작
  void _startEditingVocabularyName(RecentStudyInfo info) {
    // TODO: 나중에 어휘집 표시명 편집 다이얼로그 구현
    debugPrint('어휘집 이름 편집: ${info.vocabularyFile}');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return tr('time.today', namespace: 'home/recent_study');
    } else if (difference.inDays == 1) {
      return tr('time.yesterday', namespace: 'home/recent_study');
    } else if (difference.inDays < 7) {
      return tr('time.days_ago', namespace: 'home/recent_study', params: {'days': difference.inDays});
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('dialog.clear_all_title', namespace: 'home/recent_study')),
        content: Text(tr('dialog.clear_all_message', namespace: 'home/recent_study')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('dialog.no')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _recentStudyService.clearAllRecentStudyRecords();
                setState(() {
                  _recentStudyRecords.clear();
                });
                _loadRecentStudyRecords();
              } catch (e) {
                debugPrint('전체 삭제 실패: $e');
              }
            },
            child: Text(tr('dialog.yes'),
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
        title: Text(tr('dialog.delete_selected_title', namespace: 'home/recent_study')),
        content: Text(
            tr('dialog.delete_selected_message', namespace: 'home/recent_study', params: {'count': _selectedRecentRecords.length})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('dialog.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final selectedFiles = _selectedRecentRecords
                    .map((index) => _recentStudyRecords[index].vocabularyFile)
                    .toSet();

                for (final vocabularyFile in selectedFiles) {
                  await _recentStudyService
                      .removeFromRecentStudyOnly(vocabularyFile);
                }

                setState(() {
                  _selectedRecentRecords.clear();
                  _isSelectionMode = false;
                });
                _loadRecentStudyRecords();
              } catch (e) {
                debugPrint('선택된 기록 삭제 실패: $e');
              }
            },
            child: Text(tr('dialog.confirm_delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
