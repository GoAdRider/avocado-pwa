import 'package:flutter/material.dart';
import '../utils/strings/base_strings.dart';

class AppHeader extends StatelessWidget {
  final bool isKoreanToEnglish;
  final VoidCallback onLanguageToggle;
  final VoidCallback onEditTap;
  final VoidCallback onSettingsTap;

  const AppHeader({
    super.key,
    required this.isKoreanToEnglish,
    required this.onLanguageToggle,
    required this.onEditTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          // 로고 (링크버튼)
          InkWell(
            onTap: () {
              // 홈으로 이동 - 현재 페이지가 홈이 아닐 때만 네비게이션
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🥑', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  'aVocaDo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B8E23),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 언어 토글 버튼
          InkWell(
            onTap: onLanguageToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF6B8E23)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isKoreanToEnglish ? '🌐KR' : '🌐EN',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 토글확인및편집 버튼
          InkWell(
            onTap: onEditTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(BaseStrings.editToggle,
                  style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          // 설정 버튼
          InkWell(
            onTap: onSettingsTap,
            child: const Icon(Icons.settings, size: 24),
          ),
        ],
      ),
    );
  }
}
