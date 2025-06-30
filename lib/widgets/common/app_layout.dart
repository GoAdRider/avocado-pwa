import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_header.dart';
import 'app_footer.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../dialogs/shortcut_dialog.dart';

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
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          return _handleGlobalKeyEvent(event)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        },
        child: ListenableBuilder(
          listenable: LanguageNotifier.instance,
          builder: (context, _) {
            return Column(
              children: [
                // 공통 헤더
                AppHeader(
                  isKoreanToEnglish: isKorean,
                  onLanguageToggle: () {
                    debugPrint('🌐 언어 토글 버튼 클릭됨');
                    LanguageNotifier.instance.toggle();
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
            );
          },
        ),
      ),
    );
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.f1:
        _onEditTap();
        return true;
      case LogicalKeyboardKey.f2:
        _onSettingsTap();
        return true;
      default:
        return false;
    }
  }

  void _onEditTap() {
    // 토글확인및편집 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: true, // 배경 클릭으로 닫기 가능
      builder: (BuildContext context) {
        return const ShortcutDialog();
      },
    );
  }

  void _onSettingsTap() {
    // 설정 기능
    print('설정 클릭');
    // TODO: 설정 화면으로 네비게이션
  }
}
