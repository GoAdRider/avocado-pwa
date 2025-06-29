import 'package:flutter/foundation.dart';
import '../../../models/study_record.dart';
import '../../../models/vocabulary_word.dart';
import '../../../utils/i18n/simple_i18n.dart';
import '../../common/hive_service.dart';
import '../../common/temporary_delete_service.dart';
import '../filter/filter_service.dart';

/// 최근 학습 기록 정보 클래스 (카드 학습만 포함)
class RecentStudyInfo {
  final String vocabularyFile; // 어휘집 파일명
  final DateTime lastStudyDate; // 마지막 학습 날짜
  final String studyMode; // 마지막 학습 모드 (card/favorites/wrong_words/smart_review)
  final int totalSessions; // 총 학습 세션 수
  final int totalWords; // 학습한 총 단어 수
  final double averageAccuracy; // 평균 정답률
  final List<String> posFilters; // 품사 필터
  final List<String> typeFilters; // 어휘 타입 필터
  final String targetMode; // 위주 학습 설정

  const RecentStudyInfo({
    required this.vocabularyFile,
    required this.lastStudyDate,
    required this.studyMode,
    required this.totalSessions,
    required this.totalWords,
    required this.averageAccuracy,
    required this.posFilters,
    required this.typeFilters,
    required this.targetMode,
  });

  /// 상대적 시간 표시 (예: "2시간 전", "1일 전")
  String get relativeTimeText {
    final now = DateTime.now();
    final difference = now.difference(lastStudyDate);

    if (difference.inMinutes < 60) {
      return tr('time.minutes_ago', namespace: 'home/recent_study', params: {'minutes': difference.inMinutes});
    } else if (difference.inHours < 24) {
      return tr('time.hours_ago', namespace: 'home/recent_study', params: {'hours': difference.inHours});
    } else if (difference.inDays < 7) {
      return tr('time.days_ago', namespace: 'home/recent_study', params: {'days': difference.inDays});
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return tr('time.weeks_ago', namespace: 'home/recent_study', params: {'weeks': weeks});
    } else {
      final months = (difference.inDays / 30).floor();
      return tr('time.months_ago', namespace: 'home/recent_study', params: {'months': months});
    }
  }

  /// 학습 모드 표시 텍스트
  String get studyModeText {
    switch (studyMode) {
      case 'card':
        return tr('study_modes.card', namespace: 'home/recent_study');
      case 'favorites':
        return tr('study_modes.favorites', namespace: 'home/recent_study');
      case 'wrong_words':
        return tr('study_modes.wrong_words', namespace: 'home/recent_study');
      case 'urgent_review':
        return tr('study_modes.urgent_review', namespace: 'home/forgetting_curve');
      case 'recommended_review':
        return tr('study_modes.recommended_review', namespace: 'home/forgetting_curve');
      case 'leisure_review':
        return tr('study_modes.leisure_review', namespace: 'home/forgetting_curve');
      case 'forgetting_risk':
        return tr('study_modes.forgetting_risk', namespace: 'home/forgetting_curve');
      case 'smart_review': // 기존 데이터 호환성을 위해 유지
        return tr('study_modes.smart_review', namespace: 'home/forgetting_curve');
      default:
        return tr('study_modes.card', namespace: 'home/recent_study');
    }
  }

  /// 정답률 텍스트 (백분율)
  String get accuracyText {
    return '${averageAccuracy.toStringAsFixed(1)}%';
  }
}

/// 최근 학습 기록 관리 서비스
class RecentStudyService {
  static final RecentStudyService _instance = RecentStudyService._internal();
  static RecentStudyService get instance => _instance;
  RecentStudyService._internal();

  final HiveService _hiveService = HiveService.instance;

  /// 최근 학습 기록 조회 (최대 개수 제한)
  /// 게임 모드는 제외하고 카드 학습만 포함 (card, favorites, wrong_words, smart_review)
  Future<List<RecentStudyInfo>> getRecentStudyRecords(
      {int maxCount = 10}) async {
    try {
      // 모든 학습 기록 가져오기
      final allRecords = _hiveService.getStudyRecords();

      // 카드 학습 모드만 필터링 (게임 제외)
      final cardStudyRecords = allRecords.where((record) {
        return record.studyMode == 'card' ||
            record.studyMode == 'favorites' ||
            record.studyMode == 'wrong_words' ||
            record.studyMode == 'urgent_review' ||
            record.studyMode == 'recommended_review' ||
            record.studyMode == 'leisure_review' ||
            record.studyMode == 'forgetting_risk' ||
            record.studyMode == 'smart_review'; // 기존 데이터 호환성
      }).toList();

      if (cardStudyRecords.isEmpty) {
        return [];
      }

      // 어휘집 + 필터 조합별로 그룹핑하여 최근 기록 추출
      final Map<String, List<StudyRecord>> groupedRecords = {};

      for (final record in cardStudyRecords) {
        final configKey = _createStudyConfigKey(record);
        groupedRecords.putIfAbsent(configKey, () => []).add(record);
      }

      // 어휘집별 최근 학습 정보 생성
      final List<RecentStudyInfo> recentInfos = [];

      for (final entry in groupedRecords.entries) {
        final records = entry.value;
        final vocabularyFile = records.first.vocabularyFile; // 실제 어휘집 파일명 추출

        // 날짜순 정렬 (최신순)
        records.sort((a, b) => b.studyDate.compareTo(a.studyDate));

        if (records.isNotEmpty) {
          final lastRecord = records.first;
          final totalSessions = records.length;
          final uniqueWords = records.map((r) => r.wordId).toSet().length;
          final correctCount = records.where((r) => r.isCorrect).length;
          final averageAccuracy =
              records.isNotEmpty ? (correctCount / records.length) * 100 : 0.0;

          recentInfos.add(RecentStudyInfo(
            vocabularyFile: vocabularyFile,
            lastStudyDate: lastRecord.studyDate,
            studyMode: lastRecord.studyMode,
            totalSessions: totalSessions,
            totalWords: uniqueWords,
            averageAccuracy: averageAccuracy,
            posFilters: lastRecord.posFilters ?? [],
            typeFilters: lastRecord.typeFilters ?? [],
            targetMode: lastRecord.targetMode ?? 'TargetVoca',
          ));
        }
      }

      // 최근 학습일 기준으로 정렬
      recentInfos.sort((a, b) => b.lastStudyDate.compareTo(a.lastStudyDate));

      // 최대 개수만큼 반환
      return recentInfos.take(maxCount).toList();
    } catch (e) {
      debugPrint('최근 학습 기록 조회 실패: $e');
      return [];
    }
  }

  /// 특정 어휘집의 최근 학습 정보 조회
  /// 게임 모드는 제외하고 카드 학습만 포함
  Future<RecentStudyInfo?> getVocabularyRecentInfo(
      String vocabularyFile) async {
    try {
      final allRecords =
          _hiveService.getStudyRecords(vocabularyFile: vocabularyFile);

      // 카드 학습 모드만 필터링 (게임 제외)
      final records = allRecords.where((record) {
        return record.studyMode == 'card' ||
            record.studyMode == 'favorites' ||
            record.studyMode == 'wrong_words' ||
            record.studyMode == 'urgent_review' ||
            record.studyMode == 'recommended_review' ||
            record.studyMode == 'leisure_review' ||
            record.studyMode == 'forgetting_risk' ||
            record.studyMode == 'smart_review'; // 기존 데이터 호환성
      }).toList();

      if (records.isEmpty) return null;

      // 날짜순 정렬 (최신순)
      records.sort((a, b) => b.studyDate.compareTo(a.studyDate));

      final lastRecord = records.first;
      final totalSessions = records.length;
      final uniqueWords = records.map((r) => r.wordId).toSet().length;
      final correctCount = records.where((r) => r.isCorrect).length;
      final averageAccuracy =
          records.isNotEmpty ? (correctCount / records.length) * 100 : 0.0;

      return RecentStudyInfo(
        vocabularyFile: vocabularyFile,
        lastStudyDate: lastRecord.studyDate,
        studyMode: lastRecord.studyMode,
        totalSessions: totalSessions,
        totalWords: uniqueWords,
        averageAccuracy: averageAccuracy,
        posFilters: lastRecord.posFilters ?? [],
        typeFilters: lastRecord.typeFilters ?? [],
        targetMode: lastRecord.targetMode ?? 'TargetVoca',
      );
    } catch (e) {
      debugPrint('어휘집 최근 학습 정보 조회 실패: $e');
      return null;
    }
  }

  /// 최근 학습 기록에서 어휘집 제거 (전체 어휘집 데이터 삭제)
  /// 주의: 이 메서드는 어휘집 자체를 완전 삭제합니다!
  Future<bool> removeVocabularyFromRecentStudy(String vocabularyFile) async {
    try {
      // 해당 어휘집의 모든 데이터 삭제 (VocabularyWord, Favorite, WordStats, StudyRecord 등)
      await _hiveService.clearVocabularyData(vocabularyFile);
      return true;
    } catch (e) {
      debugPrint('최근 학습 기록에서 어휘집 제거 실패: $e');
      return false;
    }
  }

  /// 특정 어휘집의 StudyRecord만 삭제 (어휘집 데이터는 유지)
  Future<bool> removeStudyRecordsOnly(String vocabularyFile) async {
    try {
      final studyRecordsBox = _hiveService.studyRecordsBox;
      final keysToDelete = studyRecordsBox.keys.where((key) {
        final record = studyRecordsBox.get(key);
        return record?.vocabularyFile == vocabularyFile;
      }).toList();

      for (final key in keysToDelete) {
        await studyRecordsBox.delete(key);
      }

      debugPrint(
          '어휘집 $vocabularyFile의 StudyRecord ${keysToDelete.length}개 삭제됨');
      return true;
    } catch (e) {
      debugPrint('어휘집 StudyRecord 삭제 실패: $e');
      return false;
    }
  }

  /// 모든 최근 학습 기록 삭제
  Future<bool> clearAllRecentStudyRecords() async {
    try {
      // 모든 StudyRecord 삭제 (DailyStats, WordStats 등은 유지)
      final studyRecordsBox = _hiveService.studyRecordsBox;
      await studyRecordsBox.clear();
      return true;
    } catch (e) {
      debugPrint('모든 최근 학습 기록 삭제 실패: $e');
      return false;
    }
  }

  /// 학습 세션 시작 기록 (카드 학습만)
  Future<void> recordStudySessionStart(
    String vocabularyFile,
    String studyMode,
  ) async {
    try {
      final record = StudyRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_session_start',
        wordId: 'session_start', // 세션 시작 마커
        vocabularyFile: vocabularyFile,
        studyMode: studyMode,
        isCorrect: true, // 세션 시작은 성공으로 간주
        sessionStart: DateTime.now(),
      );

      await _hiveService.addStudyRecord(record);
    } catch (e) {
      debugPrint('학습 세션 시작 기록 실패: $e');
    }
  }

  /// 즉시 학습 재개를 위한 설정 정보 (Map 형태로 반환)
  Map<String, dynamic> getResumeConfig(RecentStudyInfo recentInfo) {
    return {
      'vocabularyFiles': [recentInfo.vocabularyFile],
      'studyMode': _mapToStudyMode(recentInfo.studyMode),
      'targetMode': recentInfo.targetMode,
      'posFilters': recentInfo.posFilters,
      'typeFilters': recentInfo.typeFilters,
    };
  }

  /// 학습 모드 문자열을 StudyMode enum으로 변환
  StudyMode _mapToStudyMode(String studyMode) {
    switch (studyMode) {
      case 'card':
        return StudyMode.cardStudy;
      case 'favorites':
        return StudyMode.favoriteReview;
      case 'wrong_words':
        return StudyMode.wrongWordsStudy;
      case 'urgent_review':
        return StudyMode.urgentReview;
      case 'recommended_review':
        return StudyMode.recommendedReview;
      case 'leisure_review':
        return StudyMode.leisureReview;
      case 'forgetting_risk':
        return StudyMode.forgettingRisk;
      case 'smart_review': // 기존 데이터 호환성을 위해 유지 (긴급 복습으로 매핑)
        return StudyMode.urgentReview;
      default:
        return StudyMode.cardStudy;
    }
  }

  /// 어휘집 이름 변경 (실제로는 표시명만 변경, 파일명은 유지)
  /// 이 기능은 나중에 VocabularyService에서 구현할 수 있음
  Future<bool> updateVocabularyDisplayName(
      String vocabularyFile, String newDisplayName) async {
    try {
      // 현재는 파일명 자체를 변경하지 않고
      // 나중에 별도의 표시명 테이블을 만들 수 있음
      debugPrint('어휘집 표시명 변경: $vocabularyFile -> $newDisplayName');

      // TODO: VocabularyDisplayNames 테이블 또는 설정에 저장
      return true;
    } catch (e) {
      debugPrint('어휘집 표시명 변경 실패: $e');
      return false;
    }
  }

  /// 최근 학습 통계 조회
  Future<Map<String, dynamic>> getRecentStudyStatistics() async {
    try {
      final recentInfos = await getRecentStudyRecords(maxCount: 50);

      if (recentInfos.isEmpty) {
        return {
          'totalVocabularies': 0,
          'totalSessions': 0,
          'totalWords': 0,
          'averageAccuracy': 0.0,
          'mostActiveVocabulary': null,
          'lastStudyDate': null,
        };
      }

      final totalVocabularies = recentInfos.length;
      final totalSessions =
          recentInfos.fold<int>(0, (sum, info) => sum + info.totalSessions);
      final totalWords =
          recentInfos.fold<int>(0, (sum, info) => sum + info.totalWords);
      final averageAccuracy = recentInfos.fold<double>(
              0, (sum, info) => sum + info.averageAccuracy) /
          recentInfos.length;

      // 가장 활발히 학습한 어휘집
      final mostActiveVocabulary = recentInfos
          .reduce((a, b) => a.totalSessions > b.totalSessions ? a : b);

      return {
        'totalVocabularies': totalVocabularies,
        'totalSessions': totalSessions,
        'totalWords': totalWords,
        'averageAccuracy': averageAccuracy,
        'mostActiveVocabulary': mostActiveVocabulary.vocabularyFile,
        'lastStudyDate': recentInfos.first.lastStudyDate,
      };
    } catch (e) {
      debugPrint('최근 학습 통계 조회 실패: $e');
      return {
        'totalVocabularies': 0,
        'totalSessions': 0,
        'totalWords': 0,
        'averageAccuracy': 0.0,
        'mostActiveVocabulary': null,
        'lastStudyDate': null,
      };
    }
  }

  /// 최근 학습 기록 호버 툴팁 메시지 생성 (ui-home.mdc 스펙 준수)
  String buildRecentStudyTooltipMessage(
    RecentStudyInfo info, {
    required String currentStudyMode, // 'TargetVoca', 'ReferenceVoca', 'Random'
    required Set<String> selectedPOSFilters,
    required Set<String> selectedTypeFilters,
  }) {
    final buffer = StringBuffer();

    // 1. 어휘집 정보 (단일/복수에 따라 불렛 포인트 적용)
    final vocabularyFiles = info.vocabularyFile.split(',').map((f) => f.trim().replaceAll('.csv', '')).where((f) => f.isNotEmpty).toList();
    
    if (vocabularyFiles.length == 1) {
      buffer.writeln('${tr('tooltip.vocabulary', namespace: 'home/recent_study')}: ${vocabularyFiles.first}');
    } else {
      buffer.writeln('${tr('tooltip.vocabulary', namespace: 'home/recent_study')}:');
      for (final vocabFile in vocabularyFiles) {
        buffer.writeln('       • $vocabFile');
      }
    }

    // 2. 단어개수 (해당 학습 기록의 필터 조건에 맞는 단어 수)
    final filteredWordCount = _getFilteredWordCount(info);
    buffer.writeln('${tr('tooltip.word_count', namespace: 'home/recent_study')}: ${_formatNumber(filteredWordCount)}${tr('tooltip.unit_count', namespace: 'home/recent_study')}');

    // 3. 학습모드
    final studyModeText = _getStudyModeDisplayText(info.studyMode);
    buffer.writeln('${tr('tooltip.study_mode', namespace: 'home/recent_study')}: $studyModeText');

    // 4. 표시순서 (해당 학습 기록의 targetMode 사용)
    final targetModeText = _getTargetModeDisplayText(info.targetMode);
    buffer.writeln('${tr('tooltip.display_order', namespace: 'home/recent_study')}: $targetModeText');

    // 5. 진행도 (학습한 단어 / 필터링된 전체 단어)
    final studiedWordsCount = info.totalWords;
    if (filteredWordCount == 0) {
      buffer.writeln('${tr('tooltip.progress', namespace: 'home/recent_study')}: 0/0 (0${tr('tooltip.unit_percent', namespace: 'home/recent_study')})');
    } else {
      final progressPercent = ((studiedWordsCount / filteredWordCount) * 100).round();
      final actualProgressPercent = progressPercent > 100 ? 100 : progressPercent;
      buffer.writeln('${tr('tooltip.progress', namespace: 'home/recent_study')}: $studiedWordsCount/$filteredWordCount ($actualProgressPercent${tr('tooltip.unit_percent', namespace: 'home/recent_study')})');
    }

    // 6. 필터 정보 (해당 학습 기록의 실제 필터 사용)
    _appendFilterInfo(buffer, info);

    return buffer.toString().trim();
  }

  /// 해당 학습 기록의 필터 조건에 맞는 단어 수 계산 (학습 모드별로 정확한 단어 수)
  int _getFilteredWordCount(RecentStudyInfo info) {
    try {
      // 여러 어휘집이 쉼표로 구분되어 있는 경우 처리
      List<String> vocabularyFiles;
      if (info.vocabularyFile.contains(',')) {
        vocabularyFiles = info.vocabularyFile.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
      } else {
        vocabularyFiles = [info.vocabularyFile];
      }
      
      final filterService = FilterService.instance;
      final tempDeleteService = TemporaryDeleteService.instance;
      
      // UI 표시용 형태(예: "명사 (123개)")에서 실제 값만 추출
      List<String>? posFilters;
      List<String>? typeFilters;
      
      if (info.posFilters.isNotEmpty) {
        posFilters = info.posFilters.map((filter) => filter.split('(')[0].trim()).toList();
      }
      
      if (info.typeFilters.isNotEmpty) {
        typeFilters = info.typeFilters.map((filter) => filter.split('(')[0].trim()).toList();
      }
      
      // 학습 모드에 따라 다른 필터링 적용
      List<VocabularyWord> filteredWords;
      switch (info.studyMode) {
        case 'favorites':
          // 즐겨찾기 복습: 즐겨찾기된 단어만
          filteredWords = filterService.getFilteredWords(
            vocabularyFiles: vocabularyFiles,
            posFilters: posFilters,
            typeFilters: typeFilters,
            favoritesOnly: true,
          );
          break;
          
        case 'wrong_words':
          // 틀린단어 학습: 틀린 단어만
          return _getWrongWordsCount(vocabularyFiles, posFilters, typeFilters, info);
          
        case 'urgent_review':
        case 'recommended_review':
        case 'leisure_review':
        case 'forgetting_risk':
          // 망각곡선 기반 복습: 현재는 학습된 단어 기준으로 추정
          return _getReviewWordsCount(vocabularyFiles, posFilters, typeFilters, info.studyMode, info);
          
        case 'card':
        default:
          // 단어카드 학습: 일반 필터링된 단어
          filteredWords = filterService.getFilteredWords(
            vocabularyFiles: vocabularyFiles,
            posFilters: posFilters,
            typeFilters: typeFilters,
            favoritesOnly: false,
          );
          break;
      }
      
      // 해당 학습 기록의 세션 키 생성
      final sessionKey = TemporaryDeleteService.createSessionKey(
        vocabularyFiles: vocabularyFiles,
        studyMode: info.studyMode,
        targetMode: info.targetMode,
        posFilters: posFilters ?? [],
        typeFilters: typeFilters ?? [],
      );
      
      // 해당 세션에서 임시 삭제된 단어들을 필터링된 목록에서 제외
      final finalFilteredWords = filteredWords.where((word) => 
        !tempDeleteService.isTemporarilyDeletedInSession(word.id, sessionKey)
      ).toList();
      
      return finalFilteredWords.length;
      
    } catch (e) {
      debugPrint('필터링된 단어 수 계산 실패: $e');
      return 0;
    }
  }

  /// 학습모드 표시 텍스트 반환
  String _getStudyModeDisplayText(String studyMode) {
    switch (studyMode) {
      case 'card':
        return tr('study_modes.card', namespace: 'home/recent_study');
      case 'favorites':
        return tr('study_modes.favorites', namespace: 'home/recent_study');
      case 'wrong_words':
        return tr('study_modes.wrong_words', namespace: 'home/recent_study');
      case 'urgent_review':
        return tr('study_modes.urgent_review', namespace: 'home/recent_study');
      case 'recommended_review':
        return tr('study_modes.recommended_review', namespace: 'home/recent_study');
      case 'leisure_review':
        return tr('study_modes.leisure_review', namespace: 'home/recent_study');
      case 'forgetting_risk':
        return tr('study_modes.forgetting_risk', namespace: 'home/recent_study');
      default:
        return tr('study_modes.card', namespace: 'home/recent_study');
    }
  }

  /// 표시순서 텍스트 반환
  String _getTargetModeDisplayText(String targetMode) {
    switch (targetMode) {
      case 'TargetVoca':
        return tr('tooltip.target_mode_target', namespace: 'home/recent_study');
      case 'ReferenceVoca':
        return tr('tooltip.target_mode_reference', namespace: 'home/recent_study');
      case 'Random':
        return tr('tooltip.target_mode_random', namespace: 'home/recent_study');
      default:
        return tr('tooltip.target_mode_target', namespace: 'home/recent_study');
    }
  }

  /// 필터 정보를 버퍼에 추가 (UI 스펙에 맞게 불렛 포인트 적용)
  void _appendFilterInfo(StringBuffer buffer, RecentStudyInfo info) {
    // 기존 학습 기록 호환성: 필터 정보가 없으면 전체단어로 처리
    if (info.posFilters.isEmpty && info.typeFilters.isEmpty) {
      buffer.writeln('${tr('tooltip.selected_filters', namespace: 'home/recent_study')} ${tr('tooltip.all_filters', namespace: 'home/recent_study')}');
      return;
    }

    // 품사 필터
    if (info.posFilters.isNotEmpty) {
      if (info.posFilters.length == 1) {
        buffer.writeln('${tr('tooltip.pos_filter', namespace: 'home/recent_study')}: ${info.posFilters.first}');
      } else {
        buffer.writeln('${tr('tooltip.pos_filter', namespace: 'home/recent_study')}:');
        for (final filter in info.posFilters) {
          buffer.writeln('        • $filter');
        }
      }
    }

    // 타입 필터
    if (info.typeFilters.isNotEmpty) {
      if (info.typeFilters.length == 1) {
        buffer.writeln('${tr('tooltip.type_filter', namespace: 'home/recent_study')}: ${info.typeFilters.first}');
      } else {
        buffer.writeln('${tr('tooltip.type_filter', namespace: 'home/recent_study')}:');
        for (final filter in info.typeFilters) {
          buffer.writeln('        • $filter');
        }
      }
    }
  }

  /// 복습 대상 단어 수 계산 (임시 구현 - 학습된 단어 기준)
  int _getReviewWordsCount(List<String> vocabularyFiles, List<String>? posFilters, List<String>? typeFilters, String reviewType, RecentStudyInfo info) {
    try {
      int totalCount = 0;
      final now = DateTime.now();
      final tempDeleteService = TemporaryDeleteService.instance;
      
      // 해당 학습 기록의 세션 키 생성
      final sessionKey = TemporaryDeleteService.createSessionKey(
        vocabularyFiles: vocabularyFiles,
        studyMode: info.studyMode,
        targetMode: info.targetMode,
        posFilters: posFilters ?? [],
        typeFilters: typeFilters ?? [],
      );
      
      for (final vocabularyFile in vocabularyFiles) {
        // 해당 어휘집의 단어 통계 가져오기
        final allWordStats = _hiveService.wordStatsBox.values
            .where((stats) => stats.vocabularyFile == vocabularyFile && stats.lastStudyDate != null)
            .toList();
        
        if (allWordStats.isEmpty) continue;
        
        // 해당 어휘집의 모든 단어 가져오기
        final allWords = _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
        final wordMap = {for (var word in allWords) word.id: word};
        
        // 복습 타입별로 필터링 (임시 로직)
        Set<String> reviewWordIds = {};
        
        for (final stats in allWordStats) {
          final daysSinceLastStudy = now.difference(stats.lastStudyDate!).inDays;
          bool needsReview = false;
          
          switch (reviewType) {
            case 'urgent_review':
              // 7일 이상 지났고 정답률이 낮은 경우
              final totalAttempts = stats.correctCount + stats.wrongCount;
              final accuracy = totalAttempts > 0 ? (stats.correctCount / totalAttempts) : 0.0;
              needsReview = daysSinceLastStudy >= 7 && accuracy < 0.6;
              break;
            case 'recommended_review':
              // 3-7일 지났고 적당한 정답률인 경우
              needsReview = daysSinceLastStudy >= 3 && daysSinceLastStudy < 7;
              break;
            case 'leisure_review':
              // 1-3일 지났고 정답률이 높은 경우
              final totalAttempts2 = stats.correctCount + stats.wrongCount;
              final accuracy2 = totalAttempts2 > 0 ? (stats.correctCount / totalAttempts2) : 0.0;
              needsReview = daysSinceLastStudy >= 1 && daysSinceLastStudy < 3 && accuracy2 >= 0.8;
              break;
            case 'forgetting_risk':
              // 10일 이상 지났고 틀린 횟수가 많은 경우
              needsReview = daysSinceLastStudy >= 10 && stats.wrongCount > stats.correctCount;
              break;
          }
          
          if (needsReview) {
            reviewWordIds.add(stats.wordId);
          }
        }
        
        // 필터 조건에 맞는 복습 대상 단어만 필터링
        int filteredCount = 0;
        final tempDeleteService = TemporaryDeleteService.instance;
        
        for (final wordId in reviewWordIds) {
          final word = wordMap[wordId];
          if (word == null) continue;
          
          // 해당 세션에서 임시 삭제된 단어면 제외
          if (tempDeleteService.isTemporarilyDeletedInSession(word.id, sessionKey)) continue;
          
          // 품사 필터 체크
          bool matchesPos = true;
          if (posFilters != null && posFilters.isNotEmpty) {
            final wordPos = (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : FilterService.noPosInfo;
            matchesPos = posFilters.contains(wordPos);
          }
          
          // 타입 필터 체크
          bool matchesType = true;
          if (typeFilters != null && typeFilters.isNotEmpty) {
            final wordType = (word.type != null && word.type!.isNotEmpty) ? word.type! : FilterService.noTypeInfo;
            matchesType = typeFilters.contains(wordType);
          }
          
          if (matchesPos && matchesType) {
            filteredCount++;
          }
        }
        
        totalCount += filteredCount;
      }
      
      return totalCount;
    } catch (e) {
      debugPrint('복습 단어 수 계산 실패: $e');
      return 0;
    }
  }

  /// 틀린단어 수 계산 (품사/타입 필터 적용)
  int _getWrongWordsCount(List<String> vocabularyFiles, List<String>? posFilters, List<String>? typeFilters, RecentStudyInfo info) {
    try {
      int totalCount = 0;
      final tempDeleteService = TemporaryDeleteService.instance;
      
      // 해당 학습 기록의 세션 키 생성
      final sessionKey = TemporaryDeleteService.createSessionKey(
        vocabularyFiles: vocabularyFiles,
        studyMode: info.studyMode,
        targetMode: info.targetMode,
        posFilters: posFilters ?? [],
        typeFilters: typeFilters ?? [],
      );
      
      for (final vocabularyFile in vocabularyFiles) {
        // 해당 어휘집의 틀린단어 통계 가져오기
        final wrongWordStats = _hiveService.getWrongWords(vocabularyFile: vocabularyFile);
        final wrongWordIds = wrongWordStats.map((stats) => stats.wordId).toSet();
        
        if (wrongWordIds.isEmpty) continue;
        
        // 해당 어휘집의 모든 단어 가져오기
        final allWords = _hiveService.getVocabularyWords(vocabularyFile: vocabularyFile);
        
        // 틀린단어 중에서 필터 조건에 맞는 단어만 필터링
        int filteredCount = 0;
        for (final word in allWords) {
          // 틀린단어가 아니면 제외
          if (!wrongWordIds.contains(word.id)) continue;
          
          // 해당 세션에서 임시 삭제된 단어면 제외
          if (tempDeleteService.isTemporarilyDeletedInSession(word.id, sessionKey)) continue;
          
          // 품사 필터 체크
          bool matchesPos = true;
          if (posFilters != null && posFilters.isNotEmpty) {
            final wordPos = (word.pos != null && word.pos!.isNotEmpty) ? word.pos! : FilterService.noPosInfo;
            matchesPos = posFilters.contains(wordPos);
          }
          
          // 타입 필터 체크
          bool matchesType = true;
          if (typeFilters != null && typeFilters.isNotEmpty) {
            final wordType = (word.type != null && word.type!.isNotEmpty) ? word.type! : FilterService.noTypeInfo;
            matchesType = typeFilters.contains(wordType);
          }
          
          if (matchesPos && matchesType) {
            filteredCount++;
          }
        }
        
        totalCount += filteredCount;
      }
      
      return totalCount;
    } catch (e) {
      debugPrint('틀린단어 수 계산 실패: $e');
      return 0;
    }
  }

  /// 숫자 포매팅 (천 단위 쉼표)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  /// 최근 학습 기록에서만 해당 어휘집 제거 (어휘집 자체는 삭제하지 않음)
  Future<bool> removeFromRecentStudyOnly(String vocabularyFile) async {
    try {
      // StudyRecord에서만 해당 어휘집 기록 삭제 (VocabularyWord는 유지)
      final recordsToDelete = _hiveService.studyRecordsBox.values
          .where((record) => record.vocabularyFile == vocabularyFile)
          .map((record) => record.id)
          .toList();

      for (final id in recordsToDelete) {
        await _hiveService.studyRecordsBox.delete(id);
      }

      return true;
    } catch (e) {
      debugPrint('최근 학습 기록에서 어휘집 제거 실패: $e');
      return false;
    }
  }

  /// 학습 설정 조합으로 고유한 키 생성
  /// 어휘집 + 품사필터 + 어휘타입필터 + 위주학습설정을 조합하여 고유 키 생성
  String _createStudyConfigKey(StudyRecord record) {
    final vocabularyFile = record.vocabularyFile;
    final posKey = (record.posFilters ?? []).isEmpty 
        ? 'all' 
        : (record.posFilters ?? []).join(',');
    final typeKey = (record.typeFilters ?? []).isEmpty 
        ? 'all' 
        : (record.typeFilters ?? []).join(',');
    final targetKey = record.targetMode ?? 'TargetVoca';
    
    return '$vocabularyFile|pos:$posKey|type:$typeKey|target:$targetKey';
  }
}
