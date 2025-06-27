import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:async';
import '../../models/vocabulary_word.dart';
import '../../utils/strings/add_vocabulary_strings.dart';
import 'hive_service.dart';

/// CSV 파일 처리 및 어휘 가져오기를 담당하는 서비스
class VocabularyImportService {
  static VocabularyImportService? _instance;
  static VocabularyImportService get instance =>
      _instance ??= VocabularyImportService._internal();
  VocabularyImportService._internal();

  final HiveService _hiveService = HiveService.instance;

  /// CSV 파일 콘텐츠에서 어휘 데이터 추출 및 검증
  Future<VocabularyImportResult> parseCSVContent(
      String content, String fileName) async {
    try {
      // CSV 파싱
      List<String> lines = content.split('\n');
      if (lines.isEmpty) {
        throw VocabularyImportException(AddVocabularyStrings.errorEmptyFile);
      }

      // 헤더 파싱
      List<String> headers =
          lines[0].split(',').map((h) => h.trim().replaceAll('"', '')).toList();

      // 필수 컬럼 확인
      if (!headers.contains('TargetVoca') ||
          !headers.contains('ReferenceVoca')) {
        throw VocabularyImportException(
            AddVocabularyStrings.errorMissingRequiredColumns);
      }

      // 데이터 파싱
      List<VocabularyWord> words = [];
      List<Map<String, String>> previewData = [];
      String vocabularyFile = fileName.replaceAll('.csv', '');

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        List<String> values = _parseCSVLine(line);
        if (values.length < 2) continue;

        Map<String, String> rowData = {};
        for (int j = 0; j < headers.length && j < values.length; j++) {
          rowData[headers[j]] = values[j];
        }

        // 필수 필드 확인
        if (rowData['TargetVoca']?.isEmpty != false ||
            rowData['ReferenceVoca']?.isEmpty != false) {
          continue;
        }

        // VocabularyWord 객체 생성
        final wordId =
            '${vocabularyFile}_${DateTime.now().millisecondsSinceEpoch}_$i';

        VocabularyWord word = VocabularyWord(
          id: wordId,
          vocabularyFile: vocabularyFile,
          pos: rowData['POS']?.isEmpty == true ? null : rowData['POS'],
          type: rowData['Type']?.isEmpty == true ? null : rowData['Type'],
          targetVoca: rowData['TargetVoca']!,
          targetPronunciation: rowData['TargetPronunciation']?.isEmpty == true
              ? null
              : rowData['TargetPronunciation'],
          referenceVoca: rowData['ReferenceVoca']!,
          targetDesc: rowData['TargetDesc']?.isEmpty == true
              ? null
              : rowData['TargetDesc'],
          referenceDesc: rowData['ReferenceDesc']?.isEmpty == true
              ? null
              : rowData['ReferenceDesc'],
          targetEx:
              rowData['TargetEx']?.isEmpty == true ? null : rowData['TargetEx'],
          referenceEx: rowData['ReferenceEx']?.isEmpty == true
              ? null
              : rowData['ReferenceEx'],
          importedDate: DateTime.now(),
        );

        words.add(word);

        // 미리보기용 데이터 (최대 3개)
        if (previewData.length < 3) {
          previewData.add(rowData);
        }
      }

      if (words.isEmpty) {
        throw VocabularyImportException(AddVocabularyStrings.errorNoValidData);
      }

      return VocabularyImportResult(
        fileName: fileName,
        vocabularyFile: vocabularyFile,
        words: words,
        previewData: previewData,
        isSuccess: true,
      );
    } catch (e) {
      if (e is VocabularyImportException) {
        rethrow;
      }
      throw VocabularyImportException('$fileName: ${e.toString()}');
    }
  }

  /// 여러 CSV 파일을 일괄 처리
  Future<List<VocabularyImportResult>> parseMultipleCSVFiles(
      List<web.File> files) async {
    List<VocabularyImportResult> results = [];

    for (final file in files) {
      if (!file.name.toLowerCase().endsWith('.csv')) {
        continue; // CSV 파일이 아니면 건너뛰기
      }

      try {
        // 파일 읽기
        final content = await _readFileContent(file);
        final result = await parseCSVContent(content, file.name);
        results.add(result);
      } catch (e) {
        results.add(VocabularyImportResult(
          fileName: file.name,
          vocabularyFile: file.name.replaceAll('.csv', ''),
          words: [],
          previewData: [],
          isSuccess: false,
          errorMessage: e.toString(),
        ));
      }
    }

    return results;
  }

  /// 어휘 데이터를 Hive에 저장
  Future<int> importVocabularyData(
    List<VocabularyWord> words, {
    bool isMerge = false,
  }) async {
    int importedCount = 0;

    for (VocabularyWord word in words) {
      // 병합 모드에서는 기존 ID와 충돌 방지
      if (isMerge) {
        word = VocabularyWord(
          id: '${word.id}_merge_${DateTime.now().millisecondsSinceEpoch}',
          vocabularyFile: word.vocabularyFile,
          pos: word.pos,
          type: word.type,
          targetVoca: word.targetVoca,
          targetPronunciation: word.targetPronunciation,
          referenceVoca: word.referenceVoca,
          targetDesc: word.targetDesc,
          referenceDesc: word.referenceDesc,
          targetEx: word.targetEx,
          referenceEx: word.referenceEx,
          importedDate: word.importedDate,
        );
      }

      await _hiveService.addVocabularyWord(word);
      importedCount++;
    }

    return importedCount;
  }

  /// 중복 어휘집 처리
  Future<void> handleDuplicateVocabulary(
    String action,
    List<String> duplicateFiles,
    List<VocabularyImportResult> results,
  ) async {
    if (action == 'replace') {
      // 기존 어휘집 삭제
      for (final vocabularyFile in duplicateFiles) {
        await _hiveService.clearVocabularyData(vocabularyFile);
      }
    } else if (action == 'rename') {
      // 타임스탬프 추가하여 새로운 이름으로 변경
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      for (final result in results) {
        if (duplicateFiles.contains(result.vocabularyFile)) {
          final newVocabularyFile = '${result.vocabularyFile}_$timestamp';
          for (final word in result.words) {
            word.vocabularyFile = newVocabularyFile;
          }
        }
      }
    }
    // 'merge' 액션은 importVocabularyData에서 isMerge=true로 처리
  }

  /// 파일 내용 읽기 (웹용)
  Future<String> _readFileContent(web.File file) async {
    final reader = web.FileReader();
    final completer = Completer<String>();

    reader.addEventListener(
        'loadend',
        (web.Event e) {
          final result = reader.result;
          if (result != null) {
            completer.complete(result.toString());
          } else {
            completer.completeError('파일 읽기 실패');
          }
        }.toJS);

    reader.addEventListener(
        'error',
        (web.Event e) {
          completer.completeError('파일 읽기 오류');
        }.toJS);

    reader.readAsText(file);
    return completer.future;
  }

  /// CSV 라인 파싱 (따옴표 처리)
  List<String> _parseCSVLine(String line) {
    List<String> result = [];
    bool inQuotes = false;
    String currentField = '';

    for (int i = 0; i < line.length; i++) {
      String char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.trim());
        currentField = '';
      } else {
        currentField += char;
      }
    }

    result.add(currentField.trim());
    return result;
  }
}

/// 어휘 가져오기 결과 데이터 클래스
class VocabularyImportResult {
  final String fileName;
  final String vocabularyFile;
  final List<VocabularyWord> words;
  final List<Map<String, String>> previewData;
  final bool isSuccess;
  final String? errorMessage;

  VocabularyImportResult({
    required this.fileName,
    required this.vocabularyFile,
    required this.words,
    required this.previewData,
    required this.isSuccess,
    this.errorMessage,
  });

  int get wordCount => words.length;
  bool get hasError => !isSuccess || errorMessage != null;
}

/// 어휘 가져오기 예외 클래스
class VocabularyImportException implements Exception {
  final String message;
  VocabularyImportException(this.message);

  @override
  String toString() => message;
}
