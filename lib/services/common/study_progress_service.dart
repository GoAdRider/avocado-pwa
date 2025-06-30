import '../../models/study_progress.dart';
import '../../models/vocabulary_word.dart';
import 'hive_service.dart';

/// 학습 진행률을 관리하는 서비스
/// 사용자가 학습을 중단한 지점을 저장하고, 이어하기 기능을 제공합니다.
class StudyProgressService {
  static StudyProgressService? _instance;
  static StudyProgressService get instance => _instance ??= StudyProgressService._internal();
  StudyProgressService._internal();

  final HiveService _hiveService = HiveService.instance;

  /// 세션 키 생성 (TemporaryDeleteService와 동일한 형식)
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
    
    return 'study_progress:$vocabKey|$studyMode|$targetMode|pos:$posKey|type:$typeKey';
  }

  /// 학습 진행률 저장
  Future<void> saveProgress({
    required String sessionKey,
    required int currentIndex,
    required List<VocabularyWord> words,
    required bool isShuffled,
    required String studyMode,
    required String targetMode,
    required List<String> vocabularyFiles,
    required List<String> posFilters,
    required List<String> typeFilters,
  }) async {
    try {
      // 단어 순서를 ID 리스트로 저장
      final wordOrder = words.map((word) => word.id).toList();
      
      final progress = StudyProgress(
        sessionKey: sessionKey,
        currentIndex: currentIndex,
        totalWords: words.length,
        wordOrder: wordOrder,
        isShuffled: isShuffled,
        lastStudyTime: DateTime.now(),
        studyMode: studyMode,
        targetMode: targetMode,
        vocabularyFiles: vocabularyFiles,
        posFilters: posFilters,
        typeFilters: typeFilters,
      );

      final box = _hiveService.studyProgressBox;
      await box.put(sessionKey, progress);
      
      print('📊 학습 진행률 저장: ${progress.progressText} (${isShuffled ? "섞임" : "순서대로"})');
    } catch (e) {
      print('📊 학습 진행률 저장 실패: $e');
    }
  }

  /// 학습 진행률 조회
  StudyProgress? getProgress(String sessionKey) {
    try {
      final box = _hiveService.studyProgressBox;
      final progress = box.get(sessionKey);
      
      if (progress != null) {
        print('📊 학습 진행률 로드: ${progress.progressText} (${progress.isShuffled ? "섞임" : "순서대로"})');
      }
      
      return progress;
    } catch (e) {
      print('📊 학습 진행률 조회 실패: $e');
      return null;
    }
  }

  /// 학습 완료 시 진행률 삭제
  Future<void> clearProgress(String sessionKey) async {
    try {
      final box = _hiveService.studyProgressBox;
      await box.delete(sessionKey);
      print('📊 학습 진행률 삭제: $sessionKey');
    } catch (e) {
      print('📊 학습 진행률 삭제 실패: $e');
    }
  }

  /// 모든 진행률 초기화
  Future<void> clearAllProgress() async {
    try {
      final box = _hiveService.studyProgressBox;
      await box.clear();
      print('📊 모든 학습 진행률 초기화');
    } catch (e) {
      print('📊 학습 진행률 초기화 실패: $e');
    }
  }

  /// 단어 목록을 저장된 순서대로 재정렬
  List<VocabularyWord> restoreWordOrder(List<VocabularyWord> words, StudyProgress progress) {
    try {
      // 단어 ID를 키로 하는 맵 생성
      final wordMap = {for (var word in words) word.id: word};
      
      // 저장된 순서대로 단어 재정렬
      final orderedWords = <VocabularyWord>[];
      for (final wordId in progress.wordOrder) {
        final word = wordMap[wordId];
        if (word != null) {
          orderedWords.add(word);
        }
      }
      
      // 저장된 순서에 없는 새로운 단어들은 뒤에 추가
      for (final word in words) {
        if (!progress.wordOrder.contains(word.id)) {
          orderedWords.add(word);
        }
      }
      
      print('📊 단어 순서 복원: ${orderedWords.length}개 (${progress.isShuffled ? "섞임" : "순서대로"})');
      return orderedWords;
    } catch (e) {
      print('📊 단어 순서 복원 실패: $e');
      return words; // 실패 시 원본 반환
    }
  }

  /// 특정 어휘집의 모든 진행률 삭제 (어휘집 삭제 시 호출)
  Future<void> clearProgressByVocabulary(String vocabularyFile) async {
    try {
      final box = _hiveService.studyProgressBox;
      final keysToDelete = <String>[];
      
      for (final key in box.keys) {
        final progress = box.get(key);
        if (progress != null && progress.vocabularyFiles.contains(vocabularyFile)) {
          keysToDelete.add(key);
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      
      print('📊 어휘집 관련 진행률 삭제: $vocabularyFile (${keysToDelete.length}개)');
    } catch (e) {
      print('📊 어휘집 관련 진행률 삭제 실패: $e');
    }
  }

  /// 진행률이 있는 학습 세션 목록 조회
  List<StudyProgress> getAllProgress() {
    try {
      final box = _hiveService.studyProgressBox;
      return box.values.toList();
    } catch (e) {
      print('📊 모든 진행률 조회 실패: $e');
      return [];
    }
  }
}