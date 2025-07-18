import 'package:flutter/material.dart';
import '../../models/vocabulary_word.dart';
import '../../services/study/study_keyboard_service.dart';
import '../../utils/i18n/simple_i18n.dart';

/// 학습 제어 버튼들을 표시하는 위젯
class StudyControlsWidget extends StatelessWidget {
  final StudySession session;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFlip;
  final VoidCallback onShuffle;
  final bool showKeyboardGuide;

  const StudyControlsWidget({
    super.key,
    required this.session,
    required this.onPrevious,
    required this.onNext,
    required this.onFlip,
    required this.onShuffle,
    this.showKeyboardGuide = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 메인 컨트롤 버튼들
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: session.canGoPrevious ? onPrevious : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  tr('controls.previous', namespace: 'word_card'),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ElevatedButton(
                onPressed: onFlip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  tr('controls.flip', namespace: 'word_card'),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ElevatedButton(
                onPressed: onShuffle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  tr('controls.shuffle', namespace: 'word_card'),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  tr('controls.next', namespace: 'word_card'),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        
        // 키보드 안내 (옵션)
        if (showKeyboardGuide) ...[
          const SizedBox(height: 8),
          Text(
            StudyKeyboardService.instance.getKeyboardGuideText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 작은 화면용 간소화된 컨트롤 위젯
class CompactStudyControlsWidget extends StatelessWidget {
  final StudySession session;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFlip;
  final VoidCallback onShuffle;

  const CompactStudyControlsWidget({
    super.key,
    required this.session,
    required this.onPrevious,
    required this.onNext,
    required this.onFlip,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: session.canGoPrevious ? onPrevious : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              tr('controls.previous', namespace: 'word_card'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ElevatedButton(
            onPressed: onFlip,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              tr('controls.flip', namespace: 'word_card'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ElevatedButton(
            onPressed: onShuffle,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              tr('controls.shuffle', namespace: 'word_card'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              tr('controls.next', namespace: 'word_card'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/// 극소 화면용 아이콘 버튼 컨트롤 위젯
class IconStudyControlsWidget extends StatelessWidget {
  final StudySession session;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFlip;
  final VoidCallback onShuffle;

  const IconStudyControlsWidget({
    super.key,
    required this.session,
    required this.onPrevious,
    required this.onNext,
    required this.onFlip,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: session.canGoPrevious ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: 20,
          tooltip: tr('controls.previous', namespace: 'word_card'),
        ),
        IconButton(
          onPressed: onFlip,
          icon: const Icon(Icons.flip_to_back),
          iconSize: 20,
          tooltip: tr('controls.flip', namespace: 'word_card'),
        ),
        IconButton(
          onPressed: onShuffle,
          icon: const Icon(Icons.shuffle),
          iconSize: 20,
          tooltip: tr('controls.shuffle', namespace: 'word_card'),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          iconSize: 20,
          tooltip: tr('controls.next', namespace: 'word_card'),
        ),
      ],
    );
  }
}