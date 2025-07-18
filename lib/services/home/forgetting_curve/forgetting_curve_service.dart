import 'dart:math';
import '../../../models/vocabulary_word.dart';
import '../../../models/word_stats.dart';
import '../../common/hive_service.dart';

/// 망각곡선 기반 복습 서비스
/// 에빙하우스 망각곡선 이론을 기반으로 한 간소화된 복습 스케줄링 시스템
class ForgettingCurveService {
  static ForgettingCurveService? _instance;
  static ForgettingCurveService get instance => _instance ??= ForgettingCurveService._internal();
  ForgettingCurveService._internal();

  final HiveService _hiveService = HiveService.instance;

  /// 망각곡선 기반 복습 타입 결정
  /// 각 단어의 학습 이력을 분석해서 복습 타입을 결정
  ReviewType getReviewType(VocabularyWord word) {
    final stats = _hiveService.getWordStats(word.id);
    final now = DateTime.now();
    
    // 한번도 학습하지 않은 단어는 긴급 복습
    if (stats == null || stats.lastStudyDate == null) {
      return ReviewType.urgent;
    }
    
    final daysSinceLastStudy = now.difference(stats.lastStudyDate!).inDays;
    final accuracy = _calculateAccuracy(stats);
    
    // 망각곡선 기반 복습 타입 결정
    if (daysSinceLastStudy >= 14) {
      return ReviewType.forgettingRisk;
    } else if (daysSinceLastStudy >= 7) {
      return ReviewType.preview;
    } else if (daysSinceLastStudy >= 2) {
      return ReviewType.recommended;
    } else if (daysSinceLastStudy >= 1 || accuracy < 0.6) {
      return ReviewType.urgent;
    } else {
      return ReviewType.preview;
    }
  }

  /// 각 복습 타입별 단어 필터링
  List<VocabularyWord> getWordsForReviewType(List<VocabularyWord> allWords, ReviewType type) {
    return allWords.where((word) {
      final reviewType = getReviewType(word);
      return reviewType == type;
    }).toList();
  }

  /// 긴급 복습 단어 개수 계산
  int getUrgentReviewCount(List<VocabularyWord> words) {
    return getWordsForReviewType(words, ReviewType.urgent).length;
  }

  /// 추천 복습 단어 개수 계산
  int getRecommendedReviewCount(List<VocabularyWord> words) {
    return getWordsForReviewType(words, ReviewType.recommended).length;
  }

  /// 미리 복습 단어 개수 계산
  int getPreviewReviewCount(List<VocabularyWord> words) {
    return getWordsForReviewType(words, ReviewType.preview).length;
  }

  /// 망각 위험 단어 개수 계산
  int getForgettingRiskCount(List<VocabularyWord> words) {
    return getWordsForReviewType(words, ReviewType.forgettingRisk).length;
  }

  /// 단어의 정답률 계산
  double _calculateAccuracy(WordStats stats) {
    final totalAttempts = stats.correctCount + stats.wrongCount;
    if (totalAttempts == 0) return 0.0;
    return stats.correctCount / totalAttempts;
  }

  /// 다음 복습 권장 날짜 계산 (망각곡선 기반)
  DateTime calculateNextReviewDate(VocabularyWord word) {
    final stats = _hiveService.getWordStats(word.id);
    final now = DateTime.now();
    
    if (stats == null || stats.lastStudyDate == null) {
      return now; // 즉시 복습 필요
    }
    
    final accuracy = _calculateAccuracy(stats);
    final studyCount = stats.correctCount + stats.wrongCount;
    
    // 망각곡선 기반 간격 계산 (간소화된 버전)
    int intervalDays;
    if (accuracy >= 0.9) {
      // 정답률이 높으면 간격을 늘림
      intervalDays = min(30, studyCount * 3);
    } else if (accuracy >= 0.7) {
      // 보통 정답률
      intervalDays = min(14, studyCount * 2);
    } else if (accuracy >= 0.5) {
      // 낮은 정답률
      intervalDays = min(7, studyCount);
    } else {
      // 매우 낮은 정답률
      intervalDays = 1;
    }
    
    return stats.lastStudyDate!.add(Duration(days: intervalDays));
  }

  /// 복습 우선순위 계산
  int getReviewPriority(VocabularyWord word) {
    final reviewType = getReviewType(word);
    switch (reviewType) {
      case ReviewType.urgent:
        return 1; // 최고 우선순위
      case ReviewType.forgettingRisk:
        return 2; // 두 번째 우선순위
      case ReviewType.recommended:
        return 3; // 세 번째 우선순위
      case ReviewType.preview:
        return 4; // 네 번째 우선순위
    }
  }

  /// 복습할 단어들을 우선순위별로 정렬
  List<VocabularyWord> sortWordsByPriority(List<VocabularyWord> words) {
    return words..sort((a, b) {
      final priorityA = getReviewPriority(a);
      final priorityB = getReviewPriority(b);
      return priorityA.compareTo(priorityB);
    });
  }
}

/// 복습 타입 열거형
enum ReviewType {
  urgent,        // 긴급 복습
  recommended,   // 추천 복습
  preview,       // 미리 복습
  forgettingRisk // 망각 위험
}