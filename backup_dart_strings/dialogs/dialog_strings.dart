class DialogStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 단축키 다이얼로그
      'shortcut_dialog_title': '⌨️ 단축키 편집',
      'close': '닫기',
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
      'shortcut_help_title': '💡 단축키 편집 도움말',
      'help_browser_warning': 'PWA 환경에서는 일부 브라우저 단축키와 충돌할 수 있습니다.',
      'help_mobile_note': '모바일에서는 터치 인터페이스를 우선적으로 사용하세요.',
      'help_function_keys': 'F1~F12 키는 PWA에서 권장되는 단축키입니다.',
      
      // 어휘집 추가 다이얼로그
      'add_vocab_dialog_title': '새로운 어휘집 추가하기',
      'drag_drop_instruction': 'CSV 파일을 여기로 드래그하세요',
      'drag_drop_active': '파일을 여기에 놓으세요',
      'csv_only_support': '.csv 파일만 지원됩니다',
      'or_divider': '또는',
      'select_file_button': '파일 선택하기',
      'processing_file': '파일을 처리하고 있습니다...',
      
      // CSV 형식 도움말
      'csv_help_title': 'CSV 파일 형식 안내',
      'help_header_rule': '• 첫 번째 줄은 헤더여야 합니다',
      'help_required_columns': '• 필수 컬럼: TargetVoca, ReferenceVoca',
      'help_optional_columns': '• 선택 컬럼: POS, Type, TargetPronunciation, TargetDesc, ReferenceDesc, TargetEx, ReferenceEx, Favorites',
      'help_encoding': '• UTF-8 인코딩으로 저장해주세요',
      
      // 성공 메시지
      'success_words_added': '성공적으로 {count}개의 단어를 추가했습니다!',
      'vocab_added_success': '어휘집이 성공적으로 추가되었습니다!',
      
      // 오류 메시지
      'error_file_selection': '파일 선택 오류: {error}',
      'error_file_processing': '파일 처리 오류: {error}',
      'error_empty_file': '빈 파일입니다',
      'error_missing_required_columns': '필수 컬럼이 없습니다: TargetVoca, ReferenceVoca',
      'error_no_valid_data': '유효한 데이터가 없습니다',
      
      // 파일 미리보기 관련
      'preview_title': '파일 미리보기',
      'preview_title_with_count': '파일 미리보기 ({count}개)',
      'selected_files': '선택된 파일: {count}개',
      'total_words': '총 단어 수: {count}개',
      'file_list': '파일 목록: {list}',
      'data_preview': '데이터 미리보기:',
      'drag_multiple_files': '여러 CSV 파일을 여기에 드래그하세요',
      'select_files': '파일 선택',
      'help_multiple_files': '• 한 번에 여러 CSV 파일을 선택하거나 드래그할 수 있습니다.',
      
      // 버튼 텍스트
      'import_files_button': '{count}개 파일 가져오기',
      'importing_files': '가져오는 중...',
      
      // 처리 결과 메시지
      'partial_error_message': '일부 파일 처리 오류:\n{errors}\n\n성공: {count}개 단어 가져오기 완료',
      'success_import_message': '성공: 총 {count}개 단어를 {fileCount}개 파일에서 가져왔습니다!',
      'no_processable_files': '처리 가능한 파일이 없습니다.',
      'csv_files_only': 'CSV 파일만 업로드 가능합니다.',
      
      // 중복 처리 메시지
      'duplicate_vocabulary_title': '중복 어휘집 발견',
      'duplicate_vocabulary_message': '"{name}" 어휘집이 이미 존재합니다.\n어떻게 하시겠습니까?',
      'replace_vocabulary': '기존 어휘집 교체',
      'merge_vocabulary': '기존 어휘집에 병합',
      'rename_vocabulary': '새 이름으로 저장',
      'multiple_vocabularies': '{count}개 어휘집',
      'duplicate_list': '중복된 어휘집: {list}',
      
      // 오류 키워드 (상태 메시지 색상 판별용)
      'error_keyword': '오류',
    },
    'EN': {
      // 단축키 다이얼로그
      'shortcut_dialog_title': '⌨️ Shortcut Editing',
      'close': 'Close',
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
      'card_shortcuts_scope': 'Applied to Flashcards, Favorites, Wrong Words, Forgetting Curve Review',
      'game_shortcuts_scope': 'Applied to Lightning, Timing, Puzzle, Challenge games',
      
      // 도움말
      'shortcut_help_title': '💡 Shortcut Editing Help',
      'help_browser_warning': 'Some browser shortcuts may conflict in PWA environment.',
      'help_mobile_note': 'Use touch interface primarily on mobile devices.',
      'help_function_keys': 'F1-F12 keys are recommended shortcuts for PWA.',
      
      // 어휘집 추가 다이얼로그
      'add_vocab_dialog_title': 'Add New Vocabulary',
      'drag_drop_instruction': 'Drag CSV file here',
      'drag_drop_active': 'Drop file here',
      'csv_only_support': 'Only .csv files are supported',
      'or_divider': 'or',
      'select_file_button': 'Select File',
      'processing_file': 'Processing file...',
      
      // CSV 형식 도움말
      'csv_help_title': 'CSV File Format Guide',
      'help_header_rule': '• First row must be header',
      'help_required_columns': '• Required columns: TargetVoca, ReferenceVoca',
      'help_optional_columns': '• Optional columns: POS, Type, TargetPronunciation, TargetDesc, ReferenceDesc, TargetEx, ReferenceEx, Favorites',
      'help_encoding': '• Please save in UTF-8 encoding',
      
      // 성공 메시지
      'success_words_added': 'Successfully added {count} words!',
      'vocab_added_success': 'Vocabulary added successfully!',
      
      // 오류 메시지
      'error_file_selection': 'File selection error: {error}',
      'error_file_processing': 'File processing error: {error}',
      'error_empty_file': 'Empty file',
      'error_missing_required_columns': 'Missing required columns: TargetVoca, ReferenceVoca',
      'error_no_valid_data': 'No valid data found',
      
      // 파일 미리보기 관련
      'preview_title': 'File Preview',
      'preview_title_with_count': 'File Preview ({count} files)',
      'selected_files': 'Selected files: {count}',
      'total_words': 'Total words: {count}',
      'file_list': 'File list: {list}',
      'data_preview': 'Data Preview:',
      'drag_multiple_files': 'Drag multiple CSV files here',
      'select_files': 'Select Files',
      'help_multiple_files': '• You can select or drag multiple CSV files at once.',
      
      // 버튼 텍스트
      'import_files_button': 'Import {count} Files',
      'importing_files': 'Importing...',
      
      // 처리 결과 메시지
      'partial_error_message': 'Some file processing errors:\n{errors}\n\nSuccess: {count} words imported',
      'success_import_message': 'Success: {count} words imported from {fileCount} files!',
      'no_processable_files': 'No processable files.',
      'csv_files_only': 'Only CSV files can be uploaded.',
      
      // 중복 처리 메시지
      'duplicate_vocabulary_title': 'Duplicate Vocabulary Found',
      'duplicate_vocabulary_message': 'Vocabulary "{name}" already exists.\nWhat would you like to do?',
      'replace_vocabulary': 'Replace Existing',
      'merge_vocabulary': 'Merge with Existing',
      'rename_vocabulary': 'Save with New Name',
      'multiple_vocabularies': '{count} vocabularies',
      'duplicate_list': 'Duplicates: {list}',
      
      // 오류 키워드 (상태 메시지 색상 판별용)
      'error_keyword': 'error',
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

    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value.toString());
      });
    }

    return text;
  }

  // 단축키 다이얼로그
  static String get shortcutDialogTitle => get('shortcut_dialog_title');
  static String get dialogTitle => get('shortcut_dialog_title'); // Alias for backward compatibility
  static String get close => get('close');
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
  static String get shortcutHelpTitle => get('shortcut_help_title');
  static String get helpBrowserWarning => get('help_browser_warning');
  static String get helpMobileNote => get('help_mobile_note');
  static String get helpFunctionKeys => get('help_function_keys');

  // 어휘집 추가 다이얼로그
  static String get addVocabDialogTitle => get('add_vocab_dialog_title');
  static String get dragDropInstruction => get('drag_drop_instruction');
  static String get dragDropActive => get('drag_drop_active');
  static String get csvOnlySupport => get('csv_only_support');
  static String get orDivider => get('or_divider');
  static String get selectFileButton => get('select_file_button');
  static String get processingFile => get('processing_file');

  // CSV 형식 도움말
  static String get csvHelpTitle => get('csv_help_title');
  static String get helpTitle => get('csv_help_title'); // Alias for backward compatibility
  static String get helpHeaderRule => get('help_header_rule');
  static String get helpRequiredColumns => get('help_required_columns');
  static String get helpOptionalColumns => get('help_optional_columns');
  static String get helpEncoding => get('help_encoding');

  // 성공 메시지
  static String successWordsAdded(int count) =>
      get('success_words_added', params: {'count': count});
  static String get vocabAddedSuccess => get('vocab_added_success');

  // 오류 메시지
  static String errorFileSelection(String error) =>
      get('error_file_selection', params: {'error': error});
  static String errorFileProcessing(String error) =>
      get('error_file_processing', params: {'error': error});
  static String get errorEmptyFile => get('error_empty_file');
  static String get errorMissingRequiredColumns =>
      get('error_missing_required_columns');
  static String get errorNoValidData => get('error_no_valid_data');

  // 파일 미리보기 관련
  static String get previewTitle => get('preview_title');
  static String previewTitleWithCount(int count) =>
      get('preview_title_with_count', params: {'count': count});
  static String selectedFiles(int count) =>
      get('selected_files', params: {'count': count});
  static String totalWords(int count) =>
      get('total_words', params: {'count': count});
  static String fileList(String list) =>
      get('file_list', params: {'list': list});
  static String get dataPreview => get('data_preview');
  static String get dragMultipleFiles => get('drag_multiple_files');
  static String get selectFiles => get('select_files');
  static String get helpMultipleFiles => get('help_multiple_files');

  // 버튼 텍스트
  static String importFilesButton(int count) =>
      get('import_files_button', params: {'count': count});
  static String get importingFiles => get('importing_files');

  // 처리 결과 메시지
  static String partialErrorMessage(String errors, int count) =>
      get('partial_error_message', params: {'errors': errors, 'count': count});
  static String successImportMessage(int count, int fileCount) =>
      get('success_import_message',
          params: {'count': count, 'fileCount': fileCount});
  static String get noProcessableFiles => get('no_processable_files');
  static String get csvFilesOnly => get('csv_files_only');

  // 중복 처리 관련
  static String get duplicateVocabularyTitle =>
      get('duplicate_vocabulary_title');
  static String duplicateVocabularyMessage(String name) =>
      get('duplicate_vocabulary_message', params: {'name': name});
  static String get replaceVocabulary => get('replace_vocabulary');
  static String get mergeVocabulary => get('merge_vocabulary');
  static String get renameVocabulary => get('rename_vocabulary');
  static String multipleVocabularies(int count) =>
      get('multiple_vocabularies', params: {'count': count});
  static String duplicateList(String list) =>
      get('duplicate_list', params: {'list': list});

  // 오류 키워드 (상태 메시지 색상 판별용)
  static String get errorKeyword => get('error_keyword');
}