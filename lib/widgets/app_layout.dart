import 'package:flutter/material.dart';
import 'app_header.dart';
import 'app_footer.dart';
import '../utils/language_provider.dart';
import '../screens/toggle_dialog.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String? customQuote;
  final String? customAuthor;

  const AppLayout({
    super.key,
    required this.child,
    this.customQuote,
    this.customAuthor,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = LanguageProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // 공통 헤더
          AppHeader(
            isKoreanToEnglish: languageProvider?.isKoreanToEnglish ?? true,
            onLanguageToggle: () {
              languageProvider?.toggleLanguage();
            },
            onEditTap: () => _onEditTap(),
            onSettingsTap: () => _onSettingsTap(),
          ),
          // 메인 컨텐츠
          Expanded(child: widget.child),
          // 공통 푸터
          AppFooter(
            customQuote: widget.customQuote,
            customAuthor: widget.customAuthor,
          ),
        ],
      ),
    );
  }

  void _onEditTap() {
    // 토글확인및편집 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: true, // 배경 클릭으로 닫기 가능
      builder: (BuildContext context) {
        return const ToggleDialog();
      },
    );
  }

  void _onSettingsTap() {
    // 설정 기능
    print('설정 클릭');
    // TODO: 설정 화면으로 네비게이션
  }
}
