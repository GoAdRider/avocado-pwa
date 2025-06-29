class FilterStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 필터 섹션 제목
      'section_pos_type_filter': '🎯 품사/타입 필터 (선택사항)',
      
      // 필터 UI
      'pos_filter': '🔍 품사 필터',
      'type_filter': '🏷️ 어휘 타입 필터',
      'selected_filters': '📌 선택된 필터: ',
      'filter_no_selection_guide': '{filterType}을(를) 보려면',
      'filter_select_vocab_first': '먼저 어휘집을 선택해주세요',
      'pos_not_available': '품사정보없음',
      'type_not_available': '타입정보없음',
      
      // 필터 통계
      'filtered_words': '필터된 단어: 📝{words}개 ⭐{favorites}개 ❌{wrong}개 🔢{wrongCount}회',
      
      // 툴팁 필터 관련
      'tooltip_all_filters': '전체단어',
      'tooltip_pos_filter': '품사필터',
      'tooltip_type_filter': '타입필터',
    },
    'EN': {
      // 필터 섹션 제목
      'section_pos_type_filter': '🎯 POS/Type Filter (Optional)',
      
      // 필터 UI
      'pos_filter': '🔍 POS Filter',
      'type_filter': '🏷️ Type Filter',
      'selected_filters': '📌 Selected Filters: ',
      'filter_no_selection_guide': 'To see {filterType}',
      'filter_select_vocab_first': 'Please select vocabulary first',
      'pos_not_available': 'No POS Info',
      'type_not_available': 'No Type Info',
      
      // 필터 통계
      'filtered_words': 'Filtered: 📝{words} ⭐{favorites} ❌{wrong} 🔢{wrongCount}',
      
      // 툴팁 필터 관련
      'tooltip_all_filters': 'All Words',
      'tooltip_pos_filter': 'POS Filter',
      'tooltip_type_filter': 'Type Filter',
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
  static String get sectionPosTypeFilter => get('section_pos_type_filter');

  // 필터 UI
  static String get posFilter => get('pos_filter');
  static String get typeFilter => get('type_filter');
  static String get selectedFilters => get('selected_filters');
  static String filterNoSelectionGuide(String filterType) =>
      get('filter_no_selection_guide', params: {'filterType': filterType});
  static String get filterSelectVocabFirst => get('filter_select_vocab_first');
  static String get posNotAvailable => get('pos_not_available');
  static String get typeNotAvailable => get('type_not_available');

  // 필터 통계
  static String filteredWords({
    required int words,
    required int favorites,
    required int wrong,
    required int wrongCount,
  }) =>
      get('filtered_words', params: {
        'words': words,
        'favorites': favorites,
        'wrong': wrong,
        'wrongCount': wrongCount
      });

  // 툴팁
  static String get tooltipAllFilters => get('tooltip_all_filters');
  static String get tooltipPosFilter => get('tooltip_pos_filter');
  static String get tooltipTypeFilter => get('tooltip_type_filter');
}