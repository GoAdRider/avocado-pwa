import 'package:flutter/material.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../../services/home/vocabulary_list/vocabulary_list_service.dart';
import '../../screens/study_screen.dart';
import '../../screens/home_screen.dart';
import '../services/daily_study_time_widget.dart';

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
          GestureDetector(
            onTap: () async {
              debugPrint('🏠 로고 클릭됨 - 상태 초기화 시작');

              try {
                // 현재 화면이 StudyScreen인지 확인
                final currentRoute = ModalRoute.of(context);
                final currentRouteName = currentRoute?.settings.name;

                debugPrint('🏠 현재 라우트: $currentRouteName');

                // 어휘집 선택 상태 초기화 (모든 경우에 실행)
                debugPrint('🏠 어휘집 선택 상태 초기화');
                VocabularyListService.instance.unselectAll();

                // StudyScreen에서 홈으로 갈 때는 StudyScreenController.exitStudy() 사용 (ESC와 동일한 처리)
                if (Navigator.canPop(context) && currentRouteName == '/study') {
                  debugPrint(
                      '🏠 StudyScreen에서 홈버튼 클릭 - StudyScreenController.exitStudy() 호출');
                  StudyScreenController.exitStudy();
                } else if (currentRouteName != '/' &&
                    currentRouteName != '/home') {
                  // 다른 화면에서는 홈으로 이동
                  debugPrint('🏠 일반 화면에서 홈버튼 클릭 - 홈으로 이동');
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                } else {
                  // 이미 홈화면이면 스크롤 최상단으로 이동
                  debugPrint('🏠 홈화면에서 로고 클릭 - 스크롤 최상단 이동');
                  try {
                    // HomeScreen의 전용 scrollToTop 메서드 사용
                    HomeScreen.scrollToTop();
                  } catch (scrollError) {
                    debugPrint('🏠 스크롤 이동 중 오류: $scrollError');
                  }
                }
              } catch (e) {
                debugPrint('🏠 로고 클릭 처리 중 오류: $e');
                // 오류 발생 시 안전하게 홈으로 이동
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: Image.asset(
                      'assets/images/avocado-logo.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 0),
                const Text(
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
          // 당일 누적 공부 시간
          const DailyStudyTimeWidget(),
          const SizedBox(width: 16),
          // 언어 토글 버튼
          GestureDetector(
            onTap: () {
              debugPrint('🌐 언어 토글 버튼 직접 클릭됨');
              onLanguageToggle();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF6B8E23)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 16, color: Color(0xFF6B8E23)),
                  const SizedBox(width: 4),
                  Text(
                    isKoreanToEnglish ? 'KR' : 'EN',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
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
              child: Text(tr('header.edit_toggle'),
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

