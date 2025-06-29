class VocabularyListStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 어휘집 섹션
      'section_vocab_selection': '📚 어휘집 선택',
      'vocabulary_list_title': '📚 어휘집 목록',
      
      // 어휘집 관련
      'selected_vocab_info':
          '선택된 어휘집: 📝{count}개 ⭐{favorites}개 ❌{wrong}개 🔢{wrongCount}회',
      'vocab_info_guide': '📖 어휘집 정보 가이드: 📝단어수 ⭐즐겨찾기 ❌틀린단어 🔢틀린횟수 📅최근학습',
      'add_new_vocab': '새로운 어휘집\n추가하기',
      'add_new_vocabulary': '새로운 어휘집\n추가하기',
      'selected_vocabularies': '선택된 어휘집',
      'no_vocab_message': '어휘집을 추가하시면 여기에 표시됩니다.',
      
      // 버튼들
      'select_clear': '✅선택지우기',
      'clear_all': '🗑️전체지우기',
      'single_select': '☐단일선택',
      'multi_select': '✅다중선택',
      'reset_wrong_count': '🧹틀린횟수 초기화',
      'reset_favorites': '⭐즐겨찾기 초기화',
      
      // 모드 관련
      'multi_select_mode': '다중선택 모드',
      'single_select_mode': '단일선택 모드',
      'select_all': '전체선택',
      'unselect_all': '전체해제',
      'delete_button': '삭제',
      'export_button': '내보내기',
      'reset_wrong_counts': '틀린횟수 초기화',
      'reset_favorites_button': '즐겨찾기 초기화',
      'reset_wrong_counts_button': '틀린횟수 초기화',
      
      // 도움말
      'help_title': '어휘집 관리 도움말',
      'help_tooltip': '도움말',
      'vocabulary_list_help': '''📚 어휘집 관리 가이드:

🔹 어휘집 선택:
• 탭하여 단일 선택
• 길게 눌러서 다중 선택 모드 진입

🔹 관리 기능:
• ✅ 전체선택 / ❌ 전체해제
• 🗑️ 선택된 어휘집 삭제
• 📤 CSV 형태로 내보내기
• 🧹 틀린횟수 초기화
• ⭐ 즐겨찾기 초기화

📊 어휘집 정보:
• 📝 단어수: 총 단어 개수
• ⭐ 즐겨찾기: 즐겨찾기 단어 수
• ❌ 틀린단어: 틀린 단어 수
• 🔢 틀린횟수: 총 틀린 횟수

📁 새 어휘집 추가:
• + 버튼으로 CSV 파일 업로드
• 필수 컬럼: TargetVoca, ReferenceVoca''',
      
      // 다이얼로그
      'delete_vocab_title': '어휘집 삭제',
      'delete_vocab_message':
          '선택된 어휘집 {count}개를 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.',
      'delete_confirm_title': '어휘집 삭제 확인',
      'delete_confirm_message': '{count}개의 어휘집을 삭제하시겠습니까?',
      'reset_wrong_count_title': '틀린횟수 초기화',
      'reset_wrong_count_message':
          '선택된 어휘집 {count}개의 틀린횟수를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      'reset_wrong_counts_title': '틀린횟수 초기화 확인',
      'reset_wrong_counts_message': '{count}개 어휘집의 틀린횟수를 초기화하시겠습니까?',
      'reset_favorites_title': '즐겨찾기 초기화',
      'reset_favorites_message':
          '선택된 어휘집 {count}개의 즐겨찾기를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      'add_vocab_title': '어휘집 추가',
      'add_vocab_message':
          'CSV 파일을 선택하여 새로운 어휘집을 추가하시겠습니까?\n\n지원 형식: .csv\n필수 컬럼: TargetVoca, ReferenceVoca',
      
      // 성공/오류 메시지
      'delete_success_message': '어휘집이 성공적으로 삭제되었습니다',
      'export_success_message': 'CSV 파일로 성공적으로 내보냈습니다',
      'reset_wrong_counts_success_message': '틀린횟수가 성공적으로 초기화되었습니다',
      'reset_favorites_success_message': '즐겨찾기가 성공적으로 초기화되었습니다',
      'reset_button': '초기화',
      'error_delete_vocabulary': '어휘집 삭제 중 오류가 발생했습니다: {error}',
      'error_reset_wrong_counts': '틀린횟수 초기화 중 오류가 발생했습니다: {error}',
      'error_reset_favorites': '즐겨찾기 초기화 중 오류가 발생했습니다: {error}',
      
      // 학습 시작 관련 다이얼로그
      'no_vocab_selected_title': '어휘집이 선택되지 않음',
      'no_vocab_selected_message': '학습을 시작하려면 먼저 어휘집을 선택해주세요.',
      'no_words_found_title': '학습할 단어가 없음',
      'no_words_found_message': '선택된 조건에 해당하는 단어가 없습니다.\n필터 설정을 확인해주세요.',
      'no_favorites_found_title': '즐겨찾기 단어가 없음',
      'no_favorites_found_message': '즐겨찾기로 등록된 단어가 없습니다.\n먼저 단어를 즐겨찾기에 추가해주세요.',
      
      // 도움말 다이얼로그
      'vocab_selection_help_title': '어휘집 선택 도움말',
      'vocab_selection_help_content': '''어휘집 선택 방법:

🔹 단일선택 모드: 하나의 어휘집만 선택 가능
🔹 다중선택 모드: 여러 어휘집 동시 선택 가능

📚 어휘집 정보:
• 📝 단어수: 해당 어휘집의 총 단어 개수
• ⭐ 즐겨찾기: 즐겨찾기로 등록된 단어 수
• ❌ 틀린단어: 한 번이라도 틀린 단어 수  
• 🔢 틀린횟수: 총 틀린 횟수 누적
• 📅 최근학습: 마지막 학습 시점

📄 CSV 어휘집 업로드 형식:

✅ 필수 열 (반드시 포함):
• TargetVoca: 학습 대상어 (예: 영어 단어)
• ReferenceVoca: 참조어 (예: 한국어 뜻)

⚙️ 선택 열 (있으면 더 좋음):
• POS: 품사 (명사, 동사, 형용사 등)
• Type: 분류 (기본어휘, 고급어휘, 관용구 등)
• TargetPronunciation: 대상어 발음
• TargetDesc: 대상어 설명
• ReferenceDesc: 참조어 설명
• TargetEx: 대상어 예문
• ReferenceEx: 참조어 예문
• Favorites: 즐겨찾기 (1 또는 빈칸)

📖 언어 배치 권장사항:
• TargetVoca: 학습하고 싶은 언어 (영어, 일본어 등)
• ReferenceVoca: 잘 아는 언어 (한국어, 모국어 등)

💡 팁: 어휘집을 선택한 후 학습 방법을 선택하세요!''',
    },
    'EN': {
      // 어휘집 섹션
      'section_vocab_selection': '📚 Vocabulary Selection',
      'vocabulary_list_title': '📚 Vocabulary List',
      
      // 어휘집 관련
      'selected_vocab_info':
          'Selected: 📝{count} ⭐{favorites} ❌{wrong} 🔢{wrongCount}',
      'vocab_info_guide':
          '📖 Vocab Info Guide: 📝Words ⭐Favorites ❌Wrong 🔢Count 📅Recent',
      'add_new_vocab': 'Add New\nVocabulary',
      'add_new_vocabulary': 'Add New\nVocabulary',
      'selected_vocabularies': 'Selected Vocabularies',
      'no_vocab_message': 'Vocabularies will be displayed here once added.',
      
      // 버튼들
      'select_clear': '✅Clear Selected',
      'clear_all': '🗑️Clear All',
      'single_select': '☐Single Select',
      'multi_select': '✅Multi Select',
      'reset_wrong_count': '🧹Reset Wrong Count',
      'reset_favorites': '⭐Reset Favorites',
      
      // 모드 관련
      'multi_select_mode': 'Multi Select Mode',
      'single_select_mode': 'Single Select Mode',
      'select_all': 'Select All',
      'unselect_all': 'Unselect All',
      'delete_button': 'Delete',
      'export_button': 'Export',
      'reset_wrong_counts': 'Reset Wrong Counts',
      'reset_favorites_button': 'Reset Favorites',
      'reset_wrong_counts_button': 'Reset Wrong Counts',
      
      // 도움말
      'help_title': 'Vocabulary Management Help',
      'help_tooltip': 'Help',
      'vocabulary_list_help': '''📚 Vocabulary Management Guide:

🔹 Vocabulary Selection:
• Tap to select single vocabulary
• Long press to enter multi-select mode

🔹 Management Features:
• ✅ Select All / ❌ Unselect All
• 🗑️ Delete selected vocabularies
• 📤 Export as CSV format
• 🧹 Reset wrong counts
• ⭐ Reset favorites

📊 Vocabulary Info:
• 📝 Words: Total word count
• ⭐ Favorites: Favorite word count  
• ❌ Wrong: Wrong word count
• 🔢 Count: Total wrong count

📁 Add New Vocabulary:
• + button to upload CSV file
• Required columns: TargetVoca, ReferenceVoca''',
      
      // 다이얼로그
      'delete_vocab_title': 'Delete Vocabulary',
      'delete_vocab_message':
          'Delete {count} selected vocabulary sets?\nThis action cannot be undone.',
      'delete_confirm_title': 'Confirm Vocabulary Deletion',
      'delete_confirm_message': 'Delete {count} vocabulary sets?',
      'reset_wrong_count_title': 'Reset Wrong Count',
      'reset_wrong_count_message':
          'Reset wrong count for {count} selected vocabulary sets?\nThis action cannot be undone.',
      'reset_wrong_counts_title': 'Confirm Reset Wrong Counts',
      'reset_wrong_counts_message': 'Reset wrong counts for {count} vocabulary sets?',
      'reset_favorites_title': 'Reset Favorites',
      'reset_favorites_message':
          'Reset favorites for {count} selected vocabulary sets?\nThis action cannot be undone.',
      'add_vocab_title': 'Add Vocabulary',
      'add_vocab_message':
          'Select CSV file to add new vocabulary?\n\nSupported: .csv\nRequired columns: TargetVoca, ReferenceVoca',
      
      // 성공/오류 메시지
      'delete_success_message': 'Vocabulary successfully deleted',
      'export_success_message': 'Successfully exported as CSV file',
      'reset_wrong_counts_success_message': 'Wrong counts successfully reset',
      'reset_favorites_success_message': 'Favorites successfully reset',
      'reset_button': 'Reset',
      'error_delete_vocabulary': 'Error occurred while deleting vocabulary: {error}',
      'error_reset_wrong_counts': 'Error occurred while resetting wrong counts: {error}',
      'error_reset_favorites': 'Error occurred while resetting favorites: {error}',
      
      // 학습 시작 관련 다이얼로그
      'no_vocab_selected_title': 'No Vocabulary Selected',
      'no_vocab_selected_message':
          'Please select a vocabulary set first to start studying.',
      'no_words_found_title': 'No Words Found',
      'no_words_found_message':
          'No words match the selected criteria.\nPlease check your filter settings.',
      'no_favorites_found_title': 'No Favorite Words',
      'no_favorites_found_message':
          'No words are marked as favorites.\nPlease add words to favorites first.',
      
      // 도움말 다이얼로그
      'vocab_selection_help_title': 'Vocabulary Selection Help',
      'vocab_selection_help_content': '''How to select vocabulary:

🔹 Single Select: Choose only one vocabulary set
🔹 Multi Select: Choose multiple vocabulary sets

📚 Vocabulary Info:
• 📝 Words: Total number of words in the set
• ⭐ Favorites: Number of favorited words
• ❌ Wrong: Number of words answered incorrectly
• 🔢 Count: Total number of wrong attempts
• 📅 Recent: Last study session time

📄 CSV Vocabulary Upload Format:

✅ Required Columns (Must Include):
• TargetVoca: Target language word (e.g., English)
• ReferenceVoca: Reference language (e.g., Korean meaning)

⚙️ Optional Columns (Better if included):
• POS: Part of speech (noun, verb, adjective, etc.)
• Type: Category (basic, advanced, idiom, etc.)
• TargetPronunciation: Target word pronunciation
• TargetDesc: Target word description
• ReferenceDesc: Reference word description
• TargetEx: Target language example
• ReferenceEx: Reference language example
• Favorites: Bookmark (1 or empty)

📖 Language Placement Recommendations:
• TargetVoca: Language you want to learn (English, Japanese, etc.)
• ReferenceVoca: Language you know well (Korean, native language, etc.)

💡 Tip: Select vocabulary first, then choose learning method!''',
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

  // 섹션 제목
  static String get sectionVocabSelection => get('section_vocab_selection');
  static String get vocabularyListTitle => get('vocabulary_list_title');

  // 어휘집 관련
  static String selectedVocabInfo(
          {required int count,
          required int favorites,
          required int wrong,
          required int wrongCount}) =>
      get('selected_vocab_info', params: {
        'count': count,
        'favorites': favorites,
        'wrong': wrong,
        'wrongCount': wrongCount
      });
  static String get vocabInfoGuide => get('vocab_info_guide');
  static String get addNewVocab => get('add_new_vocab');
  static String get addNewVocabulary => get('add_new_vocabulary');
  static String get selectedVocabularies => get('selected_vocabularies');
  static String get noVocabMessage => get('no_vocab_message');

  // 버튼들
  static String get selectClear => get('select_clear');
  static String get clearAll => get('clear_all');
  static String get singleSelect => get('single_select');
  static String get multiSelect => get('multi_select');
  static String get resetWrongCount => get('reset_wrong_count');
  static String get resetFavorites => get('reset_favorites');

  // 모드 관련
  static String get multiSelectMode => get('multi_select_mode');
  static String get singleSelectMode => get('single_select_mode');
  static String get selectAll => get('select_all');
  static String get unselectAll => get('unselect_all');
  static String get deleteButton => get('delete_button');
  static String get exportButton => get('export_button');
  static String get resetWrongCounts => get('reset_wrong_counts');
  static String get resetFavoritesButton => get('reset_favorites_button');
  static String get resetWrongCountsButton => get('reset_wrong_counts_button');

  // 도움말
  static String get helpTitle => get('help_title');
  static String get helpTooltip => get('help_tooltip');
  static String get vocabularyListHelp => get('vocabulary_list_help');

  // 다이얼로그
  static String get deleteVocabTitle => get('delete_vocab_title');
  static String deleteVocabMessage(int count) =>
      get('delete_vocab_message', params: {'count': count});
  static String get deleteConfirmTitle => get('delete_confirm_title');
  static String deleteConfirmMessage(int count) =>
      get('delete_confirm_message', params: {'count': count});
  static String get resetWrongCountTitle => get('reset_wrong_count_title');
  static String resetWrongCountMessage(int count) =>
      get('reset_wrong_count_message', params: {'count': count});
  static String get resetWrongCountsTitle => get('reset_wrong_counts_title');
  static String resetWrongCountsMessage(int count) =>
      get('reset_wrong_counts_message', params: {'count': count});
  static String get resetFavoritesTitle => get('reset_favorites_title');
  static String resetFavoritesMessage(int count) =>
      get('reset_favorites_message', params: {'count': count});
  static String get addVocabTitle => get('add_vocab_title');
  static String get addVocabMessage => get('add_vocab_message');

  // 성공/오류 메시지
  static String get deleteSuccessMessage => get('delete_success_message');
  static String get exportSuccessMessage => get('export_success_message');
  static String get resetWrongCountsSuccessMessage =>
      get('reset_wrong_counts_success_message');
  static String get resetFavoritesSuccessMessage =>
      get('reset_favorites_success_message');
  static String get resetButton => get('reset_button');
  static String errorDeleteVocabulary(String error) =>
      get('error_delete_vocabulary', params: {'error': error});
  static String errorResetWrongCounts(String error) =>
      get('error_reset_wrong_counts', params: {'error': error});
  static String errorResetFavorites(String error) =>
      get('error_reset_favorites', params: {'error': error});

  // 학습 시작 관련 다이얼로그
  static String get noVocabSelectedTitle => get('no_vocab_selected_title');
  static String get noVocabSelectedMessage => get('no_vocab_selected_message');
  static String get noWordsFoundTitle => get('no_words_found_title');
  static String get noWordsFoundMessage => get('no_words_found_message');
  static String get noFavoritesFoundTitle => get('no_favorites_found_title');
  static String get noFavoritesFoundMessage =>
      get('no_favorites_found_message');

  // 도움말 다이얼로그
  static String get vocabSelectionHelpTitle =>
      get('vocab_selection_help_title');
  static String get vocabSelectionHelpContent =>
      get('vocab_selection_help_content');
}