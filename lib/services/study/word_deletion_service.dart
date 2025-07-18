import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/vocabulary_word.dart';
import '../common/vocabulary_service.dart';
import '../common/temporary_delete_service.dart';
import 'study_session_manager.dart';

/// 학습 중 단어 삭제 처리를 담당하는 서비스
class WordDeletionService {
  static WordDeletionService? _instance;
  static WordDeletionService get instance => _instance ??= WordDeletionService._internal();
  WordDeletionService._internal();

  final VocabularyService _vocabularyService = VocabularyService.instance;
  final TemporaryDeleteService _tempDeleteService = TemporaryDeleteService.instance;
  final StudySessionManager _sessionManager = StudySessionManager.instance;

  // 스트림 컨트롤러
  final StreamController<WordDeletionResult> _deletionController = StreamController<WordDeletionResult>.broadcast();
  
  /// 단어 삭제 결과 스트림
  Stream<WordDeletionResult> get deletionStream => _deletionController.stream;

  /// 임시 삭제 처리
  Future<WordDeletionResult> temporaryDelete(VocabularyWord word) async {
    try {
      _tempDeleteService.addTemporarilyDeletedWord(word.id);
      _sessionManager.removeWordFromSession(word);
      
      final result = WordDeletionResult(
        success: true,
        isTemporary: true,
        word: word,
        message: '단어 "${word.targetVoca}"이(가) 이 세션에서 임시 삭제되었습니다.',
      );
      
      _deletionController.add(result);
      debugPrint('🗑️ 임시삭제 완료: ${word.targetVoca}');
      return result;
    } catch (e) {
      final result = WordDeletionResult(
        success: false,
        isTemporary: true,
        word: word,
        message: '임시 삭제 중 오류가 발생했습니다: $e',
      );
      
      _deletionController.add(result);
      debugPrint('❌ 임시삭제 실패: ${word.targetVoca} - $e');
      return result;
    }
  }

  /// 영구 삭제 처리
  Future<WordDeletionResult> permanentDelete(VocabularyWord word) async {
    try {
      final success = await _vocabularyService.deleteVocabularyWord(word.vocabularyFile, word.id);
      
      if (success) {
        // 모든 세션에서 단어 제거 (영구삭제되었으므로)
        _tempDeleteService.removeFromAllSessions(word.id);
        _sessionManager.removeWordFromSession(word);
        
        final result = WordDeletionResult(
          success: true,
          isTemporary: false,
          word: word,
          message: '단어 "${word.targetVoca}"이(가) 영구 삭제되었습니다.',
        );
        
        _deletionController.add(result);
        debugPrint('🗑️ 영구삭제 완료: ${word.targetVoca}');
        return result;
      } else {
        final result = WordDeletionResult(
          success: false,
          isTemporary: false,
          word: word,
          message: '단어 삭제에 실패했습니다.',
        );
        
        _deletionController.add(result);
        debugPrint('❌ 영구삭제 실패: ${word.targetVoca}');
        return result;
      }
    } catch (e) {
      final result = WordDeletionResult(
        success: false,
        isTemporary: false,
        word: word,
        message: '삭제 중 오류가 발생했습니다: $e',
      );
      
      _deletionController.add(result);
      debugPrint('❌ 영구삭제 오류: ${word.targetVoca} - $e');
      return result;
    }
  }

  /// 세션 종료 확인 (모든 단어가 삭제되었는지)
  bool shouldEndSession() {
    final session = _sessionManager.currentSession;
    return session?.words.isEmpty ?? true;
  }

  /// 삭제 후 세션 상태 확인
  SessionDeletionState getSessionStateAfterDeletion() {
    final session = _sessionManager.currentSession;
    
    if (session == null) {
      return SessionDeletionState.sessionEnded;
    }
    
    if (session.words.isEmpty) {
      return SessionDeletionState.allWordsDeleted;
    }
    
    return SessionDeletionState.continueSession;
  }

  /// 서비스 정리
  void dispose() {
    _deletionController.close();
  }
}

/// 단어 삭제 결과 클래스
class WordDeletionResult {
  final bool success;
  final bool isTemporary;
  final VocabularyWord word;
  final String message;

  WordDeletionResult({
    required this.success,
    required this.isTemporary,
    required this.word,
    required this.message,
  });

  /// 성공적인 임시 삭제 결과인지 확인
  bool get isSuccessfulTemporaryDeletion => success && isTemporary;
  
  /// 성공적인 영구 삭제 결과인지 확인
  bool get isSuccessfulPermanentDeletion => success && !isTemporary;
  
  /// 삭제 실패 결과인지 확인
  bool get isFailure => !success;
}

/// 삭제 후 세션 상태 열거형
enum SessionDeletionState {
  continueSession,    // 계속 학습
  allWordsDeleted,    // 모든 단어 삭제됨
  sessionEnded,       // 세션 종료됨
}