import 'dart:async';
import 'package:flutter/foundation.dart';
import '../common/daily_study_time_service.dart';

/// 학습 시간 타이머를 관리하는 서비스
/// 카드별 10초 제한 및 총 학습 시간 추적
class StudyTimerService {
  static StudyTimerService? _instance;
  static StudyTimerService get instance => _instance ??= StudyTimerService._internal();
  StudyTimerService._internal();

  final DailyStudyTimeService _dailyTimeService = DailyStudyTimeService.instance;
  
  // 타이머 관련 변수들
  Timer? _studyTimer;
  Duration _totalStudyTime = Duration.zero;
  Duration _currentCardTime = Duration.zero;
  DateTime? _currentCardStartTime;
  bool _isMainTimerActive = true;
  
  // 스트림 컨트롤러
  final StreamController<StudyTimeState> _timeStateController = StreamController<StudyTimeState>.broadcast();
  
  /// 학습 시간 상태 스트림
  Stream<StudyTimeState> get timeStateStream => _timeStateController.stream;
  
  /// 현재 타이머 상태 getter
  StudyTimeState get currentState => StudyTimeState(
    totalStudyTime: _totalStudyTime,
    currentCardTime: _currentCardTime,
    isMainTimerActive: _isMainTimerActive,
  );
  
  /// 타이머 시작
  void startTimer() {
    _startCardTimer();
    
    _studyTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      
      if (_isMainTimerActive && _currentCardStartTime != null) {
        _currentCardTime = now.difference(_currentCardStartTime!);
        
        // 현재 카드에서 정확히 10초 경과 체크
        if (_currentCardTime.inSeconds >= 10) {
          _isMainTimerActive = false;
          _currentCardTime = const Duration(seconds: 10); // 정확히 10초로 제한
          _totalStudyTime = _totalStudyTime + _currentCardTime;
          debugPrint('⏱️ 정확히 10초에서 타이머 정지');
        } else {
          // 1초마다 UI 업데이트 및 당일 누적 시간 업데이트
          if (_currentCardTime.inMilliseconds % 1000 < 100) {
            final currentSessionTime = _totalStudyTime + _currentCardTime;
            _dailyTimeService.updateCurrentTime(currentSessionTime);
          }
        }
        
        // 상태 업데이트
        _timeStateController.add(currentState);
      }
    });
    
    debugPrint('⏱️ 학습 시간 타이머 시작');
  }
  
  /// 새 카드 타이머 시작
  void startNewCard() {
    // 이전 카드에서 사용한 시간을 총 시간에 누적
    if (!_isMainTimerActive) {
      // 정지된 상태에서 카드 이동하는 경우 (이미 10초 누적됨)
      debugPrint('🎯 정지된 상태에서 카드 이동');
    } else if (_currentCardStartTime != null) {
      // 10초 전에 카드 이동하는 경우
      _totalStudyTime = _totalStudyTime + _currentCardTime;
      debugPrint('🎯 ${_currentCardTime.inSeconds}초에서 카드 이동');
    }
    
    _startCardTimer();
  }
  
  /// 현재 카드 타이머 시작
  void _startCardTimer() {
    _currentCardStartTime = DateTime.now();
    _currentCardTime = Duration.zero;
    _isMainTimerActive = true; // 새 카드에서는 타이머 재활성화
    debugPrint('🎯 새 카드 진입 - 타이머 재시작');
  }
  
  /// 타이머 정지
  void stopTimer() {
    _studyTimer?.cancel();
    debugPrint('⏱️ 학습 시간 타이머 정지');
  }
  
  /// 최종 학습 시간 계산 및 반환
  Duration getFinalStudyTime() {
    final finalSessionTime = _totalStudyTime + (_isMainTimerActive ? _currentCardTime : Duration.zero);
    return finalSessionTime;
  }
  
  /// 당일 누적 시간에 최종 학습 시간 추가
  Future<void> addFinalTimeToDaily() async {
    final finalTime = getFinalStudyTime();
    await _dailyTimeService.addStudyTime(finalTime);
    debugPrint('📊 당일 누적 시간에 최종 학습 시간 추가: ${_formatDuration(finalTime)}');
  }
  
  /// 시간 포맷팅
  String formatCurrentTime() {
    final currentTotal = _totalStudyTime + (_isMainTimerActive ? _currentCardTime : Duration.zero);
    final timeText = _formatDuration(currentTotal);
    return _isMainTimerActive ? timeText : '$timeText ⏸';
  }
  
  /// 시간 포맷팅 (HH:MM:SS)
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// 리셋 (새 세션 시작 시)
  void reset() {
    _totalStudyTime = Duration.zero;
    _currentCardTime = Duration.zero;
    _currentCardStartTime = null;
    _isMainTimerActive = true;
    debugPrint('🔄 StudyTimerService 리셋');
  }
  
  /// 서비스 정리
  void dispose() {
    _studyTimer?.cancel();
    _timeStateController.close();
  }
}

/// 학습 시간 상태 클래스
class StudyTimeState {
  final Duration totalStudyTime;
  final Duration currentCardTime;
  final bool isMainTimerActive;
  
  StudyTimeState({
    required this.totalStudyTime,
    required this.currentCardTime,
    required this.isMainTimerActive,
  });
  
  Duration get currentTotal => totalStudyTime + (isMainTimerActive ? currentCardTime : Duration.zero);
  
  String get formattedTime {
    final minutes = currentTotal.inMinutes;
    final seconds = currentTotal.inSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return isMainTimerActive ? timeText : '$timeText ⏸';
  }
}