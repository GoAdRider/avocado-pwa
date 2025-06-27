import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../../common/hive_service.dart';
import '../../../models/vocabulary_word.dart';

/// 어휘집 내보내기 및 데이터 초기화를 담당하는 서비스
class VocabularyExportService {
  static VocabularyExportService? _instance;
  static VocabularyExportService get instance =>
      _instance ??= VocabularyExportService._internal();
  VocabularyExportService._internal();

  final HiveService _hiveService = HiveService.instance;

  /// 선택된 어휘집들을 CSV 파일로 내보내기
  Future<bool> exportVocabulariesToCSV(List<String> vocabularyFiles) async {
    if (vocabularyFiles.isEmpty) return false;

    try {
      // 모든 선택된 어휘집의 단어들 수집
      List<VocabularyWord> allWords = [];

      for (final fileName in vocabularyFiles) {
        final words = _hiveService.getVocabularyWords(vocabularyFile: fileName);
        allWords.addAll(words);
      }

      if (allWords.isEmpty) return false;

      // CSV 콘텐츠 생성
      final csvContent = _generateCSVContent(allWords);

      // 파일명 생성
      final timestamp = DateTime.now();
      final dateString =
          '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}'
          '_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';

      final fileName = vocabularyFiles.length == 1
          ? '${vocabularyFiles.first.replaceAll('.csv', '')}_$dateString.csv'
          : '선택된어휘집_$dateString.csv';

      // 브라우저에서 파일 다운로드
      _downloadFile(csvContent, fileName);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// CSV 콘텐츠 생성
  String _generateCSVContent(List<VocabularyWord> words) {
    final buffer = StringBuffer();

    // 헤더 작성
    buffer.writeln(
        'POS,Type,TargetVoca,TargetPronunciation,ReferenceVoca,TargetDesc,ReferenceDesc,TargetEx,ReferenceEx,Favorites');

    // 각 단어 데이터 작성
    for (final word in words) {
      // 즐겨찾기 여부 확인
      final isFavorite = _hiveService.isFavorite(word.id) ? '⭐' : '';

      // CSV 형식으로 변환 (콤마와 따옴표 처리)
      final row = [
        _csvEscape(word.pos ?? ''),
        _csvEscape(word.type ?? ''),
        _csvEscape(word.targetVoca),
        _csvEscape(word.targetPronunciation ?? ''),
        _csvEscape(word.referenceVoca),
        _csvEscape(word.targetDesc ?? ''),
        _csvEscape(word.referenceDesc ?? ''),
        _csvEscape(word.targetEx ?? ''),
        _csvEscape(word.referenceEx ?? ''),
        _csvEscape(isFavorite),
      ].join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }

  /// CSV 필드 이스케이프 처리
  String _csvEscape(String value) {
    if (value.isEmpty) return '';

    // 콤마, 따옴표, 줄바꿈이 포함된 경우 따옴표로 감싸기
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      // 내부 따옴표는 두 번 써서 이스케이프
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }

    return value;
  }

  /// 브라우저에서 파일 다운로드
  void _downloadFile(String content, String fileName) {
    try {
      // Blob 생성
      final blob = web.Blob([content.toJS].toJS,
          web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));

      // URL 생성
      final url = web.URL.createObjectURL(blob);

      // 다운로드 링크 생성 및 클릭
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';

      web.document.body!.appendChild(anchor);
      anchor.click();
      web.document.body!.removeChild(anchor);

      // URL 해제
      web.URL.revokeObjectURL(url);
    } catch (e) {
      // 다운로드 실패 시 콘솔에 로그
      web.console.error('파일 다운로드 실패: $e'.toJS);
    }
  }

  /// 선택된 어휘집들의 틀린횟수 초기화
  Future<bool> resetWrongCounts(List<String> vocabularyFiles) async {
    if (vocabularyFiles.isEmpty) return false;

    try {
      for (final fileName in vocabularyFiles) {
        // 해당 어휘집의 모든 WordStats 삭제
        await _hiveService.clearWordStats(vocabularyFile: fileName);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 선택된 어휘집들의 즐겨찾기 초기화
  Future<bool> resetFavorites(List<String> vocabularyFiles) async {
    if (vocabularyFiles.isEmpty) return false;

    try {
      for (final fileName in vocabularyFiles) {
        // 해당 어휘집의 모든 즐겨찾기 삭제
        await _hiveService.clearFavorites(vocabularyFile: fileName);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 내보내기 가능 여부 확인
  bool canExport(List<String> vocabularyFiles) {
    if (vocabularyFiles.isEmpty) return false;

    // 선택된 어휘집에 최소 하나의 단어가 있는지 확인
    for (final fileName in vocabularyFiles) {
      final words = _hiveService.getVocabularyWords(vocabularyFile: fileName);
      if (words.isNotEmpty) return true;
    }

    return false;
  }

  /// 초기화 가능 여부 확인 (틀린횟수)
  bool canResetWrongCounts(List<String> vocabularyFiles) {
    if (vocabularyFiles.isEmpty) return false;

    // 선택된 어휘집에 틀린 기록이 있는지 확인
    for (final fileName in vocabularyFiles) {
      final wrongWords = _hiveService.getWrongWords(vocabularyFile: fileName);
      if (wrongWords.isNotEmpty) return true;
    }

    return false;
  }

  /// 초기화 가능 여부 확인 (즐겨찾기)
  bool canResetFavorites(List<String> vocabularyFiles) {
    if (vocabularyFiles.isEmpty) return false;

    // 선택된 어휘집에 즐겨찾기가 있는지 확인
    for (final fileName in vocabularyFiles) {
      final favorites = _hiveService.getFavorites(vocabularyFile: fileName);
      if (favorites.isNotEmpty) return true;
    }

    return false;
  }
}
