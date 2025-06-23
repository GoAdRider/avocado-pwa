import 'package:flutter/material.dart';
import 'strings/base_strings.dart';
import 'strings/home_strings.dart';

class LanguageProvider extends InheritedWidget {
  final String currentLanguage;
  final bool isKoreanToEnglish;
  final VoidCallback toggleLanguage;

  const LanguageProvider({
    super.key,
    required this.currentLanguage,
    required this.isKoreanToEnglish,
    required this.toggleLanguage,
    required super.child,
  });

  static LanguageProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LanguageProvider>();
  }

  @override
  bool updateShouldNotify(LanguageProvider oldWidget) {
    return currentLanguage != oldWidget.currentLanguage ||
        isKoreanToEnglish != oldWidget.isKoreanToEnglish;
  }
}

class LanguageManager extends StatefulWidget {
  final Widget child;

  const LanguageManager({super.key, required this.child});

  @override
  State<LanguageManager> createState() => _LanguageManagerState();
}

class _LanguageManagerState extends State<LanguageManager> {
  String _currentLanguage = 'KR';
  bool _isKoreanToEnglish = true;

  void _toggleLanguage() {
    setState(() {
      _isKoreanToEnglish = !_isKoreanToEnglish;
      _currentLanguage = _isKoreanToEnglish ? 'KR' : 'EN';
      BaseStrings.setLanguage(_currentLanguage);
      HomeStrings.setLanguage(_currentLanguage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LanguageProvider(
      currentLanguage: _currentLanguage,
      isKoreanToEnglish: _isKoreanToEnglish,
      toggleLanguage: _toggleLanguage,
      child: widget.child,
    );
  }
}
