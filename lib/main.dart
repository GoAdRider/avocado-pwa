import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/language_provider.dart';
import 'services/hive_service.dart';

void main() async {
  // Flutter 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 데이터베이스 초기화
  await HiveService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageManager(
      child: MaterialApp(
        title: 'aVocaDo PWA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
