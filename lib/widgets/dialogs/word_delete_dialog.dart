import 'package:flutter/material.dart';
import '../../models/vocabulary_word.dart';
import '../../services/study/word_deletion_service.dart';
import '../../utils/i18n/simple_i18n.dart';

/// 단어 삭제 다이얼로그 위젯
class WordDeleteDialog extends StatelessWidget {
  final VocabularyWord word;
  final Function(WordDeletionResult) onDeletionComplete;

  const WordDeleteDialog({
    super.key,
    required this.word,
    required this.onDeletionComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        tr('title', namespace: 'dialogs/word_delete'),
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
          // 현재 단어 정보
          _buildWordInfo(),
          const SizedBox(height: 16),
          Text(tr('question', namespace: 'dialogs/word_delete')),
          const SizedBox(height: 16),
          // 임시 삭제 설명
          _buildTemporaryDeleteInfo(),
          const SizedBox(height: 8),
          // 영구 삭제 설명
          _buildPermanentDeleteInfo(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('buttons.cancel', namespace: 'dialogs/word_delete')),
        ),
        TextButton(
          onPressed: () => _handleTemporaryDelete(context),
          style: TextButton.styleFrom(foregroundColor: Colors.orange[700]),
          child: Text(tr('buttons.temporary_delete', namespace: 'dialogs/word_delete')),
        ),
        TextButton(
          onPressed: () => _handlePermanentDelete(context),
          style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
          child: Text(tr('buttons.permanent_delete', namespace: 'dialogs/word_delete')),
        ),
      ],
    );
  }

  Widget _buildWordInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('word_to_delete', namespace: 'dialogs/word_delete'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '📝 ${word.targetVoca}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '🔤 ${word.referenceVoca}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            '📂 ${word.vocabularyFile}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTemporaryDeleteInfo() {
    return Container(
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
            tr('temporary_delete.title', namespace: 'dialogs/word_delete'),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[700]),
          ),
          Text(tr('temporary_delete.description_1', namespace: 'dialogs/word_delete')),
          Text(tr('temporary_delete.description_2', namespace: 'dialogs/word_delete')),
          Text(tr('temporary_delete.description_3', namespace: 'dialogs/word_delete')),
          Text(tr('temporary_delete.description_4', namespace: 'dialogs/word_delete')),
        ],
      ),
    );
  }

  Widget _buildPermanentDeleteInfo() {
    return Container(
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
            tr('permanent_delete.title', namespace: 'dialogs/word_delete'),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
          ),
          Text(tr('permanent_delete.description_1', namespace: 'dialogs/word_delete')),
          Text(tr('permanent_delete.description_2', namespace: 'dialogs/word_delete')),
          Text(tr('permanent_delete.description_3', namespace: 'dialogs/word_delete')),
        ],
      ),
    );
  }

  void _handleTemporaryDelete(BuildContext context) async {
    Navigator.of(context).pop();
    final result = await WordDeletionService.instance.temporaryDelete(word);
    onDeletionComplete(result);
  }

  void _handlePermanentDelete(BuildContext context) async {
    Navigator.of(context).pop();
    final result = await WordDeletionService.instance.permanentDelete(word);
    onDeletionComplete(result);
  }

  /// 다이얼로그 표시 유틸리티 메서드
  static Future<void> show(
    BuildContext context, 
    VocabularyWord word, 
    Function(WordDeletionResult) onDeletionComplete,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WordDeleteDialog(
          word: word,
          onDeletionComplete: onDeletionComplete,
        );
      },
    );
  }
}