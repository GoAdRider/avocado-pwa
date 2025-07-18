import 'package:flutter/material.dart';
import '../../models/vocabulary_word.dart';
import '../../utils/i18n/simple_i18n.dart';

/// 학습 카드를 표시하는 위젯
class StudyCardWidget extends StatefulWidget {
  final StudySession session;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleDetails;

  const StudyCardWidget({
    super.key,
    required this.session,
    required this.onToggleFavorite,
    required this.onToggleDetails,
  });

  @override
  State<StudyCardWidget> createState() => _StudyCardWidgetState();
}

class _StudyCardWidgetState extends State<StudyCardWidget> {
  @override
  Widget build(BuildContext context) {
    final word = widget.session.currentWord;
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

  Widget _buildCardHeader(VocabularyWord word) {
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
              '${tr('info.wrong_count_prefix', namespace: 'word_card')}${word.wrongCount}${tr('info.wrong_count_suffix', namespace: 'word_card')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        const Spacer(),
        // 즐겨찾기 토글
        GestureDetector(
          onTap: widget.onToggleFavorite,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: word.isFavorite
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              word.isFavorite ? Icons.star : Icons.star_border,
              color: word.isFavorite ? Colors.orange[600] : Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(VocabularyWord word) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 반응형 폰트 크기 계산
    double mainFontSize = 32;
    if (screenHeight < 500) {
      mainFontSize = 20;
    } else if (screenHeight < 600) {
      mainFontSize = 24;
    } else if (screenHeight < 700) {
      mainFontSize = 28;
    }
    
    // 화면 폭에 따른 추가 조정
    if (screenWidth < 400) {
      mainFontSize = mainFontSize * 0.8;
    }
    
    // 작은 화면 여부 판단
    final isSmallScreen = screenHeight < 600;
    
    if (isSmallScreen && widget.session.showDetails) {
      // 작은 화면 + 펼친 상태: 펼치기 내용만 전체 화면
      return Expanded(
        child: _buildDetailsContent(word),
      );
    }
    
    return Expanded(
      child: Column(
        children: [
          // 메인 단어 영역
          if (!widget.session.showDetails)
            // 기본 상태: 중앙 정렬
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 메인 단어
                    Text(
                      _getCurrentMainWord(word),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: mainFontSize,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 발음 (앞면에만 표시)
                    if (widget.session.currentSide == CardSide.front &&
                        word.targetPronunciation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '[${word.targetPronunciation}]',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              fontSize: mainFontSize * 0.5,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          if (widget.session.showDetails) ...[
            // 펼친 상태: 메인 단어 위로 이동
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 메인 단어
                  Text(
                    _getCurrentMainWord(word),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: mainFontSize,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 발음 (앞면에만 표시)
                  if (widget.session.currentSide == CardSide.front &&
                      word.targetPronunciation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '[${word.targetPronunciation}]',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: mainFontSize * 0.5,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // 구분선
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            
            // 상세 정보 내용
            Expanded(
              child: _buildDetailsContent(word),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsContent(VocabularyWord word) {
    final isTargetSide = widget.session.currentSide == CardSide.front;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isWideScreen = screenWidth > 600;
            
            if ((description != null && description.isNotEmpty) && 
                (example != null && example.isNotEmpty)) {
              // 둘 다 있을 때: 화면 크기에 따른 반응형 레이아웃
              if (isWideScreen) {
                return _buildWideScreenLayout(description, example);
              } else {
                return _buildNarrowScreenLayout(description, example);
              }
            }
            
            // 설명만 있을 때
            if ((description != null && description.isNotEmpty) && 
                (example == null || example.isEmpty)) {
              return _buildDescriptionOnlyLayout(description);
            }
            
            // 예문만 있을 때
            if ((description == null || description.isEmpty) && 
                (example != null && example.isNotEmpty)) {
              return _buildExampleOnlyLayout(example);
            }
            
            // 둘 다 없을 때
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout(String description, String example) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tr('content.description_label', namespace: 'word_card'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tr('content.example_label', namespace: 'word_card'),
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
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(String description, String example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 설명 섹션
        Text(
          tr('content.description_label', namespace: 'word_card'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // 예문 섹션
        Text(
          tr('content.example_label', namespace: 'word_card'),
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
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionOnlyLayout(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tr('content.description_label', namespace: 'word_card'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExampleOnlyLayout(String example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tr('content.example_label', namespace: 'word_card'),
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
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onToggleDetails,
        icon: const Icon(Icons.menu_book),
        label: Text(
          widget.session.showDetails
              ? tr('content.collapse_details', namespace: 'word_card')
              : tr('content.expand_details', namespace: 'word_card'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              widget.session.showDetails ? Colors.grey[200] : Colors.blue[50],
          foregroundColor:
              widget.session.showDetails ? Colors.grey[700] : Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _getCurrentMainWord(VocabularyWord word) {
    return widget.session.currentSide == CardSide.front
        ? word.targetVoca
        : word.referenceVoca;
  }
}