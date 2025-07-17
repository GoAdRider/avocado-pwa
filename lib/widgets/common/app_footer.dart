import 'package:flutter/material.dart';
import '../../utils/i18n/simple_i18n.dart';

class AppFooter extends StatelessWidget {
  final String? customQuote;
  final String? customAuthor;

  const AppFooter({
    super.key,
    this.customQuote,
    this.customAuthor,
  });

  @override
  Widget build(BuildContext context) {
    // 기본 명언들 (나중에 Quote 테이블에서 가져올 예정)
    final defaultQuotes = [
      {'quote': tr('footer.default_quote'), 'author': 'aVocaDo'},
      {'quote': '작은 진전도 진전입니다.', 'author': 'aVocaDo'},
      {'quote': '꾸준함이 재능을 이깁니다.', 'author': 'aVocaDo'},
      {'quote': '오늘의 노력이 내일의 실력이 됩니다.', 'author': 'aVocaDo'},
    ];

    // 현재 시간을 기반으로 명언 선택 (간단한 로테이션)
    final currentQuote = customQuote ??
        defaultQuotes[DateTime.now().hour % defaultQuotes.length]['quote']!;
    final currentAuthor = customAuthor ??
        defaultQuotes[DateTime.now().hour % defaultQuotes.length]['author']!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Center(
        child: _buildResponsiveQuote(context, currentQuote, currentAuthor),
      ),
    );
  }

  Widget _buildResponsiveQuote(
      BuildContext context, String quote, String author) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1024) {
      // 데스크톱: 전체 명언 표시
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            '"$quote" - $author',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey),
        ],
      );
    } else if (screenWidth > 768) {
      // 태블릿: 명언만 표시 (저자는 단축)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            '"$quote" - $author',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey),
        ],
      );
    } else {
      // 모바일: 짧은 버전
      final shortQuote =
          quote.length > 30 ? '${quote.substring(0, 30)}...' : quote;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            '"$shortQuote"',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.lightbulb_outline, size: 14, color: Colors.grey),
        ],
      );
    }
  }
}
