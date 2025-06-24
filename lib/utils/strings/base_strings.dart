class BaseStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 헤더 (모든 페이지 공통)
      'app_title': 'aVocaDo',
      'edit_toggle': '단축키편집',
      'settings': '설정',

      // 공통 단위 (모든 페이지에서 사용 가능)
      'words_unit': '개',
      'count_unit': '회',
      'percent_unit': '%',
      'days_unit': '일',

      // 공통 다이얼로그 버튼
      'cancel': '취소',
      'confirm': '확인',
      'delete': '삭제',
      'reset': '초기화',
      'yes': '예',
      'no': '아니오',
      'ok': '확인',
      'close': '닫기',
      'file_select': '파일 선택',
      'confirm_delete': '삭제 확인',
      'confirm_reset': '초기화 확인',
      'save_success': '성공적으로 저장되었습니다!',

      // 공통 푸터
      'default_quote': '배움은 평생의 여정입니다. 매일 조금씩 성장하세요.',

      // 공통 액션
      'select_all': '전체선택',
      'deselect_all': '전체해제',
      'export': '내보내기',
      'select_all_filter': '모두선택',
      'deselect_all_filter': '모두해제',
      'start': '시작하기',

      // 구현 상태 메시지
      'coming_soon': '구현 예정',
      'feature_coming_soon': '이 기능은 곧 구현될 예정입니다.',
      'game_feature_coming_soon': '게임 기반 학습 기능이 곧 추가됩니다!',
    },
    'EN': {
      // 헤더 (모든 페이지 공통)
      'app_title': 'aVocaDo',
      'edit_toggle': 'Shortcuts',
      'settings': 'Settings',

      // 공통 단위 (모든 페이지에서 사용 가능)
      'words_unit': '',
      'count_unit': ' times',
      'percent_unit': '%',
      'days_unit': ' days',

      // 공통 다이얼로그 버튼
      'cancel': 'Cancel',
      'confirm': 'OK',
      'delete': 'Delete',
      'reset': 'Reset',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'close': 'Close',
      'file_select': 'Select File',
      'confirm_delete': 'Confirm Delete',
      'confirm_reset': 'Confirm Reset',
      'save_success': 'Successfully saved!',

      // 공통 푸터
      'default_quote':
          'Learning is a lifelong journey. Grow a little every day.',

      // 공통 액션
      'select_all': 'Select All',
      'deselect_all': 'Deselect All',
      'export': 'Export',
      'select_all_filter': 'Select All',
      'deselect_all_filter': 'Deselect All',
      'start': 'Start',

      // 구현 상태 메시지
      'coming_soon': 'Coming Soon',
      'feature_coming_soon': 'This feature will be implemented soon.',
      'game_feature_coming_soon': 'Game-based learning features coming soon!',
    },
  };

  static String _currentLanguage = 'KR';

  static void setLanguage(String language) {
    if (_strings.containsKey(language)) {
      _currentLanguage = language;
    }
  }

  static String get currentLanguage => _currentLanguage;

  static String get(String key, {Map<String, dynamic>? params}) {
    String text = _strings[_currentLanguage]?[key] ?? key;

    // 매개변수가 있으면 치환
    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value.toString());
      });
    }

    return text;
  }

  // 헤더 관련
  static String get appTitle => get('app_title');
  static String get editToggle => get('edit_toggle');
  static String get settings => get('settings');

  // 공통 단위
  static String get wordsUnit => get('words_unit');
  static String get countUnit => get('count_unit');
  static String get percentUnit => get('percent_unit');
  static String get daysUnit => get('days_unit');

  // 공통 다이얼로그
  static String get cancel => get('cancel');
  static String get confirm => get('confirm');
  static String get delete => get('delete');
  static String get reset => get('reset');
  static String get yes => get('yes');
  static String get no => get('no');
  static String get ok => get('ok');
  static String get close => get('close');
  static String get fileSelect => get('file_select');
  static String get confirmDelete => get('confirm_delete');
  static String get confirmReset => get('confirm_reset');
  static String get saveSuccess => get('save_success');

  // 공통 푸터
  static String get defaultQuote => get('default_quote');

  // 공통 액션
  static String get selectAll => get('select_all');
  static String get deselectAll => get('deselect_all');
  static String get export => get('export');
  static String get selectAllFilter => get('select_all_filter');
  static String get deselectAllFilter => get('deselect_all_filter');
  static String get start => get('start');

  // 구현 상태 메시지
  static String get comingSoon => get('coming_soon');
  static String get featureComingSoon => get('feature_coming_soon');
  static String get gameFeatureComingSoon => get('game_feature_coming_soon');
}
