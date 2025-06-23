class StudyStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 학습 모드 타이틀
      'card_study': '단어카드 학습',
      'favorite_review': '즐겨찾기 복습',
      'wrong_words_study': '틀린단어 학습',
      'urgent_review': '긴급 복습',
      'recommended_review': '권장 복습',
      'leisure_review': '여유 복습',
      'forgetting_risk': '망각 위험',

      // 진행도 정보
      'selected_vocabularies': '선택된 어휘집',
      'progress': '진행도',
      'vocabulary_count_suffix': '개',

      // 카드 정보
      'wrong_count_prefix': '❌[',
      'wrong_count_suffix': ']',
      'favorite_filled': '⭐',
      'favorite_empty': '☆',

      // 버튼 텍스트
      'previous': '← 이전',
      'flip': '🔄 뒤집기',
      'shuffle': '🔀 섞기',
      'next': '다음 →',
      'expand_details': '📖 설명 및 예시 펼치기',
      'collapse_details': '📖 설명 및 예시 접기',

      // 상세 정보 라벨
      'description_label': '설명:',
      'example_label': '예시:',

      // 키보드 안내
      'keyboard_guide': '키보드: ←→ 이동 | 스페이스 뒤집기 | R 섞기 | S 즐겨찾기 | D 설명',

      // 완료 메시지
      'study_completed': '학습을 완료했습니다!',
      'congratulations': '축하합니다!',
      'return_to_home': '홈으로 돌아가기',
      'continue_study': '계속 학습하기',

      // 오류 메시지
      'no_words_available': '학습할 단어가 없습니다',
      'loading_error': '데이터를 불러오는 중 오류가 발생했습니다',

      // 스낵바 메시지
      'favorite_added': '즐겨찾기에 추가했습니다',
      'favorite_removed': '즐겨찾기에서 제거했습니다',
      'words_shuffled': '단어 순서를 섞었습니다',
    },
    'EN': {
      // 학습 모드 타이틀
      'card_study': 'Card Study',
      'favorite_review': 'Favorite Review',
      'wrong_words_study': 'Wrong Words Study',
      'urgent_review': 'Urgent Review',
      'recommended_review': 'Recommended Review',
      'leisure_review': 'Leisure Review',
      'forgetting_risk': 'Forgetting Risk',

      // 진행도 정보
      'selected_vocabularies': 'Selected Vocabularies',
      'progress': 'Progress',
      'vocabulary_count_suffix': '',

      // 카드 정보
      'wrong_count_prefix': '❌[',
      'wrong_count_suffix': ']',
      'favorite_filled': '⭐',
      'favorite_empty': '☆',

      // 버튼 텍스트
      'previous': '← Previous',
      'flip': '🔄 Flip',
      'shuffle': '🔀 Shuffle',
      'next': 'Next →',
      'expand_details': '📖 Show Details',
      'collapse_details': '📖 Hide Details',

      // 상세 정보 라벨
      'description_label': 'Description:',
      'example_label': 'Example:',

      // 키보드 안내
      'keyboard_guide':
          'Keyboard: ←→ Navigate | Space Flip | R Shuffle | S Favorite | D Details',

      // 완료 메시지
      'study_completed': 'Study completed!',
      'congratulations': 'Congratulations!',
      'return_to_home': 'Return to Home',
      'continue_study': 'Continue Studying',

      // 오류 메시지
      'no_words_available': 'No words available',
      'loading_error': 'Error loading data',

      // 스낵바 메시지
      'favorite_added': 'Added to favorites',
      'favorite_removed': 'Removed from favorites',
      'words_shuffled': 'Words order shuffled',
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

  // 학습 모드 타이틀
  static String get cardStudy => get('card_study');
  static String get favoriteReview => get('favorite_review');
  static String get wrongWordsStudy => get('wrong_words_study');
  static String get urgentReview => get('urgent_review');
  static String get recommendedReview => get('recommended_review');
  static String get leisureReview => get('leisure_review');
  static String get forgettingRisk => get('forgetting_risk');

  // 진행도 정보
  static String get selectedVocabularies => get('selected_vocabularies');
  static String get progress => get('progress');
  static String get vocabularyCountSuffix => get('vocabulary_count_suffix');

  // 카드 정보
  static String get wrongCountPrefix => get('wrong_count_prefix');
  static String get wrongCountSuffix => get('wrong_count_suffix');
  static String get favoriteFilled => get('favorite_filled');
  static String get favoriteEmpty => get('favorite_empty');

  // 버튼 텍스트
  static String get previous => get('previous');
  static String get flip => get('flip');
  static String get shuffle => get('shuffle');
  static String get next => get('next');
  static String get expandDetails => get('expand_details');
  static String get collapseDetails => get('collapse_details');

  // 상세 정보 라벨
  static String get descriptionLabel => get('description_label');
  static String get exampleLabel => get('example_label');

  // 키보드 안내
  static String get keyboardGuide => get('keyboard_guide');

  // 완료 메시지
  static String get studyCompleted => get('study_completed');
  static String get congratulations => get('congratulations');
  static String get returnToHome => get('return_to_home');
  static String get continueStudy => get('continue_study');

  // 오류 메시지
  static String get noWordsAvailable => get('no_words_available');
  static String get loadingError => get('loading_error');

  // 스낵바 메시지
  static String get favoriteAdded => get('favorite_added');
  static String get favoriteRemoved => get('favorite_removed');
  static String get wordsShuffled => get('words_shuffled');
}
