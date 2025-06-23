class ToggleStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 다이얼로그 제목 및 기본
      'dialog_title': '⌨️ 단축키 편집',
      'close': '닫기',

      // 단축키 편집 섹션
      'shortcut_section': '⌨️ 단축키 편집',
      'system_shortcuts': '시스템 단축키 (편집 불가)',
      'card_shortcuts': '카드형 학습 단축키',
      'game_shortcuts': '게임 전용 단축키',

      // 시스템 단축키 (편집 불가능)
      'toggle_edit_key': 'F1',
      'toggle_edit_desc': '토글확인및편집',
      'study_end_key': 'F12',
      'study_end_desc': '학습 종료',
      'escape_key': 'Esc',
      'escape_desc': '취소/이전화면',

      // 카드형 학습 단축키 (편집 가능)
      'card_flip_key': 'Space',
      'card_flip_desc': '카드 뒤집기',
      'previous_card_key': '←',
      'previous_card_desc': '이전 카드',
      'next_card_key': '→',
      'next_card_desc': '다음 카드',
      'favorite_toggle_key': 'S',
      'favorite_toggle_desc': '즐겨찾기 토글',
      'detail_toggle_key': 'D',
      'detail_toggle_desc': '상세정보 토글',
      'shuffle_key': 'R',
      'shuffle_desc': '순서 섞기',
      'remove_key': 'Delete',
      'remove_desc': '임시 제거 (세션 동안만)',

      // 게임 전용 단축키 (편집 가능)
      'beginner_hint_key': 'F6',
      'beginner_hint_desc': '초급 힌트',
      'intermediate_hint_key': 'F7',
      'intermediate_hint_desc': '중급 힌트',
      'advanced_hint_key': 'F8',
      'advanced_hint_desc': '고급 힌트',
      'game_pause_key': 'F10',
      'game_pause_desc': '게임 일시정지',
      'answer_submit_key': 'Enter',
      'answer_submit_desc': '정답 제출',

      // 단축키 편집 관련
      'edit_button': '편집',
      'editing_key': '키를 눌러주세요...',
      'key_conflict': '이미 사용중인 키입니다',
      'invalid_key': '사용할 수 없는 키입니다',
      'reset_category': '기본값 복원',
      'reset_card_shortcuts': '카드형 학습 단축키 복원',
      'reset_game_shortcuts': '게임 단축키 복원',
      'reset_all_shortcuts': '모든 단축키 복원',

      // 적용 범위 설명
      'card_shortcuts_scope': '단어카드, 즐겨찾기, 틀린단어, 망각곡선 복습에 적용',
      'game_shortcuts_scope': 'Lightning, Timing, Puzzle, Challenge 게임에 적용',

      // 도움말
      'help_title': '💡 단축키 편집 도움말',
      'help_browser_warning': 'PWA 환경에서는 일부 브라우저 단축키와 충돌할 수 있습니다.',
      'help_mobile_note': '모바일에서는 터치 인터페이스를 우선적으로 사용하세요.',
      'help_function_keys': 'F1~F12 키는 PWA에서 권장되는 단축키입니다.',
    },
    'EN': {
      // 다이얼로그 제목 및 기본
      'dialog_title': '⌨️ Shortcut Editing',
      'close': 'Close',

      // 단축키 편집 섹션
      'shortcut_section': '⌨️ Shortcut Editing',
      'system_shortcuts': 'System Shortcuts (Read-only)',
      'card_shortcuts': 'Card-based Learning Shortcuts',
      'game_shortcuts': 'Game-only Shortcuts',

      // 시스템 단축키 (편집 불가능)
      'toggle_edit_key': 'F1',
      'toggle_edit_desc': 'Toggle Check & Edit',
      'study_end_key': 'F12',
      'study_end_desc': 'End Study',
      'escape_key': 'Esc',
      'escape_desc': 'Cancel/Previous',

      // 카드형 학습 단축키 (편집 가능)
      'card_flip_key': 'Space',
      'card_flip_desc': 'Flip Card',
      'previous_card_key': '←',
      'previous_card_desc': 'Previous Card',
      'next_card_key': '→',
      'next_card_desc': 'Next Card',
      'favorite_toggle_key': 'S',
      'favorite_toggle_desc': 'Toggle Favorite',
      'detail_toggle_key': 'D',
      'detail_toggle_desc': 'Toggle Details',
      'shuffle_key': 'R',
      'shuffle_desc': 'Shuffle Order',
      'remove_key': 'Delete',
      'remove_desc': 'Temporary Remove (Session Only)',

      // 게임 전용 단축키 (편집 가능)
      'beginner_hint_key': 'F6',
      'beginner_hint_desc': 'Beginner Hint',
      'intermediate_hint_key': 'F7',
      'intermediate_hint_desc': 'Intermediate Hint',
      'advanced_hint_key': 'F8',
      'advanced_hint_desc': 'Advanced Hint',
      'game_pause_key': 'F10',
      'game_pause_desc': 'Pause Game',
      'answer_submit_key': 'Enter',
      'answer_submit_desc': 'Submit Answer',

      // 단축키 편집 관련
      'edit_button': 'Edit',
      'editing_key': 'Press a key...',
      'key_conflict': 'Key already in use',
      'invalid_key': 'Invalid key',
      'reset_category': 'Reset to Default',
      'reset_card_shortcuts': 'Reset Card Shortcuts',
      'reset_game_shortcuts': 'Reset Game Shortcuts',
      'reset_all_shortcuts': 'Reset All Shortcuts',

      // 적용 범위 설명
      'card_shortcuts_scope':
          'Applied to Flashcards, Favorites, Wrong Words, Forgetting Curve Review',
      'game_shortcuts_scope':
          'Applied to Lightning, Timing, Puzzle, Challenge games',

      // 도움말
      'help_title': '💡 Shortcut Editing Help',
      'help_browser_warning':
          'Some browser shortcuts may conflict in PWA environment.',
      'help_mobile_note': 'Use touch interface primarily on mobile devices.',
      'help_function_keys': 'F1-F12 keys are recommended shortcuts for PWA.',
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

  // 다이얼로그 기본
  static String get dialogTitle => get('dialog_title');
  static String get close => get('close');

  // 단축키 편집
  static String get shortcutSection => get('shortcut_section');
  static String get systemShortcuts => get('system_shortcuts');
  static String get cardShortcuts => get('card_shortcuts');
  static String get gameShortcuts => get('game_shortcuts');

  // 시스템 단축키
  static String get toggleEditKey => get('toggle_edit_key');
  static String get toggleEditDesc => get('toggle_edit_desc');
  static String get studyEndKey => get('study_end_key');
  static String get studyEndDesc => get('study_end_desc');
  static String get escapeKey => get('escape_key');
  static String get escapeDesc => get('escape_desc');

  // 카드형 학습 단축키
  static String get cardFlipKey => get('card_flip_key');
  static String get cardFlipDesc => get('card_flip_desc');
  static String get previousCardKey => get('previous_card_key');
  static String get previousCardDesc => get('previous_card_desc');
  static String get nextCardKey => get('next_card_key');
  static String get nextCardDesc => get('next_card_desc');
  static String get favoriteToggleKey => get('favorite_toggle_key');
  static String get favoriteToggleDesc => get('favorite_toggle_desc');
  static String get detailToggleKey => get('detail_toggle_key');
  static String get detailToggleDesc => get('detail_toggle_desc');
  static String get shuffleKey => get('shuffle_key');
  static String get shuffleDesc => get('shuffle_desc');
  static String get removeKey => get('remove_key');
  static String get removeDesc => get('remove_desc');

  // 게임 전용 단축키
  static String get beginnerHintKey => get('beginner_hint_key');
  static String get beginnerHintDesc => get('beginner_hint_desc');
  static String get intermediateHintKey => get('intermediate_hint_key');
  static String get intermediateHintDesc => get('intermediate_hint_desc');
  static String get advancedHintKey => get('advanced_hint_key');
  static String get advancedHintDesc => get('advanced_hint_desc');
  static String get gamePauseKey => get('game_pause_key');
  static String get gamePauseDesc => get('game_pause_desc');
  static String get answerSubmitKey => get('answer_submit_key');
  static String get answerSubmitDesc => get('answer_submit_desc');

  // 편집 관련
  static String get editButton => get('edit_button');
  static String get editingKey => get('editing_key');
  static String get keyConflict => get('key_conflict');
  static String get invalidKey => get('invalid_key');
  static String get resetCategory => get('reset_category');
  static String get resetCardShortcuts => get('reset_card_shortcuts');
  static String get resetGameShortcuts => get('reset_game_shortcuts');
  static String get resetAllShortcuts => get('reset_all_shortcuts');

  // 적용 범위
  static String get cardShortcutsScope => get('card_shortcuts_scope');
  static String get gameShortcutsScope => get('game_shortcuts_scope');

  // 도움말
  static String get helpTitle => get('help_title');
  static String get helpBrowserWarning => get('help_browser_warning');
  static String get helpMobileNote => get('help_mobile_note');
  static String get helpFunctionKeys => get('help_function_keys');
}
