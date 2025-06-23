import 'package:flutter/material.dart';
import '../services/vocabulary_service.dart';
import '../utils/strings/home_strings.dart';

/// 어휘집 정보를 카드 형태로 표시하는 위젯 (ui-home.mdc 구조 준수)
/// 6열 그리드에 최적화된 컴팩트 디자인
class VocabularyCard extends StatelessWidget {
  final VocabularyFileInfo vocabularyInfo;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSelection;

  const VocabularyCard({
    super.key,
    required this.vocabularyInfo,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.showSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shadowColor: isSelected
          ? const Color(0xFF6B8E23).withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF6B8E23)
              : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 68, // 고정 높이를 더 줄임 (더더더욱 컴팩트하게)
          padding: const EdgeInsets.all(3), // 패딩 더 줄임
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? const Color(0xFF6B8E23).withValues(alpha: 0.2) // 선택 시 더 진한 배경
                : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 어휘집 이름 (상단) - 체크박스 제거
              Text(
                vocabularyInfo.displayName,
                style: TextStyle(
                  fontSize: 15, // 제목 폰트 크기 더 키움
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF6B8E23)
                      : const Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // 2x2 통계 정보 (중앙) - ui-home.mdc 구조
              Column(
                children: [
                  // 첫 번째 줄: 📝 단어수, ⭐ 즐겨찾기
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatItem(
                            '📝', vocabularyInfo.totalWords),
                      ),
                      Expanded(
                        child: _buildCompactStatItem(
                            '⭐', vocabularyInfo.favoriteWords),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  // 두 번째 줄: ❌ 틀린단어, 🔢 틀린횟수
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatItem(
                            '❌', vocabularyInfo.wrongWords,
                            isError: true),
                      ),
                      Expanded(
                        child: _buildCompactStatItem(
                            '🔢', vocabularyInfo.wrongCount,
                            isError: true),
                      ),
                    ],
                  ),
                ],
              ),

              // 최근 학습 시간 (하단)
              Text(
                '📅 ${_getLastStudyTime()}',
                style: TextStyle(
                  fontSize: 10, // 시간 표시 폰트 크기 키움
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 컴팩트한 통계 항목 위젯 (6열 그리드에 최적화)
  Widget _buildCompactStatItem(String emoji, int value,
      {bool isError = false}) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 1),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isError && value > 0
                ? Colors.red[600]
                : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  /// 최근 학습 시간 텍스트 생성 (ui-home.mdc 스펙)
  String _getLastStudyTime() {
    // TODO: 실제 학습 기록에서 가져와야 함. 현재는 가져온 날짜 기준으로 임시 표시
    final now = DateTime.now();
    final diff = now.difference(vocabularyInfo.importedDate);

    if (diff.inSeconds < 60) {
      return HomeStrings.justNow;
    } else if (diff.inMinutes < 60) {
      return HomeStrings.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return HomeStrings.hoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return HomeStrings.daysAgo(diff.inDays);
    } else if (diff.inDays < 30) {
      return HomeStrings.weeksAgo((diff.inDays / 7).floor());
    } else {
      return HomeStrings.noRecent;
    }
  }
}
