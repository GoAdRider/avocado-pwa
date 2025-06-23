import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';
import '../utils/strings/study_strings.dart';

class StudyCardWidget extends StatelessWidget {
  final StudySession session;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDetailsToggle;

  const StudyCardWidget({
    super.key,
    required this.session,
    required this.onFavoriteToggle,
    required this.onDetailsToggle,
  });

  @override
  Widget build(BuildContext context) {
    final word = session.currentWord;
    if (word == null) {
      return const Center(
        child: Text('단어를 불러올 수 없습니다'),
      );
    }

    return Column(
      children: [
        // POS | Type 태그 영역
        _buildPosTypeTag(context, word),

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
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 카드 상단 정보 패널
                _buildCardHeader(context, word),

                const SizedBox(height: 16),

                // 메인 단어 표시 영역
                Expanded(
                  child: _buildMainContent(context, word),
                ),

                const SizedBox(height: 16),

                // 설명 및 예시 토글 버튼
                _buildDetailsButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPosTypeTag(BuildContext context, VocabularyWord word) {
    final pos = word.pos ?? '';
    final type = word.type ?? '';

    if (pos.isEmpty && type.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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

  Widget _buildCardHeader(BuildContext context, VocabularyWord word) {
    return Row(
      children: [
        // 틀린횟수 표시
        if (word.wrongCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
          onTap: onFavoriteToggle,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: word.isFavorite
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
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

  Widget _buildMainContent(BuildContext context, VocabularyWord word) {
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
        if (session.currentSide == CardSide.front &&
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
        if (session.showDetails) ...[
          const SizedBox(height: 24),
          Expanded(
            child: _buildDetailsContent(context, word),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsContent(BuildContext context, VocabularyWord word) {
    final isTargetSide = session.currentSide == CardSide.front;
    final description = isTargetSide ? word.targetDesc : word.referenceDesc;
    final example = isTargetSide ? word.targetEx : word.referenceEx;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
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

  Widget _buildDetailsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onDetailsToggle,
        icon: const Icon(Icons.menu_book),
        label: Text(
          session.showDetails
              ? StudyStrings.collapseDetails
              : StudyStrings.expandDetails,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              session.showDetails ? Colors.grey[200] : Colors.blue[50],
          foregroundColor:
              session.showDetails ? Colors.grey[700] : Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _getCurrentMainWord(VocabularyWord word) {
    return session.currentSide == CardSide.front
        ? word.targetVoca
        : word.referenceVoca;
  }
}
