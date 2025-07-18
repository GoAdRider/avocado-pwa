import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common/app_layout.dart';
import '../models/vocabulary_word.dart';
import '../utils/i18n/simple_i18n.dart';
import '../services/study/study_session_manager.dart';
import '../services/study/study_timer_service.dart';
import '../services/study/study_keyboard_service.dart';
import '../services/study/word_deletion_service.dart';
import '../services/home/study_status/study_status_service.dart';
import '../services/home/vocabulary_list/vocabulary_list_service.dart';
import '../widgets/home/recent_study_section.dart';
import '../widgets/word_card/study_card_widget.dart';
import '../widgets/word_card/study_progress_bar_widget.dart';
import '../widgets/word_card/study_controls_widget.dart';
import '../widgets/dialogs/word_delete_dialog.dart';

class StudyScreen extends StatefulWidget {
  final StudyMode mode;
  final List<VocabularyWord> words;
  final List<String> vocabularyFiles;
  final String studyModePreference;
  final List<String> posFilters;
  final List<String> typeFilters;

  const StudyScreen({
    super.key,
    required this.mode,
    required this.words,
    required this.vocabularyFiles,
    this.studyModePreference = 'TargetVoca',
    this.posFilters = const [],
    this.typeFilters = const [],
  });

  @override
  State<StudyScreen> createState() => StudyScreenState();
}

// StudyScreen 컨트롤러
class StudyScreenController {
  static final GlobalKey<StudyScreenState> _key = GlobalKey<StudyScreenState>();
  
  static GlobalKey<StudyScreenState> get key => _key;
  
  static void exitStudy() {
    _key.currentState?._exitStudy();
  }
}

class StudyScreenState extends State<StudyScreen> with WidgetsBindingObserver {
  late FocusNode _focusNode;
  
  // 서비스 인스턴스들
  final StudySessionManager _sessionManager = StudySessionManager.instance;
  final StudyTimerService _timerService = StudyTimerService.instance;
  final StudyKeyboardService _keyboardService = StudyKeyboardService.instance;
  final WordDeletionService _deletionService = WordDeletionService.instance;
  final StudyStatusService _studyStatusService = StudyStatusService.instance;
  
  StudySession? _currentSession;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();
    _initializeStudySession();
    _setupKeyboardService();
    _setupDeletionService();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerService.stopTimer();
    _sessionManager.saveCurrentProgress(
      widget.vocabularyFiles, 
      widget.studyModePreference, 
      widget.posFilters, 
      widget.typeFilters
    );
    _sessionManager.endSession();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _sessionManager.saveCurrentProgress(
        widget.vocabularyFiles, 
        widget.studyModePreference, 
        widget.posFilters, 
        widget.typeFilters
      );
      _sessionManager.endSession();
    }
  }

  Future<void> _initializeStudySession() async {
    try {
      final session = await _sessionManager.initializeSession(
        mode: widget.mode,
        words: widget.words,
        vocabularyFiles: widget.vocabularyFiles,
        studyModePreference: widget.studyModePreference,
        posFilters: widget.posFilters,
        typeFilters: widget.typeFilters,
      );
      
      setState(() {
        _currentSession = session;
      });
      
      _timerService.startTimer();
    } catch (e) {
      debugPrint('❌ 학습 세션 초기화 실패: $e');
    }
  }

  void _setupKeyboardService() {
    _keyboardService.registerCallbacks(
      onExitStudy: _exitStudy,
      onShowWordDeleteDialog: _showWordDeleteDialog,
      onToggleDetails: () => _sessionManager.toggleDetails(),
      studyModePreference: widget.studyModePreference,
    );
  }

  void _setupDeletionService() {
    _deletionService.deletionStream.listen((result) {
      final message = result.message;
      final backgroundColor = result.success
          ? (result.isTemporary ? Colors.orange : Colors.red)
          : Colors.red;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
      
      // 모든 단어가 삭제되면 학습 종료
      if (_deletionService.shouldEndSession()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('messages.all_words_removed', namespace: 'dialogs/word_delete')),
            backgroundColor: Colors.red,
          ),
        );
        _exitStudy();
      }
    });
  }

  void _onPrevious() {
    _sessionManager.goToPrevious(widget.studyModePreference);
    _timerService.startNewCard();
  }

  void _onNext() {
    if (_currentSession?.canGoNext == true) {
      _sessionManager.goToNext(widget.studyModePreference);
      _timerService.startNewCard();
    } else if (_currentSession?.currentIndex == (_currentSession?.words.length ?? 0) - 1) {
      _showCompletionDialog();
    }
  }

  void _onFlip() {
    _sessionManager.flipCard();
  }

  void _onShuffle() {
    _sessionManager.shuffleWords(widget.studyModePreference);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('study.words_shuffled', namespace: 'word_card')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _onToggleFavorite() async {
    final isNowFavorite = await _sessionManager.toggleFavorite();
    
    final message = isNowFavorite
        ? tr('study.favorite_added', namespace: 'word_card')
        : tr('study.favorite_removed', namespace: 'word_card');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showWordDeleteDialog() {
    final currentWord = _currentSession?.currentWord;
    if (currentWord == null) return;

    WordDeleteDialog.show(
      context, 
      currentWord, 
      (result) {
        // 삭제 결과는 deletionStream에서 처리됨
      },
    );
  }

  void _showCompletionDialog() async {
    await _sessionManager.clearCurrentProgress(
      widget.vocabularyFiles, 
      widget.studyModePreference, 
      widget.posFilters, 
      widget.typeFilters
    );
    
    await _sessionManager.endSession();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Focus(
            autofocus: true,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Enter') {
                Navigator.of(context).pop();
                _restartSession();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(tr('study.congratulations', namespace: 'word_card')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr('study.study_completed', namespace: 'word_card')),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 팁: Enter 키를 누르면 학습을 계속할 수 있습니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _exitStudy();
                  },
                  child: Text(tr('study.return_to_home', namespace: 'word_card')),
                ),
                ElevatedButton(
                  autofocus: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartSession();
                  },
                  child: Text(tr('study.continue_study', namespace: 'word_card')),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _restartSession() {
    _initializeStudySession();
  }

  void _exitStudy() async {
    if (_isExiting) return;
    _isExiting = true;
    
    try {
      await _sessionManager.saveCurrentProgress(
        widget.vocabularyFiles, 
        widget.studyModePreference, 
        widget.posFilters, 
        widget.typeFilters
      );
      
      await _timerService.addFinalTimeToDaily();
      
      final finalTime = _timerService.getFinalStudyTime();
      if (finalTime.inMinutes >= 1) {
        _studyStatusService.refreshStats();
      }
      
      await _sessionManager.endSession();

      if (mounted) {
        VocabularyListService.instance.unselectAll();
        Navigator.of(context).pop();
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          RecentStudySectionController.refresh();
        });
      }
    } catch (e) {
      debugPrint('❌ StudyScreen 종료 중 오류: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      _isExiting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSession == null) {
      return AppLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(tr('content.loading_session', namespace: 'word_card')),
            ],
          ),
        ),
      );
    }

    if (_currentSession!.words.isEmpty) {
      return AppLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                tr('content.no_words_available', namespace: 'word_card'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _exitStudy,
                child: Text(tr('study.return_to_home', namespace: 'word_card')),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _exitStudy();
      },
      child: AppLayout(
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            return _keyboardService.handleKeyEvent(event)
                ? KeyEventResult.handled
                : KeyEventResult.ignored;
          },
          child: StreamBuilder<StudySession>(
            stream: _sessionManager.sessionStream,
            initialData: _currentSession,
            builder: (context, snapshot) {
              final session = snapshot.data!;
              
              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight;
                  final isVerySmallScreen = screenHeight < 400;
                  final isSmallScreen = screenHeight < 600;
                  
                  return Column(
                    children: [
                      // 진행 상태 바
                      if (!isVerySmallScreen)
                        StudyProgressBarWidget(
                          session: session,
                          vocabularyFiles: widget.vocabularyFiles,
                        ),
                      
                      if (isVerySmallScreen)
                        CompactProgressBarWidget(session: session),

                      // 메인 학습 영역
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                          child: Column(
                            children: [
                              // 학습 카드
                              Expanded(
                                flex: isSmallScreen ? 8 : 6,
                                child: Container(
                                  constraints: BoxConstraints(
                                    minHeight: isVerySmallScreen ? 200 : 300,
                                  ),
                                  child: StudyCardWidget(
                                    session: session,
                                    onToggleFavorite: _onToggleFavorite,
                                    onToggleDetails: () => _sessionManager.toggleDetails(),
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 8 : 16),

                              // 컨트롤 버튼들
                              if (!isVerySmallScreen)
                                if (isSmallScreen)
                                  CompactStudyControlsWidget(
                                    session: session,
                                    onPrevious: _onPrevious,
                                    onNext: _onNext,
                                    onFlip: _onFlip,
                                    onShuffle: _onShuffle,
                                  )
                                else
                                  StudyControlsWidget(
                                    session: session,
                                    onPrevious: _onPrevious,
                                    onNext: _onNext,
                                    onFlip: _onFlip,
                                    onShuffle: _onShuffle,
                                    showKeyboardGuide: !isSmallScreen,
                                  ),

                              if (isVerySmallScreen)
                                IconStudyControlsWidget(
                                  session: session,
                                  onPrevious: _onPrevious,
                                  onNext: _onNext,
                                  onFlip: _onFlip,
                                  onShuffle: _onShuffle,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}