import 'package:flutter/services.dart';
import 'study_session_manager.dart';
import 'study_timer_service.dart';

/// 학습 화면의 키보드 단축키를 관리하는 서비스
class StudyKeyboardService {
  static StudyKeyboardService? _instance;
  static StudyKeyboardService get instance => _instance ??= StudyKeyboardService._internal();
  StudyKeyboardService._internal();

  final StudySessionManager _sessionManager = StudySessionManager.instance;
  final StudyTimerService _timerService = StudyTimerService.instance;

  // 콜백 함수들
  Function()? _onExitStudy;
  Function()? _onShowWordDeleteDialog;
  Function()? _onToggleDetails;
  
  String _studyModePreference = 'TargetVoca';

  /// 콜백 함수 등록
  void registerCallbacks({
    Function()? onExitStudy,
    Function()? onShowWordDeleteDialog,
    Function()? onToggleDetails,
    String studyModePreference = 'TargetVoca',
  }) {
    _onExitStudy = onExitStudy;
    _onShowWordDeleteDialog = onShowWordDeleteDialog;
    _onToggleDetails = onToggleDetails;
    _studyModePreference = studyModePreference;
  }

  /// 키보드 이벤트 처리
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _goToPrevious();
        return true;
      case LogicalKeyboardKey.arrowRight:
        _goToNext();
        return true;
      case LogicalKeyboardKey.space:
        _flipCard();
        return true;
      case LogicalKeyboardKey.keyR:
        _shuffleWords();
        return true;
      case LogicalKeyboardKey.keyS:
        _toggleFavorite();
        return true;
      case LogicalKeyboardKey.keyD:
        _toggleDetails();
        return true;
      case LogicalKeyboardKey.escape:
        _exitStudy();
        return true;
      case LogicalKeyboardKey.delete:
        _showWordDeleteDialog();
        return true;
      default:
        return false;
    }
  }

  /// 이전 카드로 이동
  void _goToPrevious() {
    _sessionManager.goToPrevious(_studyModePreference);
    _timerService.startNewCard();
  }

  /// 다음 카드로 이동
  void _goToNext() {
    final session = _sessionManager.currentSession;
    if (session == null) return;
    
    if (session.canGoNext) {
      _sessionManager.goToNext(_studyModePreference);
      _timerService.startNewCard();
    } else if (session.currentIndex == session.words.length - 1) {
      // 마지막 단어에서 다음 버튼을 누르면 완료 처리
      // 이 처리는 StudyScreen에서 별도 처리
    }
  }

  /// 카드 뒤집기
  void _flipCard() {
    _sessionManager.flipCard();
  }

  /// 단어 섞기
  void _shuffleWords() {
    _sessionManager.shuffleWords(_studyModePreference);
  }

  /// 즐겨찾기 토글
  Future<void> _toggleFavorite() async {
    await _sessionManager.toggleFavorite();
  }

  /// 세부사항 토글
  void _toggleDetails() {
    if (_onToggleDetails != null) {
      _onToggleDetails!();
    } else {
      _sessionManager.toggleDetails();
    }
  }

  /// 학습 종료
  void _exitStudy() {
    _onExitStudy?.call();
  }

  /// 단어 삭제 다이얼로그 표시
  void _showWordDeleteDialog() {
    _onShowWordDeleteDialog?.call();
  }

  /// 키보드 단축키 안내 텍스트 생성
  String getKeyboardGuideText() {
    return '← → : 이전/다음 카드 | Space : 뒤집기 | R : 섞기 | S : 즐겨찾기 | D : 세부사항 | ESC : 종료 | Del : 삭제';
  }

  /// 키보드 단축키 맵 반환
  Map<String, String> getKeyboardShortcuts() {
    return {
      '← →': '이전/다음 카드',
      'Space': '카드 뒤집기',
      'R': '단어 섞기',
      'S': '즐겨찾기 토글',
      'D': '세부사항 토글',
      'ESC': '학습 종료',
      'Del': '단어 삭제',
    };
  }
}