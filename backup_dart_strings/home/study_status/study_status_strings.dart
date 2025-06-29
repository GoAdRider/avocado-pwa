class StudyStatusStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 홈화면 섹션 제목들
      'title_main': '✨ Do a Vocabulary! ✨',
      'section_study_status': '📊 나의 학습 현황',
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
      
      // 학습 모드
      'target_voca': '📖 TargetVoca',
      'reference_voca': '🌐 ReferenceVoca',
      'random_mode': '🎲 Random',
      
      // 학습 방법
      'card_study': '📖 단어카드',
      'favorite_review': '⭐ 즐겨찾기',
      'game_study': '🎮 게임',
      'wrong_word_study': '❌ 틀린단어',
      
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
    },
    'EN': {
      // 홈화면 섹션 제목들
      'title_main': '✨ Do a Vocabulary! ✨',
      'section_study_status': '📊 My Study Status',
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
      
      // 학습 모드
      'target_voca': '📖 TargetVoca',
      'reference_voca': '🌐 ReferenceVoca',
      'random_mode': '🎲 Random',
      
      // 학습 방법
      'card_study': '📖 Card',
      'favorite_review': '⭐ Favorite',
      'game_study': '🎮 Game',
      'wrong_word_study': '❌ Wrong Words',
      
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

  // 섹션 제목들
  static String get titleMain => get('title_main');
  static String get sectionStudyStatus => get('section_study_status');
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

  // 학습 모드
  static String get targetVoca => get('target_voca');
  static String get referenceVoca => get('reference_voca');
  static String get randomMode => get('random_mode');

  // 학습 방법
  static String get cardStudy => get('card_study');
  static String get favoriteReview => get('favorite_review');
  static String get gameStudy => get('game_study');
  static String get wrongWordStudy => get('wrong_word_study');

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
  static String get studyModeHelpTitle => get('study_mode_help_title');
  static String get studyModeHelpContent => get('study_mode_help_content');
}