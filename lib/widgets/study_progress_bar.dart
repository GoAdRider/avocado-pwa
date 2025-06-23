import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';
import '../utils/strings/study_strings.dart';

class StudyProgressBar extends StatelessWidget {
  final StudySession session;
  final String modeTitle;
  final bool showVocabularyInfo;

  const StudyProgressBar({
    super.key,
    required this.session,
    required this.modeTitle,
    required this.showVocabularyInfo,
  });

  @override
  Widget build(BuildContext context) {
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
              modeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getModeColor(),
                  ),
            ),
          ),

          // 선택된 어휘집 정보 (조건부 표시)
          if (showVocabularyInfo) ...[
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
        ],
      ),
    );
  }

  Widget _buildVocabularyInfo(BuildContext context) {
    final vocabularyCount = session.vocabularyFiles.length;

    return Tooltip(
      message: _buildTooltipMessage(),
      child: Container(
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
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context) {
    final current = session.currentIndex + 1;
    final total = session.words.length;
    final percent = session.progressPercent;

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

  String _buildTooltipMessage() {
    final buffer = StringBuffer();
    buffer.writeln('📚 선택된 어휘집 상세 정보');
    buffer.writeln('');

    // 실제 구현에서는 각 어휘집별 상세 정보를 표시
    for (int i = 0; i < session.vocabularyFiles.length; i++) {
      buffer.writeln('• ${session.vocabularyFiles[i]}');
    }

    buffer.writeln('');
    buffer.writeln('총 단어: ${session.words.length}개');

    final favoriteCount = session.words.where((word) => word.isFavorite).length;
    final wrongWordCount =
        session.words.where((word) => word.wrongCount > 0).length;
    final totalWrongCount =
        session.words.fold<int>(0, (sum, word) => sum + word.wrongCount);

    buffer.writeln('⭐ 즐겨찾기: $favoriteCount개');
    buffer.writeln('❌ 틀린단어: $wrongWordCount개');
    buffer.writeln('🔢 틀린횟수: $totalWrongCount회');

    return buffer.toString().trim();
  }

  Color _getModeColor() {
    switch (session.mode) {
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
}
