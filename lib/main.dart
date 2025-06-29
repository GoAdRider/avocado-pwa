import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/common/hive_service.dart';
import 'utils/i18n/simple_i18n.dart';

void main() async {
  // Flutter 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 데이터베이스 초기화
  await HiveService.initialize();
  
  // 🚀 간소화된 고성능 JSON 다국어 시스템 초기화 (앱 시작시 모든 JSON 한번에 로드)
  try {
    await SimpleI18n.instance.loadAll();
    print('✅ Simple I18n system initialized successfully');
  } catch (e) {
    print('❌ I18n initialization failed: $e');
    // I18n 실패해도 앱은 계속 실행 (fallback 사용)
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageNotifier.instance,
      builder: (context, _) {
        // 언어 변경시 UI 텍스트만 변경되도록 key 제거
        return MaterialApp(
          title: 'aVocaDo PWA',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
