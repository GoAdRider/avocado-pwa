import 'dart:async';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';

/// 당일 누적 공부 시간을 관리하는 서비스
class DailyStudyTimeService {
  static DailyStudyTimeService? _instance;
  static DailyStudyTimeService get instance => _instance ??= DailyStudyTimeService._internal();
  DailyStudyTimeService._internal();

  final HiveService _hiveService = HiveService.instance;
  final StreamController<Duration> _dailyTimeController = StreamController<Duration>.broadcast();
  
  /// 당일 누적 시간 스트림
  Stream<Duration> get dailyTimeStream => _dailyTimeController.stream;
  
  static const String _dailyTimeBoxKey = 'daily_study_times';
  
  /// 오늘 날짜 키 생성
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  /// 당일 누적 시간 조회
  Duration getTodayStudyTime() {
    try {
      final box = _hiveService.generalBox;
      final todayKey = _getTodayKey();
      final seconds = box.get('$_dailyTimeBoxKey:$todayKey', defaultValue: 0) as int;
      return Duration(seconds: seconds);
    } catch (e) {
      debugPrint('❌ 당일 학습 시간 조회 실패: $e');
      return Duration.zero;
    }
  }
  
  /// 학습 시간 추가 (세션 종료시 호출)
  Future<void> addStudyTime(Duration sessionTime) async {
    try {
      final box = _hiveService.generalBox;
      final todayKey = _getTodayKey();
      final boxKey = '$_dailyTimeBoxKey:$todayKey';
      
      final currentSeconds = box.get(boxKey, defaultValue: 0) as int;
      final newSeconds = currentSeconds + sessionTime.inSeconds;
      
      await box.put(boxKey, newSeconds);
      
      final newTotalTime = Duration(seconds: newSeconds);
      _dailyTimeController.add(newTotalTime);
      
      debugPrint('📊 당일 학습 시간 업데이트: ${_formatDuration(sessionTime)} 추가 → 총 ${_formatDuration(newTotalTime)}');
    } catch (e) {
      debugPrint('❌ 당일 학습 시간 저장 실패: $e');
    }
  }
  
  /// 실시간 시간 업데이트 (학습 중 호출)
  void updateCurrentTime(Duration sessionTime) {
    final todayBase = getTodayStudyTime();
    final currentTotal = todayBase + sessionTime;
    _dailyTimeController.add(currentTotal);
  }
  
  /// 시간 포맷팅 (HH:MM:SS 형식)
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// 오늘의 누적 시간 포맷팅
  String formatTodayTime() {
    return _formatDuration(getTodayStudyTime());
  }
  
  /// 현재 총 시간 포맷팅 (기존 + 현재 세션)
  String formatCurrentTotalTime(Duration sessionTime) {
    final total = getTodayStudyTime() + sessionTime;
    return _formatDuration(total);
  }
  
  /// 1분 이상 학습했는지 확인 (연속학습 판정용)
  bool hasStudiedOverOneMinute() {
    return getTodayStudyTime().inMinutes >= 1;
  }
  
  /// 이전 날짜 데이터 정리 (일주일 이상 된 데이터 삭제)
  Future<void> cleanupOldData() async {
    try {
      final box = _hiveService.generalBox;
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      final keysToDelete = <String>[];
      
      for (final key in box.keys) {
        if (key.toString().startsWith(_dailyTimeBoxKey)) {
          try {
            final dateStr = key.toString().split(':')[1];
            final dateParts = dateStr.split('-');
            final date = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );
            
            if (date.isBefore(weekAgo)) {
              keysToDelete.add(key.toString());
            }
          } catch (e) {
            // 잘못된 형식의 키는 삭제
            keysToDelete.add(key.toString());
          }
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      
      if (keysToDelete.isNotEmpty) {
        debugPrint('🧹 오래된 학습 시간 데이터 정리: ${keysToDelete.length}개');
      }
    } catch (e) {
      debugPrint('❌ 오래된 데이터 정리 실패: $e');
    }
  }
  
  void dispose() {
    _dailyTimeController.close();
  }
}