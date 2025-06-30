import 'package:flutter/material.dart';
import '../../models/vocabulary_word.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../../services/common/temporary_delete_service.dart';

class StudyProgressBar extends StatelessWidget {
  final StudySession session;
  final String modeTitle;
  final bool showVocabularyInfo;
  final Function(String vocabularyFile, bool isPermanent)? onDeleteVocabulary;

  const StudyProgressBar({
    super.key,
    required this.session,
    required this.modeTitle,
    required this.showVocabularyInfo,
    this.onDeleteVocabulary,
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
      child: InkWell(
        onTap: () => _showVocabularyDetailsDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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

  String _buildTooltipMessage() {
    final buffer = StringBuffer();
    
    // 선택된 어휘집 표시 (불렛 포인트 적용)
    if (session.vocabularyFiles.length == 1) {
      buffer.writeln('${tr('tooltip.vocabulary', namespace: 'word_card')}: ${session.vocabularyFiles.first.replaceAll('.csv', '')}');
    } else {
      buffer.writeln('${tr('tooltip.vocabulary', namespace: 'word_card')}:');
      for (final vocabFile in session.vocabularyFiles) {
        final displayName = vocabFile.replaceAll('.csv', '');
        buffer.writeln('       • $displayName');
      }
    }
    
    // 임시 삭제된 단어들을 제외한 실제 단어 수 계산
    final tempDeleteService = TemporaryDeleteService.instance;
    final activeWords = session.words.where((word) => 
      !tempDeleteService.isTemporarilyDeleted(word.id)
    ).toList();
    
    buffer.writeln('${tr('tooltip.word_count', namespace: 'word_card')}: ${activeWords.length}${tr('tooltip.unit_count', namespace: 'word_card')}');

    final favoriteCount = activeWords.where((word) => word.isFavorite).length;
    final wrongWordCount = activeWords.where((word) => word.wrongCount > 0).length;
    final totalWrongCount = activeWords.fold<int>(0, (sum, word) => sum + word.wrongCount);

    buffer.writeln('${tr('tooltip.favorites', namespace: 'word_card')}: $favoriteCount${tr('tooltip.unit_count', namespace: 'word_card')}');
    buffer.writeln('${tr('tooltip.wrong_words', namespace: 'word_card')}: $wrongWordCount${tr('tooltip.unit_count', namespace: 'word_card')}');
    buffer.writeln('${tr('tooltip.wrong_count', namespace: 'word_card')}: $totalWrongCount${tr('tooltip.unit_times', namespace: 'word_card')}');

    return buffer.toString().trim();
  }

  void _showVocabularyDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '📚 선택된 어휘집 상세 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 통계 정보
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('총 단어: ${session.words.length}개'),
                      Text('⭐ 즐겨찾기: ${session.words.where((word) => word.isFavorite).length}개'),
                      Text('❌ 틀린단어: ${session.words.where((word) => word.wrongCount > 0).length}개'),
                      Text('🔢 틀린횟수: ${session.words.fold<int>(0, (sum, word) => sum + word.wrongCount)}회'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 어휘집 목록
                Text(
                  '어휘집 목록:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: session.vocabularyFiles.length,
                    itemBuilder: (context, index) {
                      final vocabularyFile = session.vocabularyFiles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.folder, color: Colors.blue),
                          title: Text(
                            vocabularyFile,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '• $vocabularyFile',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: onDeleteVocabulary != null
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmDialog(context, vocabularyFile),
                                  tooltip: '어휘집 삭제',
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String vocabularyFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '어휘집 삭제',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('어휘집 "$vocabularyFile"을(를) 어떻게 처리하시겠습니까?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔸 임시삭제',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[700]),
                    ),
                    const Text('• 이 학습 세션에서만 제외됩니다'),
                    const Text('• 어휘집 파일은 유지됩니다'),
                    const Text('• 최근 학습 기록에서 다시 선택 가능합니다'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔸 영구삭제',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                    ),
                    const Text('• 어휘집 파일이 완전히 삭제됩니다'),
                    const Text('• 관련된 모든 학습 기록도 삭제됩니다'),
                    const Text('• 복구할 수 없습니다'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 삭제 다이얼로그 닫기
                Navigator.of(context).pop(); // 상세 다이얼로그 닫기
                onDeleteVocabulary?.call(vocabularyFile, false); // 임시삭제
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange[700]),
              child: const Text('임시삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 삭제 다이얼로그 닫기
                Navigator.of(context).pop(); // 상세 다이얼로그 닫기
                onDeleteVocabulary?.call(vocabularyFile, true); // 영구삭제
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
              child: const Text('영구삭제'),
            ),
          ],
        );
      },
    );
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
