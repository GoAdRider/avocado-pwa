import 'package:flutter/material.dart';
import '../../utils/i18n/simple_i18n.dart';

class ForgettingCurveReviewSection extends StatefulWidget {
  const ForgettingCurveReviewSection({super.key});

  @override
  State<ForgettingCurveReviewSection> createState() => _ForgettingCurveReviewSectionState();
}

class _ForgettingCurveReviewSectionState extends State<ForgettingCurveReviewSection> {
  // 선택된 복습 타입을 추적하는 변수
  String _selectedReviewType = 'urgent'; // 기본값은 긴급 복습

  // 복습 데이터 맵
  Map<String, Map<String, String>> get _reviewData => {
        'urgent': {
          'emoji': 'priority_high',
          'title': tr('review_types.urgent_review', namespace: 'home/forgetting_curve'),
          'count': '7${tr('units.words')}',
          'description': tr('descriptions.urgent_review', namespace: 'home/forgetting_curve'),
        },
        'recommended': {
          'emoji': 'lightbulb',
          'title': tr('review_types.recommended_review', namespace: 'home/forgetting_curve'),
          'count': '12${tr('units.words')}',
          'description': tr('descriptions.recommended_review', namespace: 'home/forgetting_curve'),
        },
        'preview': {
          'emoji': 'preview',
          'title': tr('review_types.preview_review', namespace: 'home/forgetting_curve'),
          'count': '5${tr('units.words')}',
          'description': tr('descriptions.preview_review', namespace: 'home/forgetting_curve'),
        },
        'forgotten': {
          'emoji': 'warning',
          'title': tr('review_types.forgotten_review', namespace: 'home/forgetting_curve'),
          'count': '7${tr('units.words')}',
          'description': tr('descriptions.forgotten_review', namespace: 'home/forgetting_curve'),
        },
      };

  // 아이콘 헬퍼 메서드
  Widget _getReviewIcon(String iconName, double size, Color color) {
    IconData iconData;
    switch (iconName) {
      case 'priority_high':
        iconData = Icons.priority_high;
        break;
      case 'lightbulb':
        iconData = Icons.lightbulb;
        break;
      case 'preview':
        iconData = Icons.preview;
        break;
      case 'warning':
        iconData = Icons.warning;
        break;
      default:
        iconData = Icons.help;
    }
    return Icon(iconData, size: size, color: color);
  }

  // 아이콘 색상 헬퍼 메서드
  Color _getIconColor(String reviewType) {
    switch (reviewType) {
      case 'urgent':
        return Colors.red;
      case 'recommended':
        return Colors.amber;
      case 'preview':
        return Colors.green;
      case 'forgotten':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageNotifier.instance,
      builder: (context, _) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('review_types.smart_review', namespace: 'home/forgetting_curve'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTabStyleReview(),
      ],
        );
      },
    );
  }

  // 새로운 탭 형태 복습 위젯
  Widget _buildTabStyleReview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // 좌측: 선택된 복습 항목 (큰 카드)
          Expanded(
            flex: 3,
            child: _buildMainReviewCard(_selectedReviewType),
          ),
          const SizedBox(width: 16),
          // 우측: 나머지 복습 항목들 (작은 탭들)
          Expanded(
            flex: 2,
            child: Column(
              children: _reviewData.entries
                  .where((entry) => entry.key != _selectedReviewType)
                  .map((entry) => _buildSmallReviewTab(entry.key, entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 메인 복습 카드 (좌측 큰 카드)
  Widget _buildMainReviewCard(String reviewType) {
    final data = _reviewData[reviewType]!;
    final colors = _getReviewColors(reviewType);
    final backgroundColor = colors['background']!;
    final borderColor = colors['border']!;
    final textColor = colors['text']!;

    return Material(
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: () => _handleReviewTap(reviewType),
        borderRadius: BorderRadius.circular(18),
        splashColor: borderColor.withValues(alpha: 0.1),
        highlightColor: borderColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이모지와 제목
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _getReviewIcon(
                        data['emoji']!, 
                        28, 
                        _getIconColor(reviewType),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['count']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 설명
              Text(
                data['description']!,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              // 시작 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr('actions.start'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 작은 복습 탭 (우측 작은 탭들)
  Widget _buildSmallReviewTab(String reviewType, Map<String, String> data) {
    final colors = _getReviewColors(reviewType);
    final backgroundColor = colors['background']!;
    final borderColor = colors['border']!;
    final textColor = colors['text']!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedReviewType = reviewType;
            });
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: borderColor.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _getReviewIcon(
                      data['emoji']!, 
                      16, 
                      _getIconColor(reviewType),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['count']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 14,
                    color: borderColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 복습 타입별 색상 정보
  Map<String, Color> _getReviewColors(String reviewType) {
    switch (reviewType) {
      case 'urgent':
        return {
          'background': const Color(0xFFFFF5F5), // 매우 연한 로즈
          'border': const Color(0xFFEC4899), // 모던 핑크
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFFEC4899),
        };
      case 'recommended':
        return {
          'background': const Color(0xFFFEFCE8), // 매우 연한 골드
          'border': const Color(0xFFF59E0B), // 모던 앰버
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFFF59E0B),
        };
      case 'preview':
        return {
          'background': const Color(0xFFF0FDF4), // 매우 연한 에메랄드
          'border': const Color(0xFF10B981), // 모던 에메랄드
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFF10B981),
        };
      case 'forgotten':
        return {
          'background': const Color(0xFFFFF7ED), // 매우 연한 오렌지
          'border': const Color(0xFFEA580C), // 모던 오렌지
          'text': const Color(0xFF1F2937), // 다크 그레이
          'icon': const Color(0xFFEA580C),
        };
      default:
        return {
          'background': const Color(0xFFF8FAFC),
          'border': const Color(0xFF6366F1), // 모던 인디고
          'text': const Color(0xFF1F2937),
          'icon': const Color(0xFF6366F1),
        };
    }
  }

  // 복습 버튼 탭 처리
  void _handleReviewTap(String reviewType) {
    switch (reviewType) {
      case 'urgent':
        _showComingSoonDialog(tr('status.game_feature_coming_soon'));
        break;
      case 'recommended':
        _showComingSoonDialog(tr('status.game_feature_coming_soon'));
        break;
      case 'preview':
        _showComingSoonDialog(tr('status.game_feature_coming_soon'));
        break;
      case 'forgotten':
        _showComingSoonDialog(tr('status.game_feature_coming_soon'));
        break;
    }
  }

  // 준비 중 다이얼로그
  void _showComingSoonDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(tr('status.coming_soon')),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('dialog.confirm')),
            ),
          ],
        );
      },
    );
  }
}
