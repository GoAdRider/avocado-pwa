class RecentStudyStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 최근 학습 기록 섹션
      'section_recent_study': '📖 최근 학습 기록',
      'recent_study_title': '📖 최근 학습 기록',
      
      // 빈 상태
      'no_recent_study_title': '최근 학습 기록이 없습니다',
      'no_recent_study_message': '학습을 시작하면 여기에 표시됩니다',
      'no_recent_study': '최근 학습 기록이 없습니다',
      'start_study_to_see_records': '학습을 시작하면 여기에 표시됩니다',
      
      // 선택 관련
      'cancel_selection': '선택 취소',
      'select_mode': '선택',
      'select_clear': '선택지우기',
      'clear_all': '전체지우기',
      
      // 기록 정보
      'total_sessions': '총 학습 횟수',
      'accuracy': '정답률',
      'last_study_date': '마지막 학습',
      
      // 시간 표시
      'just_now': '방금 전',
      'seconds_ago': '{seconds}초 전',
      'minutes_ago': '{minutes}분 전',
      'hours_ago': '{hours}시간 전',
      'days_ago': '{days}일 전',
      'weeks_ago': '{weeks}주 전',
      'months_ago': '{months}달 전',
      'no_recent': '없음',
      'today': '오늘',
      'yesterday': '어제',
      
      // 학습 모드별 텍스트
      'study_mode_card': '📖 단어카드',
      'study_mode_favorites': '⭐ 즐겨찾기',
      'study_mode_wrong_words': '❌ 틀린단어',
      'study_mode_urgent_review': '🔥 긴급복습',
      'study_mode_recommended_review': '🟡 권장복습',
      'study_mode_leisure_review': '🟢 여유복습',
      'study_mode_forgetting_risk': '⚠️ 망각위험',
      
      // 툴팁 메시지
      'tooltip_vocabulary': '어휘집',
      'tooltip_word_count': '단어개수',
      'tooltip_study_mode': '학습모드',
      'tooltip_display_order': '표시순서',
      'tooltip_total_sessions': '총 학습 세션',
      'tooltip_progress': '진행도',
      'tooltip_target_mode_target': 'TargetVoca 먼저',
      'tooltip_target_mode_reference': 'ReferenceVoca 먼저',
      'tooltip_target_mode_random': 'Random 모드',
      'tooltip_unit_count': '개',
      'tooltip_unit_times': '회',
      'tooltip_unit_percent': '%',
      'selected_filters': '선택된 필터',
      'tooltip_all_filters': '모든 필터',
      'tooltip_pos_filter': '품사 필터',
      'tooltip_type_filter': '어휘 타입 필터',
      
      // 다이얼로그
      'delete_selected_title': '선택된 기록 삭제',
      'delete_selected_message':
          '선택된 {count}개의 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
      'clear_all_title': '전체 기록 삭제',
      'clear_all_message': '모든 최근 학습 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
      'edit_name_title': '이름 변경',
      'edit_name_hint': '새 이름',
    },
    'EN': {
      // 최근 학습 기록 섹션
      'section_recent_study': '📖 Recent Study Records',
      'recent_study_title': '📖 Recent Study Records',
      
      // 빈 상태
      'no_recent_study_title': 'No recent study records',
      'no_recent_study_message':
          'Records will appear here once you start studying',
      'no_recent_study': 'No recent study records',
      'start_study_to_see_records': 'Records will appear here once you start studying',
      
      // 선택 관련
      'cancel_selection': 'Cancel Selection',
      'select_mode': 'Select Mode',
      'select_clear': 'Select Clear',
      'clear_all': 'Clear All',
      
      // 기록 정보
      'total_sessions': 'Total Sessions',
      'accuracy': 'Accuracy',
      'last_study_date': 'Last Study Date',
      
      // 시간 표시
      'just_now': 'Just now',
      'seconds_ago': '{seconds}s ago',
      'minutes_ago': '{minutes}m ago',
      'hours_ago': '{hours}h ago',
      'days_ago': '{days}d ago',
      'weeks_ago': '{weeks}w ago',
      'months_ago': '{months}mo ago',
      'no_recent': 'None',
      'today': 'Today',
      'yesterday': 'Yesterday',
      
      // 학습 모드별 텍스트
      'study_mode_card': '📖 Card Study',
      'study_mode_favorites': '⭐ Favorites',
      'study_mode_wrong_words': '❌ Wrong Words',
      'study_mode_urgent_review': '🔥 Urgent Review',
      'study_mode_recommended_review': '🟡 Recommended Review',
      'study_mode_leisure_review': '🟢 Leisure Review',
      'study_mode_forgetting_risk': '⚠️ Forgetting Risk',
      
      // 툴팁 메시지
      'tooltip_vocabulary': 'Vocabulary',
      'tooltip_word_count': 'Word Count',
      'tooltip_study_mode': 'Study Mode',
      'tooltip_display_order': 'Display Order',
      'tooltip_total_sessions': 'Total Sessions',
      'tooltip_progress': 'Progress',
      'tooltip_target_mode_target': 'TargetVoca First',
      'tooltip_target_mode_reference': 'ReferenceVoca First',
      'tooltip_target_mode_random': 'Random Mode',
      'tooltip_unit_count': ' words',
      'tooltip_unit_times': ' times',
      'tooltip_unit_percent': '%',
      'selected_filters': 'Selected Filters',
      'tooltip_all_filters': 'All Filters',
      'tooltip_pos_filter': 'POS Filter',
      'tooltip_type_filter': 'Type Filter',
      
      // 다이얼로그
      'delete_selected_title': 'Delete Selected Records',
      'delete_selected_message':
          'Delete {count} selected records?\nThis action cannot be undone.',
      'clear_all_title': 'Clear All Records',
      'clear_all_message':
          'Clear all recent study records?\nThis action cannot be undone.',
      'edit_name_title': 'Edit Name',
      'edit_name_hint': 'New name',
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
  static String get sectionRecentStudy => get('section_recent_study');
  static String get recentStudyTitle => get('recent_study_title');

  // 빈 상태
  static String get noRecentStudyTitle => get('no_recent_study_title');
  static String get noRecentStudyMessage => get('no_recent_study_message');
  static String get noRecentStudy => get('no_recent_study');
  static String get startStudyToSeeRecords => get('start_study_to_see_records');

  // 선택 관련
  static String get cancelSelection => get('cancel_selection');
  static String get selectMode => get('select_mode');
  static String get selectClear => get('select_clear');
  static String get clearAll => get('clear_all');

  // 기록 정보
  static String get totalSessions => get('total_sessions');
  static String get accuracy => get('accuracy');
  static String get lastStudyDate => get('last_study_date');

  // 시간 표시
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
  static String monthsAgo(int months) =>
      get('months_ago', params: {'months': months});
  static String get noRecent => get('no_recent');
  static String get today => get('today');
  static String get yesterday => get('yesterday');

  // 학습 모드 텍스트
  static String get studyModeCard => get('study_mode_card');
  static String get studyModeFavorites => get('study_mode_favorites');
  static String get studyModeWrongWords => get('study_mode_wrong_words');
  static String get studyModeUrgentReview => get('study_mode_urgent_review');
  static String get studyModeRecommendedReview => get('study_mode_recommended_review');
  static String get studyModeLeisureReview => get('study_mode_leisure_review');
  static String get studyModeForgettingRisk => get('study_mode_forgetting_risk');

  // 툴팁 메시지
  static String get tooltipVocabulary => get('tooltip_vocabulary');
  static String get tooltipWordCount => get('tooltip_word_count');
  static String get tooltipStudyMode => get('tooltip_study_mode');
  static String get tooltipDisplayOrder => get('tooltip_display_order');
  static String get tooltipTotalSessions => get('tooltip_total_sessions');
  static String get tooltipProgress => get('tooltip_progress');
  static String get tooltipTargetModeTarget =>
      get('tooltip_target_mode_target');
  static String get tooltipTargetModeReference =>
      get('tooltip_target_mode_reference');
  static String get tooltipTargetModeRandom =>
      get('tooltip_target_mode_random');
  static String get tooltipUnitCount => get('tooltip_unit_count');
  static String get tooltipUnitTimes => get('tooltip_unit_times');
  static String get tooltipUnitPercent => get('tooltip_unit_percent');
  static String get selectedFilters => get('selected_filters');
  static String get tooltipAllFilters => get('tooltip_all_filters');
  static String get tooltipPosFilter => get('tooltip_pos_filter');
  static String get tooltipTypeFilter => get('tooltip_type_filter');

  // 다이얼로그
  static String get deleteSelectedTitle => get('delete_selected_title');
  static String deleteSelectedMessage(int count) =>
      get('delete_selected_message', params: {'count': count});
  static String get clearAllTitle => get('clear_all_title');
  static String get clearAllMessage => get('clear_all_message');
  static String get editNameTitle => get('edit_name_title');
  static String get editNameHint => get('edit_name_hint');
}