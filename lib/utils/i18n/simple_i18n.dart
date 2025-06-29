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
      final jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // 플랫 캐시에 저장
      _flattenToCache(data, language, namespace, '');
    } catch (e) {
      print('⚠️ Failed to load $namespace/$language.json: $e');
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

  /// 문자열 조회 (초고속)
  String tr(String key, {String namespace = 'common', Map<String, dynamic>? params}) {
    final cacheKey = '$_currentLanguage:$namespace:$key';
    String? cachedText = _cache[cacheKey];
    
    String text;
    // 디버깅을 위한 로그
    if (cachedText == null) {
      print('❌ Missing translation: $cacheKey (available: ${_cache.keys.where((k) => k.startsWith('$_currentLanguage:$namespace:')).take(3).toList()})');
      text = '[$namespace:$key]';
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