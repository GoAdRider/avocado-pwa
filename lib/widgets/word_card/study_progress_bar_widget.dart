import 'package:flutter/material.dart';
import '../../models/vocabulary_word.dart';
import '../../services/study/study_timer_service.dart';
import '../../services/word_card/study_service.dart';
import '../../utils/i18n/simple_i18n.dart';

/// 학습 진행 상태를 표시하는 위젯
class StudyProgressBarWidget extends StatelessWidget {
  final StudySession session;
  final List<String> vocabularyFiles;

  const StudyProgressBarWidget({
    super.key,
    required this.session,
    required this.vocabularyFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              child: _buildVocabularyInfo(context),
            ),
          ],

          const SizedBox(width: 16),

          // 진행도 정보
          Expanded(
            flex: 2,
            child: _buildProgressInfo(context),
          ),
          
          const SizedBox(width: 16),
          
          // 학습 시간 정보
          Expanded(
            flex: 1,
            child: _buildStudyTimeInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyInfo(BuildContext context) {
    final vocabularyCount = vocabularyFiles.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tr('info.selected_vocabularies', namespace: 'word_card')}($vocabularyCount${tr('info.vocabulary_count_suffix', namespace: 'word_card')})',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStudyTimeInfo(BuildContext context) {
    return StreamBuilder<StudyTimeState>(
      stream: StudyTimerService.instance.timeStateStream,
      initialData: StudyTimerService.instance.currentState,
      builder: (context, snapshot) {
        final timeState = snapshot.data!;
        final timerColor = timeState.isMainTimerActive ? Colors.green : Colors.red;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: timerColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                timeState.isMainTimerActive ? Icons.timer : Icons.timer_off,
                size: 16,
                color: timerColor[700],
              ),
              const SizedBox(height: 2),
              Text(
                timeState.formattedTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: timerColor[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressInfo(BuildContext context) {
    final current = session.currentIndex + 1;
    final total = session.words.length;
    final percent = session.progressPercent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tr('info.progress', namespace: 'word_card')}: $current/$total ($percent%)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getModeTitle() {
    switch (session.mode) {
      case StudyMode.cardStudy:
        return '📖 ${tr('modes.card_study', namespace: 'word_card')}';
      case StudyMode.favoriteReview:
        return '⭐ ${tr('modes.favorite_review', namespace: 'word_card')}';
      case StudyMode.wrongWordsStudy:
        return '❌ ${tr('modes.wrong_words_study', namespace: 'word_card')}';
      case StudyMode.urgentReview:
        return '🔴 ${tr('modes.urgent_review', namespace: 'word_card')}';
      case StudyMode.recommendedReview:
        return '🟡 ${tr('modes.recommended_review', namespace: 'word_card')}';
      case StudyMode.leisureReview:
        return '🟢 ${tr('modes.leisure_review', namespace: 'word_card')}';
      case StudyMode.forgettingRisk:
        return '⚠️ ${tr('modes.forgetting_risk', namespace: 'word_card')}';
    }
  }

  bool _shouldShowVocabularyInfo() {
    // 망각곡선 기반 복습은 어휘집 정보를 표시하지 않음
    return ![
      StudyMode.urgentReview,
      StudyMode.recommendedReview,
      StudyMode.leisureReview,
      StudyMode.forgettingRisk,
    ].contains(session.mode);
  }

  Color _getModeColor() {
    return StudyService.instance.getStudyModeColor(session.mode);
  }
}

/// 극소 화면용 간소화된 진행바 위젯
class CompactProgressBarWidget extends StatelessWidget {
  final StudySession session;

  const CompactProgressBarWidget({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '${session.currentIndex + 1}/${session.words.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: (session.currentIndex + 1) / session.words.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}