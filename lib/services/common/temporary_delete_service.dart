import 'dart:collection';
import 'hive_service.dart';

/// 세션별 임시 삭제된 단어들을 관리하는 서비스
/// 특정 학습 세션(최근 학습 기록의 특정 설정)에 대해서만 임시 삭제를 적용하고,
/// Hive에 저장하여 앱 재시작 후에도 상태를 유지합니다.
class TemporaryDeleteService {
  static TemporaryDeleteService? _instance;
  static TemporaryDeleteService get instance => _instance ??= TemporaryDeleteService._internal();
  TemporaryDeleteService._internal();

  final HiveService _hiveService = HiveService.instance;
  
  // 현재 활성 세션의 임시 삭제 상태 (메모리 캐시)
  String? _currentSessionKey;
  final Set<String> _currentSessionDeletedWords = <String>{};

  /// 현재 학습 세션 시작 시 호출
  /// 세션 키는 어휘집파일+필터설정+학습모드+표시순서 조합으로 생성
  void startSession(String sessionKey) {
    print('🗑️ 임시삭제 세션 시작: $sessionKey');
    _currentSessionKey = sessionKey;
    _currentSessionDeletedWords.clear();
    
    // Hive에서 해당 세션의 임시 삭제 목록 로드
    _loadSessionDeletedWords(sessionKey);
  }

  /// 현재 세션의 임시 삭제 목록을 Hive에서 로드
  void _loadSessionDeletedWords(String sessionKey) {
    try {
      final box = _hiveService.temporaryDeleteBox;
      final sessionData = box.get(sessionKey);
      
      if (sessionData != null && sessionData is List) {
        _currentSessionDeletedWords.clear();
        _currentSessionDeletedWords.addAll(sessionData.cast<String>());
        print('🗑️ 세션 임시삭제 목록 로드: ${_currentSessionDeletedWords.length}개');
      }
    } catch (e) {
      print('🗑️ 세션 임시삭제 목록 로드 실패: $e');
    }
  }

  /// 현재 세션에서 단어를 임시 삭제 목록에 추가
  void addTemporarilyDeletedWord(String wordId) {
    if (_currentSessionKey == null) {
      print('🗑️ 경고: 활성 세션이 없습니다. 임시삭제 실패.');
      return;
    }
    
    _currentSessionDeletedWords.add(wordId);
    _saveCurrentSession();
    print('🗑️ 세션 임시삭제 추가: $wordId (총 ${_currentSessionDeletedWords.length}개)');
  }

  /// 현재 세션에서 단어가 임시 삭제되었는지 확인
  bool isTemporarilyDeleted(String wordId) {
    return _currentSessionDeletedWords.contains(wordId);
  }

  /// 특정 세션에서 단어가 임시 삭제되었는지 확인
  bool isTemporarilyDeletedInSession(String wordId, String sessionKey) {
    try {
      final box = _hiveService.temporaryDeleteBox;
      final sessionData = box.get(sessionKey);
      
      if (sessionData != null && sessionData is List) {
        return sessionData.contains(wordId);
      }
      return false;
    } catch (e) {
      print('🗑️ 세션별 임시삭제 확인 실패: $e');
      return false;
    }
  }

  /// 현재 세션의 임시 삭제 상태를 Hive에 저장
  void _saveCurrentSession() {
    if (_currentSessionKey == null) return;
    
    try {
      final box = _hiveService.temporaryDeleteBox;
      box.put(_currentSessionKey!, _currentSessionDeletedWords.toList());
      print('🗑️ 세션 임시삭제 상태 저장: $_currentSessionKey');
    } catch (e) {
      print('🗑️ 세션 임시삭제 상태 저장 실패: $e');
    }
  }

  /// 현재 세션의 임시 삭제된 모든 단어 ID 목록 반환
  Set<String> getAllTemporarilyDeletedWords() {
    return UnmodifiableSetView(_currentSessionDeletedWords);
  }

  /// 영구 삭제 시 모든 세션에서 해당 단어 제거
  void removeFromAllSessions(String wordId) {
    try {
      final box = _hiveService.temporaryDeleteBox;
      final allKeys = box.keys.toList();
      
      for (final key in allKeys) {
        final sessionData = box.get(key);
        if (sessionData != null && sessionData is List) {
          final wordList = sessionData.cast<String>();
          if (wordList.contains(wordId)) {
            wordList.remove(wordId);
            box.put(key, wordList);
          }
        }
      }
      
      // 현재 세션에서도 제거
      _currentSessionDeletedWords.remove(wordId);
      print('🗑️ 모든 세션에서 단어 제거: $wordId');
    } catch (e) {
      print('🗑️ 모든 세션에서 단어 제거 실패: $e');
    }
  }

  /// 세션 종료
  void endSession() {
    if (_currentSessionKey != null) {
      print('🗑️ 임시삭제 세션 종료: $_currentSessionKey');
      _saveCurrentSession();
      _currentSessionKey = null;
      _currentSessionDeletedWords.clear();
    }
  }

  /// 모든 임시 삭제 기록 초기화
  void clearAllTemporaryDeletes() {
    try {
      final box = _hiveService.temporaryDeleteBox;
      box.clear();
      _currentSessionDeletedWords.clear();
      print('🗑️ 모든 임시삭제 기록 초기화');
    } catch (e) {
      print('🗑️ 임시삭제 기록 초기화 실패: $e');
    }
  }

  /// 현재 세션의 임시 삭제된 단어 개수
  int get temporarilyDeletedCount => _currentSessionDeletedWords.length;

  /// 세션 키 생성 (어휘집파일+필터설정+학습모드+표시순서 조합)
  static String createSessionKey({
    required List<String> vocabularyFiles,
    required String studyMode,
    required String targetMode,
    required List<String> posFilters,
    required List<String> typeFilters,
  }) {
    final vocabKey = vocabularyFiles.join(',');
    final posKey = posFilters.isEmpty ? 'all' : posFilters.join(',');
    final typeKey = typeFilters.isEmpty ? 'all' : typeFilters.join(',');
    
    return 'temp_delete:$vocabKey|$studyMode|$targetMode|pos:$posKey|type:$typeKey';
  }

  /// 디버그용: 현재 세션의 임시 삭제된 단어들 출력
  void printTemporarilyDeletedWords() {
    print('🗑️ 현재 세션($_currentSessionKey) 임시삭제 단어들 (${_currentSessionDeletedWords.length}개):');
    for (final wordId in _currentSessionDeletedWords) {
      print('  - $wordId');
    }
  }
}