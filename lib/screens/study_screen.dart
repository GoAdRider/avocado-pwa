import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_layout.dart';
import '../models/vocabulary_word.dart';
import '../utils/strings/study_strings.dart';
import '../utils/strings/base_strings.dart';
import '../utils/language_provider.dart';
// 위젯들을 직접 구현하므로 import 제거

class StudyScreen extends StatefulWidget {
  final StudyMode mode;
  final List<VocabularyWord> words;
  final List<String> vocabularyFiles;

  const StudyScreen({
    super.key,
    required this.mode,
    required this.words,
    required this.vocabularyFiles,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late StudySession _session;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeSession() {
    _session = StudySession(
      mode: widget.mode,
      words: List.from(widget.words),
      vocabularyFiles: List.from(widget.vocabularyFiles),
    );
  }

  void _updateSession(StudySession newSession) {
    setState(() {
      _session = newSession;
    });
  }

  // 키보드 이벤트 처리
  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _goToPrevious();
        return true;
      case LogicalKeyboardKey.arrowRight:
        _goToNext();
        return true;
      case LogicalKeyboardKey.space:
        _flipCard();
        return true;
      case LogicalKeyboardKey.keyR:
        _shuffleWords();
        return true;
      case LogicalKeyboardKey.keyS:
        _toggleFavorite();
        return true;
      case LogicalKeyboardKey.keyD:
        _toggleDetails();
        return true;
      case LogicalKeyboardKey.escape:
        _exitStudy();
        return true;
      default:
        return false;
    }
  }

  // 네비게이션 메서드들
  void _goToPrevious() {
    if (_session.canGoPrevious) {
      _updateSession(_session.copyWith(
        currentIndex: _session.currentIndex - 1,
        currentSide: CardSide.front,
        showDetails: false,
      ));
    }
  }

  void _goToNext() {
    if (_session.canGoNext) {
      _updateSession(_session.copyWith(
        currentIndex: _session.currentIndex + 1,
        currentSide: CardSide.front,
        showDetails: false,
      ));
    } else if (_session.currentIndex == _session.words.length - 1) {
      // 마지막 단어에서 다음 버튼을 누르면 완료 처리
      _showCompletionDialog();
    }
  }

  void _flipCard() {
    _updateSession(_session.copyWith(
      currentSide: _session.currentSide == CardSide.front
          ? CardSide.back
          : CardSide.front,
      showDetails: false,
    ));
  }

  void _shuffleWords() {
    final shuffledWords = List<VocabularyWord>.from(_session.words);
    shuffledWords.shuffle();

    _updateSession(_session.copyWith(
      words: shuffledWords,
      currentIndex: 0,
      currentSide: CardSide.front,
      showDetails: false,
    ));

    // 섞기 완료 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(StudyStrings.wordsShuffled),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite() {
    final currentWord = _session.currentWord;
    if (currentWord == null) return;

    // 실제 구현에서는 Hive 데이터베이스 업데이트
    final updatedWord = currentWord.copyWith(
      isFavorite: !currentWord.isFavorite,
    );

    final updatedWords = List<VocabularyWord>.from(_session.words);
    updatedWords[_session.currentIndex] = updatedWord;

    _updateSession(_session.copyWith(words: updatedWords));

    // 즐겨찾기 토글 피드백
    final message = updatedWord.isFavorite
        ? StudyStrings.favoriteAdded
        : StudyStrings.favoriteRemoved;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleDetails() {
    _updateSession(_session.copyWith(
      showDetails: !_session.showDetails,
    ));
  }

  void _previousCard() {
    if (_session.canGoPrevious) {
      _updateSession(_session.copyWith(
        currentIndex: _session.currentIndex - 1,
        currentSide: CardSide.front, // 이전 카드로 갈 때는 앞면으로
      ));
    }
  }

  void _nextCard() {
    if (_session.canGoNext) {
      _updateSession(_session.copyWith(
        currentIndex: _session.currentIndex + 1,
        currentSide: CardSide.front, // 다음 카드로 갈 때는 앞면으로
      ));
    }
  }

  void _exitStudy() {
    Navigator.of(context).pop();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.orange),
              const SizedBox(width: 8),
              Text(StudyStrings.congratulations),
            ],
          ),
          content: Text(StudyStrings.studyCompleted),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 학습 화면 닫기
              },
              child: Text(StudyStrings.returnToHome),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _initializeSession(); // 세션 초기화
                setState(() {}); // 화면 새로고침
              },
              child: Text(StudyStrings.continueStudy),
            ),
          ],
        );
      },
    );
  }

  String _getModeTitle() {
    switch (_session.mode) {
      case StudyMode.cardStudy:
        return '📖 ${StudyStrings.cardStudy}';
      case StudyMode.favoriteReview:
        return '⭐ ${StudyStrings.favoriteReview}';
      case StudyMode.wrongWordsStudy:
        return '❌ ${StudyStrings.wrongWordsStudy}';
      case StudyMode.urgentReview:
        return '🔴 ${StudyStrings.urgentReview}';
      case StudyMode.recommendedReview:
        return '🟡 ${StudyStrings.recommendedReview}';
      case StudyMode.leisureReview:
        return '🟢 ${StudyStrings.leisureReview}';
      case StudyMode.forgettingRisk:
        return '⚠️ ${StudyStrings.forgettingRisk}';
    }
  }

  bool _shouldShowVocabularyInfo() {
    // 망각곡선 기반 복습은 어휘집 정보를 표시하지 않음
    return ![
      StudyMode.urgentReview,
      StudyMode.recommendedReview,
      StudyMode.leisureReview,
      StudyMode.forgettingRisk,
    ].contains(_session.mode);
  }

  // 진행도 바 위젯 구현
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 학습 모드 타이틀
          Expanded(
            flex: 3,
            child: Text(
              _getModeTitle(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getModeColor(),
                  ),
            ),
          ),

          // 선택된 어휘집 정보 (조건부 표시)
          if (_shouldShowVocabularyInfo()) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildVocabularyInfo(),
            ),
          ],

          const SizedBox(width: 16),

          // 진행도 정보
          Expanded(
            flex: 2,
            child: _buildProgressInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyInfo() {
    final vocabularyCount = _session.vocabularyFiles.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        '${StudyStrings.selectedVocabularies}($vocabularyCount${StudyStrings.vocabularyCountSuffix})',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProgressInfo() {
    final current = _session.currentIndex + 1;
    final total = _session.words.length;
    final percent = _session.progressPercent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        '${StudyStrings.progress}: $current/$total ($percent%)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getModeColor() {
    switch (_session.mode) {
      case StudyMode.cardStudy:
        return Colors.blue[700]!;
      case StudyMode.favoriteReview:
        return Colors.orange[700]!;
      case StudyMode.wrongWordsStudy:
        return Colors.red[700]!;
      case StudyMode.urgentReview:
        return Colors.red[800]!;
      case StudyMode.recommendedReview:
        return Colors.amber[700]!;
      case StudyMode.leisureReview:
        return Colors.green[700]!;
      case StudyMode.forgettingRisk:
        return Colors.red[900]!;
    }
  }

  // 학습 카드 위젯 구현
  Widget _buildStudyCard() {
    final word = _session.currentWord;
    if (word == null) {
      return const Center(
        child: Text('단어를 불러올 수 없습니다'),
      );
    }

    return Column(
      children: [
        // POS | Type 태그 영역
        _buildPosTypeTag(word),

        const SizedBox(height: 8),

        // 메인 카드
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 카드 상단 정보 패널
                _buildCardHeader(word),

                const SizedBox(height: 16),

                // 메인 단어 표시 영역
                Expanded(
                  child: _buildMainContent(word),
                ),

                const SizedBox(height: 16),

                // 설명 및 예시 토글 버튼
                _buildDetailsButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPosTypeTag(VocabularyWord word) {
    final pos = word.pos ?? '';
    final type = word.type ?? '';

    if (pos.isEmpty && type.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        pos.isNotEmpty && type.isNotEmpty
            ? '$pos | $type'
            : pos.isNotEmpty
                ? pos
                : type,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildCardHeader(VocabularyWord word) {
    return Row(
      children: [
        // 틀린횟수 표시
        if (word.wrongCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              '${StudyStrings.wrongCountPrefix}${word.wrongCount}${StudyStrings.wrongCountSuffix}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

        const Spacer(),

        // 즐겨찾기 토글
        GestureDetector(
          onTap: _toggleFavorite,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: word.isFavorite
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              word.isFavorite
                  ? StudyStrings.favoriteFilled
                  : StudyStrings.favoriteEmpty,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(VocabularyWord word) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 메인 단어
        Text(
          _getCurrentMainWord(word),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // 발음 (앞면에만 표시)
        if (_session.currentSide == CardSide.front &&
            word.targetPronunciation != null)
          Text(
            '[${word.targetPronunciation}]',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),

        // 상세 정보 (펼쳐진 상태일 때)
        if (_session.showDetails) ...[
          const SizedBox(height: 24),
          Expanded(
            child: _buildDetailsContent(word),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsContent(VocabularyWord word) {
    final isTargetSide = _session.currentSide == CardSide.front;
    final description = isTargetSide ? word.targetDesc : word.referenceDesc;
    final example = isTargetSide ? word.targetEx : word.referenceEx;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명
            if (description != null && description.isNotEmpty) ...[
              Text(
                StudyStrings.descriptionLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],

            // 예시
            if (example != null && example.isNotEmpty) ...[
              Text(
                StudyStrings.exampleLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Text(
                  '"$example"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[800],
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleDetails,
        icon: const Icon(Icons.menu_book),
        label: Text(
          _session.showDetails
              ? StudyStrings.collapseDetails
              : StudyStrings.expandDetails,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _session.showDetails ? Colors.grey[200] : Colors.blue[50],
          foregroundColor:
              _session.showDetails ? Colors.grey[700] : Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _getCurrentMainWord(VocabularyWord word) {
    return _session.currentSide == CardSide.front
        ? word.targetVoca
        : word.referenceVoca;
  }

  // 하단 컨트롤 버튼들
  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: _session.canGoPrevious ? _previousCard : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(StudyStrings.previous),
            ),
          ),

          const SizedBox(width: 8),

          // 뒤집기 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: _flipCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(StudyStrings.flip),
            ),
          ),

          const SizedBox(width: 8),

          // 섞기 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: _shuffleWords,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(StudyStrings.shuffle),
            ),
          ),

          const SizedBox(width: 8),

          // 다음 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: _session.canGoNext ? _nextCard : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(StudyStrings.next),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 언어 프로바이더를 호출하여 언어 변경을 즉시 반영
    final languageProvider = LanguageProvider.of(context);

    if (_session.words.isEmpty) {
      return AppLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.library_books_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                StudyStrings.noWordsAvailable,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _exitStudy,
                child: Text(StudyStrings.returnToHome),
              ),
            ],
          ),
        ),
      );
    }

    return AppLayout(
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          return _handleKeyEvent(event)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        },
        child: Column(
          children: [
            // 학습 진행 상태 바
            _buildProgressBar(),

            // 메인 학습 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 단어 카드
                    Expanded(
                      child: _buildStudyCard(),
                    ),

                    const SizedBox(height: 16),

                    // 네비게이션 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _session.canGoPrevious ? _goToPrevious : null,
                            child: Text(StudyStrings.previous),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _flipCard,
                            child: Text(StudyStrings.flip),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _shuffleWords,
                            child: Text(StudyStrings.shuffle),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _goToNext,
                            child: Text(StudyStrings.next),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 키보드 안내
                    Text(
                      StudyStrings.keyboardGuide,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
