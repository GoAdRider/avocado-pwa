class HomeStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 홈화면 섹션 제목들
      'title_main': '✨ Do a Vocabulary! ✨',
      'section_study_status': '📊 나의 학습 현황',
      'section_smart_review': '🧠 망각곡선 기반 복습',
      'section_recent_study': '📖 최근 학습 기록',
      'section_vocab_selection': '📚 어휘집 선택',
      'section_pos_type_filter': '🎯 품사/타입 필터 (선택사항)',
      'section_study_mode': '🃏 위주 학습 설정',
      'section_learning_method': '🎯 학습 방법 선택하기',

      // 학습 현황 카드들
      'total_words': '학습 가능한 총 단어',
      'total_favorites': '총 즐겨찾기',
      'total_wrong_words': '총 틀린 단어',
      'total_wrong_count': '총 틀린 횟수',
      'average_accuracy': '평균 정답률',
      'study_streak': '연속 학습',

      // 홈화면 버튼들
      'todays_goal': '🎯 학습 목표',
      'detailed_stats': '📊 상세통계 보기',
      'select_clear': '✅선택지우기',
      'clear_all': '🗑️전체지우기',
      'single_select': '☐단일선택',
      'multi_select': '✅다중선택',
      'reset_wrong_count': '🧹틀린횟수 초기화',
      'reset_favorites': '⭐즐겨찾기 초기화',

      // 스마트 복습
      'urgent_review': '긴급 복습 ({count}개) - 놓치면 기억에서 사라져요!',
      'recommended_review': '권장 복습 ({count}개) - 오늘 하면 기억력 UP!',
      'optional_review': '여유 복습 ({count}개) - 시간 날 때 해보세요',
      'forgetting_risk': '망각 위험 ({count}개) - 기억에서 사라지고 있어요!',

      // 어휘집 관련
      'selected_vocab_info':
          '선택된 어휘집: 📝{count}개 ⭐{favorites}개 ❌{wrong}개 🔢{wrongCount}회',
      'vocab_info_guide': '📖 어휘집 정보 가이드: 📝단어수 ⭐즐겨찾기 ❌틀린단어 🔢틀린횟수 📅최근학습',
      'add_new_vocab': '새로운 어휘집\n추가하기',
      'no_vocab_message': '어휘집을 추가하시면 여기에 표시됩니다.',

      'filtered_words':
          '필터된 단어: 📝{words}개 ⭐{favorites}개 ❌{wrong}개 🔢{wrongCount}회',

      // 필터
      'pos_filter': '🔍 품사 필터',
      'type_filter': '🏷️ 어휘 타입 필터',
      'selected_filters': '📌 선택된 필터: ',
      'filter_no_selection_guide': '{filterType}을(를) 보려면',
      'filter_select_vocab_first': '먼저 어휘집을 선택해주세요',
      'pos_not_available': '품사정보없음',
      'type_not_available': '타입정보없음',

      // 학습 모드
      'target_voca': '📖 TargetVoca',
      'reference_voca': '🌐 ReferenceVoca',
      'random_mode': '🎲 Random',

      // 학습 방법
      'card_study': '📖 단어카드',
      'favorite_review': '⭐ 즐겨찾기',
      'game_study': '🎮 게임',
      'wrong_word_study': '❌ 틀린단어',

      // 시간 표시
      'just_now': '방금 전',
      'seconds_ago': '{seconds}초 전',
      'minutes_ago': '{minutes}분 전',
      'hours_ago': '{hours}시간 전',
      'days_ago': '{days}일 전',
      'weeks_ago': '{weeks}주 전',
      'no_recent': '없음',

      // 홈화면 다이얼로그
      'delete_selected_title': '선택된 기록 삭제',
      'delete_selected_message':
          '선택된 {count}개의 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
      'delete_vocab_title': '어휘집 삭제',
      'delete_vocab_message':
          '선택된 어휘집 {count}개를 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.',
      'reset_wrong_count_title': '틀린횟수 초기화',
      'reset_wrong_count_message':
          '선택된 어휘집 {count}개의 틀린횟수를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      'reset_favorites_title': '즐겨찾기 초기화',
      'reset_favorites_message':
          '선택된 어휘집 {count}개의 즐겨찾기를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      'add_vocab_title': '어휘집 추가',
      'add_vocab_message':
          'CSV 파일을 선택하여 새로운 어휘집을 추가하시겠습니까?\n\n지원 형식: .csv\n필수 컬럼: TargetVoca, ReferenceVoca',
      'clear_all_title': '전체 기록 삭제',
      'clear_all_message': '모든 최근 학습 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
      'edit_name_title': '이름 변경',
      'edit_name_hint': '새 이름',

      // 오늘의 목표 다이얼로그
      'todays_goal_title': '🎯 학습 목표 설정',
      'daily_goal_section': '📅 일일 목표',
      'weekly_goal_section': '📅 주간 목표',
      'monthly_goal_section': '📅 월간 목표',
      'new_words_goal': '신규 학습',
      'review_words_goal': '복습 완료',
      'perfect_answers_goal': '완벽 정답',
      'goal_progress_title': '🎯 학습 목표 달성도',
      'goal_achievement': '신규학습: {current}/{target}개 ({percent}%)',
      'goal_achievement_message': '+{remaining}개 더 하면 달성!',
      'goal_completed': '🏆완료!',
      'todays_summary':
          '💪 오늘 한 일: 신규 {newWords}개 + 복습 {reviewWords}개 = 총 {totalWords}개 학습완료!',
      'streak_info':
          '🔥 연속학습: {current}일째 (최고기록: {best}일) | 다음 도전: {next}일 달성!',
      'weekly_progress': '📅 이번 주 진도: {current}/{target}개 ({percent}%)',
      'monthly_progress': '📅 이번 달 진도: {current}/{target}개 ({percent}%)',
      'goal_settings': '⚙️ 목표 설정',
      'goal_close': '확인',
      'goal_settings_title': '🎯 학습 목표 설정',
      'goal_save': '저장',
      'daily_new_words': '일일 신규 학습',
      'daily_review_words': '일일 복습 완료',
      'daily_perfect_answers': '일일 완벽 정답',
      'perfect_answers_desc': '(힌트 없이 첫 시도에서 정답)',
      'weekly_goal_label': '주간 목표',
      'monthly_goal_label': '월간 목표',
      'weekly_monthly_goal_desc': '(신규학습 + 복습 포함 총 학습 단어수)',
      'goal_unit_words': '개',
      'goal_validation_error': '목표는 1 이상의 숫자여야 합니다.',

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
      'study_mode_help_title': '위주 학습 설정 도움말',
      'study_mode_help_content': '''학습 모드별 차이점:

📖 TargetVoca 모드:
• 카드 시작면: TargetVoca (학습 대상어)
• 카드 뒷면: ReferenceVoca (참조어)
• 게임 질문 → 답: TargetVoca
• 특징: 매 카드가 TargetVoca로 시작됨

🌐 ReferenceVoca 모드:
• 카드 시작면: ReferenceVoca (참조어)  
• 카드 뒷면: TargetVoca (학습 대상어)
• 게임 질문 → 답: ReferenceVoca
• 특징: 매 카드가 ReferenceVoca로 시작됨

🎲 Random 모드:
• 매 카드마다 시작면이 무작위로 결정
• 게임에서도 질문과 답이 무작위
• 양방향 학습으로 완전한 숙지 가능
• 특징: 예측할 수 없어 더 효과적

🎯 사용 예시:
• 영어→한국어 학습: TargetVoca 모드
• 한국어→영어 학습: ReferenceVoca 모드  
• 완전 숙지 확인: Random 모드

💡 추천: 초보자는 TargetVoca, 고급자는 Random!''',

      // 망각곡선 복습 시스템
      'smart_review_title': '🧠 망각곡선 기반 복습',
      'urgent_review_title': '긴급 복습',
      'urgent_review_desc': '놓치면 기억에서 사라져요!',
      'recommended_review_title': '권장 복습',
      'recommended_review_desc': '오늘 하면 기억력 UP!',
      'preview_review_title': '여유 복습',
      'preview_review_desc': '시간 날 때 해보세요',
      'forgotten_review_title': '망각 위험',
      'forgotten_review_desc': '기억에서 사라지고 있어요!',
    },
    'EN': {
      // 홈화면 섹션 제목들
      'title_main': '✨ Do a Vocabulary! ✨',
      'section_study_status': '📊 My Study Status',
      'section_smart_review': '🧠 Forgetting Curve Review',
      'section_recent_study': '📖 Recent Study Records',
      'section_vocab_selection': '📚 Vocabulary Selection',
      'section_pos_type_filter': '🎯 POS/Type Filter (Optional)',
      'section_study_mode': '🃏 Study Mode Setting',
      'section_learning_method': '🎯 Choose Learning Method',

      // 학습 현황 카드들
      'total_words': 'Total Available Words',
      'total_favorites': 'Total Favorites',
      'total_wrong_words': 'Total Wrong Words',
      'total_wrong_count': 'Total Wrong Count',
      'average_accuracy': 'Average Accuracy',
      'study_streak': 'Study Streak',

      // 홈화면 버튼들
      'todays_goal': '🎯 Learning Goal',
      'detailed_stats': '📊 Detailed Stats',
      'select_clear': '✅Clear Selected',
      'clear_all': '🗑️Clear All',
      'single_select': '☐Single Select',
      'multi_select': '✅Multi Select',
      'reset_wrong_count': '🧹Reset Wrong Count',
      'reset_favorites': '⭐Reset Favorites',

      // 스마트 복습
      'urgent_review': 'Urgent Review ({count}) - Don\'t miss or forget!',
      'recommended_review': 'Recommended Review ({count}) - Perfect timing!',
      'optional_review': 'Optional Review ({count}) - When you have time',
      'forgetting_risk': 'Forgetting Risk ({count}) - Fading from memory!',

      // 어휘집 관련
      'selected_vocab_info':
          'Selected: 📝{count} ⭐{favorites} ❌{wrong} 🔢{wrongCount}',
      'vocab_info_guide':
          '📖 Vocab Info Guide: 📝Words ⭐Favorites ❌Wrong 🔢Count 📅Recent',
      'add_new_vocab': 'Add New\nVocabulary',
      'no_vocab_message': 'Vocabularies will be displayed here once added.',

      'filtered_words':
          'Filtered: 📝{words} ⭐{favorites} ❌{wrong} 🔢{wrongCount}',

      // 필터
      'pos_filter': '🔍 POS Filter',
      'type_filter': '🏷️ Type Filter',
      'selected_filters': '📌 Selected Filters: ',
      'filter_no_selection_guide': 'To see {filterType}',
      'filter_select_vocab_first': 'Please select vocabulary first',
      'pos_not_available': 'No POS Info',
      'type_not_available': 'No Type Info',

      // 학습 모드
      'target_voca': '📖 TargetVoca',
      'reference_voca': '🌐 ReferenceVoca',
      'random_mode': '🎲 Random',

      // 학습 방법
      'card_study': '📖 Card',
      'favorite_review': '⭐ Favorite',
      'game_study': '🎮 Game',
      'wrong_word_study': '❌ Wrong Words',

      // 시간 표시
      'just_now': 'Just now',
      'seconds_ago': '{seconds}s ago',
      'minutes_ago': '{minutes}m ago',
      'hours_ago': '{hours}h ago',
      'days_ago': '{days}d ago',
      'weeks_ago': '{weeks}w ago',
      'no_recent': 'None',

      // 홈화면 다이얼로그
      'delete_selected_title': 'Delete Selected Records',
      'delete_selected_message':
          'Delete {count} selected records?\nThis action cannot be undone.',
      'delete_vocab_title': 'Delete Vocabulary',
      'delete_vocab_message':
          'Delete {count} selected vocabulary sets?\nThis action cannot be undone.',
      'reset_wrong_count_title': 'Reset Wrong Count',
      'reset_wrong_count_message':
          'Reset wrong count for {count} selected vocabulary sets?\nThis action cannot be undone.',
      'reset_favorites_title': 'Reset Favorites',
      'reset_favorites_message':
          'Reset favorites for {count} selected vocabulary sets?\nThis action cannot be undone.',
      'add_vocab_title': 'Add Vocabulary',
      'add_vocab_message':
          'Select CSV file to add new vocabulary?\n\nSupported: .csv\nRequired columns: TargetVoca, ReferenceVoca',
      'clear_all_title': 'Clear All Records',
      'clear_all_message':
          'Clear all recent study records?\nThis action cannot be undone.',
      'edit_name_title': 'Edit Name',
      'edit_name_hint': 'New name',

      // 오늘의 목표 다이얼로그
      'todays_goal_title': '🎯 Learning Goal Setting',
      'daily_goal_section': '📅 Daily Goal',
      'weekly_goal_section': '📅 Weekly Goal',
      'monthly_goal_section': '📅 Monthly Goal',
      'new_words_goal': 'New Words',
      'review_words_goal': 'Review Complete',
      'perfect_answers_goal': 'Perfect Answers',
      'goal_progress_title': '🎯 Learning Goal Progress',
      'goal_achievement': 'New Words: {current}/{target} ({percent}%)',
      'goal_achievement_message': '+{remaining} more to achieve!',
      'goal_completed': '🏆Complete!',
      'todays_summary':
          '💪 Today\'s Work: New {newWords} + Review {reviewWords} = Total {totalWords} studied!',
      'streak_info':
          '🔥 Study Streak: {current} days (Best: {best} days) | Next Challenge: {next} days!',
      'weekly_progress': '📅 This Week: {current}/{target} ({percent}%)',
      'monthly_progress': '📅 This Month: {current}/{target} ({percent}%)',
      'goal_settings': '⚙️ Goal Settings',
      'goal_close': 'Close',
      'goal_settings_title': '🎯 Learning Goal Settings',
      'goal_save': 'Save',
      'daily_new_words': 'Daily New Words',
      'daily_review_words': 'Daily Review Complete',
      'daily_perfect_answers': 'Daily Perfect Answers',
      'perfect_answers_desc': '(Correct on first try without hints)',
      'weekly_goal_label': 'Weekly Goal',
      'monthly_goal_label': 'Monthly Goal',
      'weekly_monthly_goal_desc': '(Total words including new + review)',
      'goal_unit_words': ' words',
      'goal_validation_error': 'Goal must be a number greater than 0.',

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
      'study_mode_help_title': 'Study Mode Setting Help',
      'study_mode_help_content': '''Study mode differences:

📖 TargetVoca Mode:
• Card Starting Side: TargetVoca (target language)
• Card Back Side: ReferenceVoca (reference language)
• Game Question → Answer: TargetVoca
• Feature: Every card starts with TargetVoca

🌐 ReferenceVoca Mode:
• Card Starting Side: ReferenceVoca (reference language)
• Card Back Side: TargetVoca (target language)
• Game Question → Answer: ReferenceVoca
• Feature: Every card starts with ReferenceVoca

🎲 Random Mode:
• Starting side randomized for each card
• Game questions and answers randomized
• Bidirectional learning for complete mastery
• Feature: Unpredictable, more effective

🎯 Usage Examples:
• English→Korean learning: TargetVoca mode
• Korean→English learning: ReferenceVoca mode
• Complete mastery check: Random mode

💡 Recommendation: Beginners use TargetVoca, Advanced use Random!''',

      // 망각곡선 복습 시스템
      'smart_review_title': '🧠 Forgetting Curve Review',
      'urgent_review_title': 'Urgent Review',
      'urgent_review_desc': 'Will disappear from memory if missed!',
      'recommended_review_title': 'Recommended Review',
      'recommended_review_desc': 'Memory boost if done today!',
      'preview_review_title': 'Preview Review',
      'preview_review_desc': 'Do it when you have time',
      'forgotten_review_title': 'Forgetting Risk',
      'forgotten_review_desc': 'Disappearing from memory!',
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

  // 섹션 제목들
  static String get titleMain => get('title_main');
  static String get sectionStudyStatus => get('section_study_status');
  static String get sectionSmartReview => get('section_smart_review');
  static String get sectionRecentStudy => get('section_recent_study');
  static String get sectionVocabSelection => get('section_vocab_selection');
  static String get sectionPosTypeFilter => get('section_pos_type_filter');
  static String get sectionStudyMode => get('section_study_mode');
  static String get sectionLearningMethod => get('section_learning_method');

  // 학습 현황
  static String get totalWords => get('total_words');
  static String get totalFavorites => get('total_favorites');
  static String get totalWrongWords => get('total_wrong_words');
  static String get totalWrongCount => get('total_wrong_count');
  static String get averageAccuracy => get('average_accuracy');
  static String get studyStreak => get('study_streak');

  // 버튼들
  static String get todaysGoal => get('todays_goal');
  static String get detailedStats => get('detailed_stats');
  static String get selectClear => get('select_clear');
  static String get clearAll => get('clear_all');
  static String get singleSelect => get('single_select');
  static String get multiSelect => get('multi_select');
  static String get resetWrongCount => get('reset_wrong_count');
  static String get resetFavorites => get('reset_favorites');

  // 스마트 복습
  static String urgentReview(int count) =>
      get('urgent_review', params: {'count': count});
  static String recommendedReview(int count) =>
      get('recommended_review', params: {'count': count});
  static String optionalReview(int count) =>
      get('optional_review', params: {'count': count});
  static String forgettingRisk(int count) =>
      get('forgetting_risk', params: {'count': count});

  // 어휘집
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
  static String get noVocabMessage => get('no_vocab_message');

  static String filteredWords(
          {required int words,
          required int favorites,
          required int wrong,
          required int wrongCount}) =>
      get('filtered_words', params: {
        'words': words,
        'favorites': favorites,
        'wrong': wrong,
        'wrongCount': wrongCount
      });

  // 필터
  static String get posFilter => get('pos_filter');
  static String get typeFilter => get('type_filter');
  static String get selectedFilters => get('selected_filters');
  static String filterNoSelectionGuide(String filterType) =>
      get('filter_no_selection_guide', params: {'filterType': filterType});
  static String get filterSelectVocabFirst => get('filter_select_vocab_first');
  static String get posNotAvailable => get('pos_not_available');
  static String get typeNotAvailable => get('type_not_available');

  // 학습 모드
  static String get targetVoca => get('target_voca');
  static String get referenceVoca => get('reference_voca');
  static String get randomMode => get('random_mode');

  // 학습 방법
  static String get cardStudy => get('card_study');
  static String get favoriteReview => get('favorite_review');
  static String get gameStudy => get('game_study');
  static String get wrongWordStudy => get('wrong_word_study');

  // 시간
  static String get justNow => get('just_now');
  static String secondsAgo(int seconds) =>
      get('seconds_ago', params: {'seconds': seconds});
  static String minutesAgo(int minutes) =>
      get('minutes_ago', params: {'minutes': minutes});
  static String hoursAgo(int hours) =>
      get('hours_ago', params: {'hours': hours});
  static String daysAgo(int days) => get('days_ago', params: {'days': days});
  static String weeksAgo(int weeks) =>
      get('weeks_ago', params: {'weeks': weeks});
  static String get noRecent => get('no_recent');

  // 다이얼로그
  static String get resetWrongCountTitle => get('reset_wrong_count_title');
  static String resetWrongCountMessage(int count) =>
      get('reset_wrong_count_message', params: {'count': count});
  static String get resetFavoritesTitle => get('reset_favorites_title');
  static String resetFavoritesMessage(int count) =>
      get('reset_favorites_message', params: {'count': count});
  static String get addVocabTitle => get('add_vocab_title');
  static String get addVocabMessage => get('add_vocab_message');
  static String get clearAllTitle => get('clear_all_title');
  static String get clearAllMessage => get('clear_all_message');
  static String get editNameTitle => get('edit_name_title');
  static String get editNameHint => get('edit_name_hint');

  // 홈화면 다이얼로그
  static String get deleteSelectedTitle => get('delete_selected_title');
  static String deleteSelectedMessage(int count) =>
      get('delete_selected_message', params: {'count': count});
  static String get deleteVocabTitle => get('delete_vocab_title');
  static String deleteVocabMessage(int count) =>
      get('delete_vocab_message', params: {'count': count});

  // 오늘의 목표 다이얼로그
  static String get todaysGoalTitle => get('todays_goal_title');
  static String get dailyGoalSection => get('daily_goal_section');
  static String get weeklyGoalSection => get('weekly_goal_section');
  static String get monthlyGoalSection => get('monthly_goal_section');
  static String get newWordsGoal => get('new_words_goal');
  static String get reviewWordsGoal => get('review_words_goal');
  static String get perfectAnswersGoal => get('perfect_answers_goal');
  static String get goalProgressTitle => get('goal_progress_title');
  static String goalAchievement(
          {required int current, required int target, required int percent}) =>
      get('goal_achievement',
          params: {'current': current, 'target': target, 'percent': percent});
  static String goalAchievementMessage(int remaining) =>
      get('goal_achievement_message', params: {'remaining': remaining});
  static String get goalCompleted => get('goal_completed');
  static String todaysSummary(
          {required int newWords,
          required int reviewWords,
          required int totalWords}) =>
      get('todays_summary', params: {
        'newWords': newWords,
        'reviewWords': reviewWords,
        'totalWords': totalWords
      });
  static String streakInfo(
          {required int current, required int best, required int next}) =>
      get('streak_info',
          params: {'current': current, 'best': best, 'next': next});
  static String weeklyProgress(
          {required int current, required int target, required int percent}) =>
      get('weekly_progress',
          params: {'current': current, 'target': target, 'percent': percent});
  static String monthlyProgress(
          {required int current, required int target, required int percent}) =>
      get('monthly_progress',
          params: {'current': current, 'target': target, 'percent': percent});
  static String get goalSettings => get('goal_settings');
  static String get goalClose => get('goal_close');
  static String get goalSettingsTitle => get('goal_settings_title');
  static String get goalSave => get('goal_save');
  static String get dailyNewWords => get('daily_new_words');
  static String get dailyReviewWords => get('daily_review_words');
  static String get dailyPerfectAnswers => get('daily_perfect_answers');
  static String get perfectAnswersDesc => get('perfect_answers_desc');
  static String get weeklyGoalLabel => get('weekly_goal_label');
  static String get monthlyGoalLabel => get('monthly_goal_label');
  static String get weeklyMonthlyGoalDesc => get('weekly_monthly_goal_desc');
  static String get goalUnitWords => get('goal_unit_words');
  static String get goalValidationError => get('goal_validation_error');

  // 도움말 다이얼로그
  static String get vocabSelectionHelpTitle =>
      get('vocab_selection_help_title');
  static String get vocabSelectionHelpContent =>
      get('vocab_selection_help_content');
  static String get studyModeHelpTitle => get('study_mode_help_title');
  static String get studyModeHelpContent => get('study_mode_help_content');

  // 망각곡선 복습 시스템
  static String get smartReviewTitle => get('smart_review_title');
  static String get urgentReviewTitle => get('urgent_review_title');
  static String get urgentReviewDesc => get('urgent_review_desc');
  static String get recommendedReviewTitle => get('recommended_review_title');
  static String get recommendedReviewDesc => get('recommended_review_desc');
  static String get previewReviewTitle => get('preview_review_title');
  static String get previewReviewDesc => get('preview_review_desc');
  static String get forgottenReviewTitle => get('forgotten_review_title');
  static String get forgottenReviewDesc => get('forgotten_review_desc');
}
