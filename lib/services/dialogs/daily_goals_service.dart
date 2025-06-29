import 'package:hive/hive.dart';

/// 일일 목표 데이터 모델
class DailyGoals {
  final int dailyNewWords;
  final int dailyReviewWords; 
  final int dailyPerfectAnswers;
  final int weeklyGoal;
  final int monthlyGoal;

  const DailyGoals({
    required this.dailyNewWords,
    required this.dailyReviewWords,
    required this.dailyPerfectAnswers,
    required this.weeklyGoal,
    required this.monthlyGoal,
  });

  /// 기본 목표 값
  factory DailyGoals.defaultGoals() {
    return const DailyGoals(
      dailyNewWords: 20,
      dailyReviewWords: 10,
      dailyPerfectAnswers: 12,
      weeklyGoal: 300,
      monthlyGoal: 1200,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyNewWords': dailyNewWords,
      'dailyReviewWords': dailyReviewWords,
      'dailyPerfectAnswers': dailyPerfectAnswers,
      'weeklyGoal': weeklyGoal,
      'monthlyGoal': monthlyGoal,
    };
  }

  factory DailyGoals.fromMap(Map<String, dynamic> map) {
    return DailyGoals(
      dailyNewWords: map['dailyNewWords'] ?? 20,
      dailyReviewWords: map['dailyReviewWords'] ?? 10,
      dailyPerfectAnswers: map['dailyPerfectAnswers'] ?? 12,
      weeklyGoal: map['weeklyGoal'] ?? 300,
      monthlyGoal: map['monthlyGoal'] ?? 1200,
    );
  }
}

/// 일일 목표 관리 서비스
class DailyGoalsService {
  static DailyGoalsService? _instance;
  static DailyGoalsService get instance => _instance ??= DailyGoalsService._internal();
  DailyGoalsService._internal();

  static const String _boxName = 'daily_goals';
  static const String _goalsKey = 'current_goals';

  Box? _box;

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox(_boxName);
      print('✅ DailyGoalsService 초기화 완료');
    } catch (e) {
      print('❌ DailyGoalsService 초기화 실패: $e');
    }
  }

  /// 현재 목표 가져오기
  DailyGoals getCurrentGoals() {
    if (_box == null) {
      print('⚠️ DailyGoalsService가 초기화되지 않음 - 기본값 반환');
      return DailyGoals.defaultGoals();
    }

    try {
      final data = _box!.get(_goalsKey);
      if (data == null) {
        return DailyGoals.defaultGoals();
      }
      
      return DailyGoals.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      print('❌ 목표 로드 실패: $e');
      return DailyGoals.defaultGoals();
    }
  }

  /// 목표 저장
  Future<void> saveGoals(DailyGoals goals) async {
    if (_box == null) {
      print('⚠️ DailyGoalsService가 초기화되지 않음 - 저장 실패');
      return;
    }

    try {
      await _box!.put(_goalsKey, goals.toMap());
      print('✅ 목표 저장 완료: $goals');
    } catch (e) {
      print('❌ 목표 저장 실패: $e');
    }
  }

  /// 목표 초기화
  Future<void> resetGoals() async {
    await saveGoals(DailyGoals.defaultGoals());
  }

  /// 서비스 정리
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}