class ForgettingCurveStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 망각곡선 복습 시스템
      'section_smart_review': '🧠 망각곡선 기반 복습',
      'smart_review_title': '🧠 망각곡선 기반 복습',
      'urgent_review': '긴급 복습 ({count}개) - 놓치면 기억에서 사라져요!',
      'recommended_review': '권장 복습 ({count}개) - 오늘 하면 기억력 UP!',
      'optional_review': '여유 복습 ({count}개) - 시간 날 때 해보세요',
      'forgetting_risk': '망각 위험 ({count}개) - 기억에서 사라지고 있어요!',
      
      'urgent_review_title': '긴급 복습',
      'urgent_review_desc': '놓치면 기억에서 사라져요!',
      'recommended_review_title': '권장 복습',
      'recommended_review_desc': '오늘 하면 기억력 UP!',
      'preview_review_title': '여유 복습',
      'preview_review_desc': '시간 날 때 해보세요',
      'forgotten_review_title': '망각 위험',
      'forgotten_review_desc': '기억에서 사라지고 있어요!',
      
      // 학습 모드별 텍스트
      'study_mode_urgent_review': '🔴 긴급 복습',
      'study_mode_recommended_review': '🟡 권장 복습',
      'study_mode_leisure_review': '🟢 여유 복습',
      'study_mode_forgetting_risk': '⚠️ 망각 위험',
      'study_mode_smart_review': '🧠 망각곡선 기반 복습',
    },
    'EN': {
      // 망각곡선 복습 시스템
      'section_smart_review': '🧠 Forgetting Curve Review',
      'smart_review_title': '🧠 Forgetting Curve Review',
      'urgent_review': 'Urgent Review ({count}) - Don\'t miss or forget!',
      'recommended_review': 'Recommended Review ({count}) - Perfect timing!',
      'optional_review': 'Optional Review ({count}) - When you have time',
      'forgetting_risk': 'Forgetting Risk ({count}) - Fading from memory!',
      
      'urgent_review_title': 'Urgent Review',
      'urgent_review_desc': 'Will disappear from memory if missed!',
      'recommended_review_title': 'Recommended Review',
      'recommended_review_desc': 'Perfect timing for memory boost!',
      'preview_review_title': 'Optional Review',
      'preview_review_desc': 'When you have time',
      'forgotten_review_title': 'Forgetting Risk',
      'forgotten_review_desc': 'Fading from memory!',
      
      // 학습 모드별 텍스트
      'study_mode_urgent_review': '🔴 Urgent Review',
      'study_mode_recommended_review': '🟡 Recommended Review',
      'study_mode_leisure_review': '🟢 Leisure Review',
      'study_mode_forgetting_risk': '⚠️ Forgetting Risk',
      'study_mode_smart_review': '🧠 Smart Review',
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
  static String get sectionSmartReview => get('section_smart_review');
  static String get smartReviewTitle => get('smart_review_title');

  // 복습 관련
  static String urgentReview(int count) =>
      get('urgent_review', params: {'count': count});
  static String recommendedReview(int count) =>
      get('recommended_review', params: {'count': count});
  static String optionalReview(int count) =>
      get('optional_review', params: {'count': count});
  static String forgettingRisk(int count) =>
      get('forgetting_risk', params: {'count': count});

  static String get urgentReviewTitle => get('urgent_review_title');
  static String get urgentReviewDesc => get('urgent_review_desc');
  static String get recommendedReviewTitle => get('recommended_review_title');
  static String get recommendedReviewDesc => get('recommended_review_desc');
  static String get previewReviewTitle => get('preview_review_title');
  static String get previewReviewDesc => get('preview_review_desc');
  static String get forgottenReviewTitle => get('forgotten_review_title');
  static String get forgottenReviewDesc => get('forgotten_review_desc');

  // 학습 모드 텍스트
  static String get studyModeUrgentReview => get('study_mode_urgent_review');
  static String get studyModeRecommendedReview =>
      get('study_mode_recommended_review');
  static String get studyModeLeisureReview => get('study_mode_leisure_review');
  static String get studyModeForgettingRisk =>
      get('study_mode_forgetting_risk');
  static String get studyModeSmartReview => get('study_mode_smart_review');
}