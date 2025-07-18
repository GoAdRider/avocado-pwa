import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎯 간소화된 고성능 JSON 다국어 시스템
/// 앱 시작시 모든 JSON을 한번에 로드하고 메모리에 캐시
class SimpleI18n {
  static SimpleI18n? _instance;
  static SimpleI18n get instance => _instance ??= SimpleI18n._();
  SimpleI18n._();

  // 현재 언어
  String _currentLanguage = 'kr';
  String get currentLanguage => _currentLanguage;

  // 🚀 초고속 플랫 캐시: 모든 문자열을 "언어:네임스페이스:키" 형태로 저장
  final Map<String, String> _cache = {};
  
  // 로드 완료 상태
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// 앱 시작시 모든 JSON 파일을 한번에 로드 (main.dart에서 호출)
  Future<void> loadAll() async {
    if (_isLoaded) return;
    
    print('🌐 Loading all JSON files...');
    final stopwatch = Stopwatch()..start();
    
    // 모든 네임스페이스 정의
    final namespaces = [
      'common',
      'home/filter',
      'home/study_status', 
      'home/vocabulary_list',
      'home/recent_study',
      'home/forgetting_curve',
      'word_card',
      'dialogs/vocabulary_import',
      'dialogs/shortcuts',
      'dialogs/daily_goals',
      'dialogs/word_delete',
    ];
    
    // 지원 언어
    final languages = ['kr', 'en'];
    
    // 병렬로 모든 JSON 파일 로드
    final futures = <Future>[];
    for (final lang in languages) {
      for (final ns in namespaces) {
        futures.add(_loadNamespace(lang, ns));
      }
    }
    
    await Future.wait(futures);
    
    _isLoaded = true;
    stopwatch.stop();
    print('✅ JSON loading complete: ${_cache.length} strings in ${stopwatch.elapsedMilliseconds}ms');
  }

  /// 개별 네임스페이스 로드
  Future<void> _loadNamespace(String language, String namespace) async {
    try {
      final path = 'assets/i18n/$namespace/$language.json';
      print('🔍 Loading i18n file: $path');
      final jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // 플랫 캐시에 저장
      _flattenToCache(data, language, namespace, '');
      print('✅ Successfully loaded $namespace/$language.json with ${data.length} root keys');
    } catch (e, stackTrace) {
      print('❌ Failed to load $namespace/$language.json: $e');
      print('📍 Stack trace: $stackTrace');
    }
  }

  /// JSON을 플랫 구조로 변환하여 캐시에 저장
  void _flattenToCache(Map<String, dynamic> data, String language, String namespace, String prefix) {
    data.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      
      if (value is Map<String, dynamic>) {
        _flattenToCache(value, language, namespace, fullKey);
      } else if (value is String) {
        final cacheKey = '$language:$namespace:$fullKey';
        _cache[cacheKey] = value;
      }
    });
  }

  /// 언어 변경
  Future<void> setLanguage(String language) async {
    if (_currentLanguage != language.toLowerCase()) {
      _currentLanguage = language.toLowerCase();
      print('🌐 Language changed to: $_currentLanguage');
      // LanguageNotifier에게 변경 알림
      LanguageNotifier._notifyLanguageChanged();
    }
  }

  /// 문자열 조회 (초고속) with Fallback
  String tr(String key, {String namespace = 'common', Map<String, dynamic>? params}) {
    final cacheKey = '$_currentLanguage:$namespace:$key';
    String? cachedText = _cache[cacheKey];
    
    String text;
    
    if (cachedText == null) {
      // Fallback 1: 다른 언어에서 찾기
      final otherLang = _currentLanguage == 'kr' ? 'en' : 'kr';
      final fallbackKey = '$otherLang:$namespace:$key';
      cachedText = _cache[fallbackKey];
      
      if (cachedText == null) {
        // Fallback 2: 하드코딩된 기본 값들
        text = _getFallbackText(key, namespace);
        // 로그를 줄여서 성능 개선
        // print('❌ Using fallback for: $cacheKey -> $text (Cache size: ${_cache.length})');
      } else {
        text = cachedText;
        // print('⚠️ Using other language fallback: $cacheKey -> $text');
      }
    } else {
      text = cachedText;
    }
    
    // 파라미터 치환
    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v.toString());
      });
    }
    
    return text;
  }
  
  /// 하드코딩된 fallback 텍스트
  String _getFallbackText(String key, String namespace) {
    final isKr = _currentLanguage == 'kr';
    
    // 공통 번역들
    if (namespace == 'common') {
      switch (key) {
        case 'main.title': return isKr ? 'Do a Vocabulary!' : 'Do a Vocabulary!';
        case 'header.edit_toggle': return isKr ? '단축키' : 'Shortcuts';
        case 'actions.start': return isKr ? '시작' : 'Start';
        case 'dialog.ok': return isKr ? '확인' : 'OK';
        case 'dialog.cancel': return isKr ? '취소' : 'Cancel';
        case 'units.words': return isKr ? '개' : 'words';
        case 'units.count': return isKr ? '회' : 'times';
        case 'units.percent': return isKr ? '%' : '%';
        case 'units.days': return isKr ? '일' : 'days';
        case 'footer.default_quote': return isKr ? '배움은 평생의 여정입니다. 매일 조금씩 성장하세요.' : 'Learning is a lifelong journey. Grow a little every day.';
      }
    }
    
    // 홈 화면 번역들
    if (namespace == 'home/study_status') {
      switch (key) {
        case 'section.title': return isKr ? '학습 현황' : 'Study Status';
        case 'stats.todays_goal': return isKr ? '오늘의 목표' : "Today's Goal";
        case 'stats.detailed_stats': return isKr ? '상세 통계' : 'Detailed Stats';
      }
    }
    
    if (namespace == 'home/forgetting_curve') {
      switch (key) {
        case 'review_types.smart_review': return isKr ? '망각곡선 기반 복습' : 'Forgetting Curve Review';
        case 'review_types.urgent_review': return isKr ? '긴급 복습' : 'Urgent Review';
        case 'review_types.recommended_review': return isKr ? '추천 복습' : 'Recommended Review';
        case 'review_types.preview_review': return isKr ? '미리 복습' : 'Preview Review';
        case 'review_types.forgotten_review': return isKr ? '망각 위험' : 'Forgotten Risk';
        case 'descriptions.urgent_review': return isKr ? '24시간 이내 복습이 필요한 단어들' : 'Words that need review within 24 hours';
        case 'descriptions.recommended_review': return isKr ? '2-7일 이내 복습하면 좋은 단어들' : 'Words recommended for review within 2-7 days';
        case 'descriptions.preview_review': return isKr ? '7일 후 복습 예정인 단어들을 미리 보기' : 'Preview words scheduled for review after 7 days';
        case 'descriptions.forgotten_review': return isKr ? '14일 이상 복습하지 않은 망각 위험 단어들' : 'Words at risk of being forgotten (14+ days since last review)';
      }
    }
    
    if (namespace == 'home/recent_study') {
      switch (key) {
        case 'section.title': return isKr ? '최근 학습 기록' : 'Recent Study Records';
        case 'section.max_records': return isKr ? '최대 10개까지만 보관' : 'Max 10 records kept';
      }
    }
    
    if (namespace == 'home/vocabulary_list') {
      switch (key) {
        case 'section.title': return isKr ? '어휘집 목록' : 'Vocabulary List';
        case 'guide.total_words': return isKr ? '총 단어수' : 'Total Words';
        case 'guide.favorites': return isKr ? '즐겨찾기' : 'Favorites';
        case 'guide.wrong_words': return isKr ? '틀린단어' : 'Wrong Words';
        case 'guide.wrong_count': return isKr ? '틀린횟수' : 'Wrong Count';
        case 'guide.add_new_vocab': return isKr ? '새로운\n어휘집 추가하기' : 'Add New\nVocabulary';
        case 'stats.calculating': return isKr ? '계산 중...' : 'Calculating...';
        case 'actions.select_all': return isKr ? '모두 선택' : 'Select All';
        case 'actions.unselect_all': return isKr ? '모두 해제' : 'Unselect All';
        case 'mode.single_select': return isKr ? '단일 선택' : 'Single Select';
      }
    }
    
    if (namespace == 'home/recent_study') {
      switch (key) {
        case 'section.title': return isKr ? '최근 학습 기록' : 'Recent Study Records';
        case 'status.no_recent_study': return isKr ? '최근 학습 기록이 없습니다' : 'No recent study records';
        case 'status.start_study_to_see_records': return isKr ? '학습을 시작하면 기록이 표시됩니다' : 'Start studying to see records';
      }
    }
    
    if (namespace == 'home/filter') {
      switch (key) {
        case 'section.title': return isKr ? '필터' : 'Filter';
        case 'stats.filtered_words': return isKr ? '필터링된 단어' : 'Filtered Words';
        case 'ui.no_selection_guide': return isKr ? '어휘집을 먼저 선택해주세요' : 'Please select vocabulary first';
        case 'ui.filter_select_vocab_first': return isKr ? '어휘집을 선택하면 필터를 사용할 수 있습니다' : 'Select vocabulary to use filters';
      }
    }
    
    // 추가 study_status fallback
    if (namespace == 'home/study_status') {
      switch (key) {
        case 'section.study_mode': return isKr ? '위주 학습 설정' : 'Study Mode Setting';
        case 'section.learning_method': return isKr ? '학습 방법' : 'Learning Method';
        case 'study_mode.target_voca': return isKr ? 'TargetVoca 위주' : 'Target Vocabulary';
        case 'study_mode.reference_voca': return isKr ? 'ReferenceVoca 위주' : 'Reference Vocabulary';
        case 'study_mode.random_mode': return isKr ? 'Random 모드' : 'Random Mode';
        case 'learning_method.card_study': return isKr ? '통합 단어카드 학습' : 'Integrated Card Study';
        case 'learning_method.favorite_review': return isKr ? '즐겨찾기 복습' : 'Favorites Review';
        case 'learning_method.game_study': return isKr ? '게임 학습' : 'Game Study';
        case 'learning_method.wrong_word_study': return isKr ? '틀린단어 학습' : 'Wrong Words Study';
        case 'stats.total_words': return isKr ? '총 단어수' : 'Total Words';
        case 'stats.total_favorites': return isKr ? '총 즐겨찾기' : 'Total Favorites';
        case 'stats.total_wrong_words': return isKr ? '총 틀린단어' : 'Total Wrong Words';
        case 'stats.total_wrong_count': return isKr ? '총 틀린횟수' : 'Total Wrong Count';
        case 'stats.average_accuracy': return isKr ? '평균 정답률' : 'Average Accuracy';
        case 'stats.study_streak': return isKr ? '연속 학습' : 'Study Streak';
      }
    }
    
    // 다이얼로그 fallback
    if (namespace == 'dialogs/vocabulary_import') {
      switch (key) {
        case 'title': return isKr ? '새로운 어휘집 추가하기' : 'Add New Vocabulary';
        case 'drag_drop_active': return isKr ? '파일을 여기에 놓으세요' : 'Drop files here';
        case 'drag_multiple_files': return isKr ? '여러 CSV 파일을 여기에 드래그하세요' : 'Drag multiple CSV files here';
        case 'csv_only_support': return isKr ? '.csv 파일만 지원됩니다' : '.csv files only supported';
        case 'or_divider': return isKr ? '또는' : 'or';
        case 'select_files': return isKr ? '파일 선택' : 'Select Files';
        case 'processing_file': return isKr ? '파일을 처리하고 있습니다...' : 'Processing files...';
        case 'importing_files': return isKr ? '가져오는 중...' : 'Importing...';
        case 'help.title': return isKr ? 'CSV 파일 형식 안내' : 'CSV File Format Guide';
        case 'help.header_rule': return isKr ? '• 첫 번째 줄은 헤더여야 합니다' : '• First line must be header';
        case 'help.required_columns': return isKr ? '• 필수 컬럼: TargetVoca, ReferenceVoca' : '• Required columns: TargetVoca, ReferenceVoca';
        case 'help.optional_columns': return isKr ? '• 선택 컬럼: POS, Type, TargetPronunciation, TargetDesc, ReferenceDesc, TargetEx, ReferenceEx, Favorites' : '• Optional columns: POS, Type, TargetPronunciation, TargetDesc, ReferenceDesc, TargetEx, ReferenceEx, Favorites';
        case 'help.encoding': return isKr ? '• UTF-8 인코딩으로 저장해주세요' : '• Save with UTF-8 encoding';
        case 'help.multiple_files': return isKr ? '• 한 번에 여러 CSV 파일을 선택하거나 드래그할 수 있습니다.' : '• You can select or drag multiple CSV files at once.';
      }
    }
    
    // 기본 fallback
    return '[$namespace:$key]';
  }
}

/// 🎯 전역 번역 함수 - 간단하고 빠름
String tr(String key, {String namespace = 'common', Map<String, dynamic>? params}) {
  return SimpleI18n.instance.tr(key, namespace: namespace, params: params);
}

/// 언어 변경 함수
Future<void> changeLanguage(String language) async {
  await SimpleI18n.instance.setLanguage(language);
}

/// 언어 토글 (한국어 ↔ 영어)
Future<void> toggleLanguage() async {
  final current = SimpleI18n.instance.currentLanguage;
  final newLang = current == 'kr' ? 'en' : 'kr';
  await changeLanguage(newLang);
}

/// 현재 언어가 한국어인지 확인
bool get isKorean => SimpleI18n.instance.currentLanguage == 'kr';

/// Flutter 위젯을 위한 언어 변경 알림 Provider (최소화)
class LanguageNotifier extends ChangeNotifier {
  static LanguageNotifier? _instance;
  static LanguageNotifier get instance => _instance ??= LanguageNotifier._();
  LanguageNotifier._();

  String get currentLanguage => SimpleI18n.instance.currentLanguage;
  bool get isKorean => SimpleI18n.instance.currentLanguage == 'kr';

  Future<void> toggle() async {
    await toggleLanguage();
    notifyListeners(); // 모든 위젯에 언어 변경 알림
  }
  
  /// SimpleI18n에서 언어 변경 시 호출
  static void _notifyLanguageChanged() {
    instance.notifyListeners();
  }
}