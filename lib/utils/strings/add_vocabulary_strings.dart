class AddVocabularyStrings {
  static const Map<String, Map<String, String>> _strings = {
    'KR': {
      // 다이얼로그 제목
      'dialog_title': '새로운 어휘집 추가하기',

      // 드래그앤드롭 영역
      'drag_drop_instruction': 'CSV 파일을 여기로 드래그하세요',
      'drag_drop_active': '파일을 여기에 놓으세요',
      'csv_only_support': '.csv 파일만 지원됩니다',

      // 구분선
      'or_divider': '또는',

      // 파일 선택 버튼
      'select_file_button': '파일 선택하기',

      // 로딩 상태
      'processing_file': '파일을 처리하고 있습니다...',

      // 도움말 섹션
      'help_title': 'CSV 파일 형식 안내',
      'help_header_rule': '• 첫 번째 줄은 헤더여야 합니다',
      'help_required_columns': '• 필수 컬럼: TargetVoca, ReferenceVoca',
      'help_optional_columns':
          '• 선택 컬럼: POS, Type, TargetPronunciation, TargetDesc, ReferenceDesc, TargetEx, ReferenceEx, Favorites',
      'help_encoding': '• UTF-8 인코딩으로 저장해주세요',

      // 성공 메시지
      'success_words_added': '성공적으로 {count}개의 단어를 추가했습니다!',
      'vocab_added_success': '어휘집이 성공적으로 추가되었습니다!',

      // 오류 메시지
      'error_file_selection': '파일 선택 오류: {error}',
      'error_file_processing': '파일 처리 오류: {error}',
      'error_empty_file': '빈 파일입니다',
      'error_missing_required_columns':
          '필수 컬럼이 없습니다: TargetVoca, ReferenceVoca',
      'error_no_valid_data': '유효한 데이터가 없습니다',

      // 파일 미리보기 관련
      'preview_title': '파일 미리보기',
      'preview_title_with_count': '파일 미리보기 ({count}개)',
      'selected_files': '선택된 파일: {count}개',
      'total_words': '총 단어 수: {count}개',
      'file_list': '파일 목록: {list}',
      'data_preview': '데이터 미리보기:',
      'drag_multiple_files': '여러 CSV 파일을 여기에 드래그하세요',
      'select_files': '파일 선택',
      'help_multiple_files': '• 한 번에 여러 CSV 파일을 선택하거나 드래그할 수 있습니다.',

      // 버튼 텍스트
      'import_files_button': '{count}개 파일 가져오기',
      'importing_files': '가져오는 중...',

      // 처리 결과 메시지
      'partial_error_message':
          '일부 파일 처리 오류:\n{errors}\n\n성공: {count}개 단어 가져오기 완료',
      'success_import_message': '성공: 총 {count}개 단어를 {fileCount}개 파일에서 가져왔습니다!',
      'no_processable_files': '처리 가능한 파일이 없습니다.',
      'csv_files_only': 'CSV 파일만 업로드 가능합니다.',

      // 중복 처리 메시지
      'duplicate_vocabulary_title': '중복 어휘집 발견',
      'duplicate_vocabulary_message': '"{name}" 어휘집이 이미 존재합니다.\n어떻게 하시겠습니까?',
      'replace_vocabulary': '기존 어휘집 교체',
      'merge_vocabulary': '기존 어휘집에 병합',
      'rename_vocabulary': '새 이름으로 저장',
      'multiple_vocabularies': '{count}개 어휘집',
      'duplicate_list': '중복된 어휘집: {list}',

      // 오류 키워드 (상태 메시지 색상 판별용)
      'error_keyword': '오류',
    },
    'EN': {
      // 다이얼로그 제목
      'dialog_title': 'Add New Vocabulary',

      // 드래그앤드롭 영역
      'drag_drop_instruction': 'Drag CSV file here',
      'drag_drop_active': 'Drop file here',
      'csv_only_support': 'Only .csv files are supported',

      // 구분선
      'or_divider': 'or',

      // 파일 선택 버튼
      'select_file_button': 'Select File',

      // 로딩 상태
      'processing_file': 'Processing file...',

      // 도움말 섹션
      'help_title': 'CSV File Format Guide',
      'help_header_rule': '• First row must be header',
      'help_required_columns': '• Required columns: TargetVoca, ReferenceVoca',
      'help_optional_columns':
          '• Optional columns: POS, Type, TargetPronunciation, TargetDesc, ReferenceDesc, TargetEx, ReferenceEx, Favorites',
      'help_encoding': '• Please save in UTF-8 encoding',

      // 성공 메시지
      'success_words_added': 'Successfully added {count} words!',
      'vocab_added_success': 'Vocabulary added successfully!',

      // 오류 메시지
      'error_file_selection': 'File selection error: {error}',
      'error_file_processing': 'File processing error: {error}',
      'error_empty_file': 'Empty file',
      'error_missing_required_columns':
          'Missing required columns: TargetVoca, ReferenceVoca',
      'error_no_valid_data': 'No valid data found',

      // 파일 미리보기 관련
      'preview_title': 'File Preview',
      'preview_title_with_count': 'File Preview ({count} files)',
      'selected_files': 'Selected files: {count}',
      'total_words': 'Total words: {count}',
      'file_list': 'File list: {list}',
      'data_preview': 'Data Preview:',
      'drag_multiple_files': 'Drag multiple CSV files here',
      'select_files': 'Select Files',
      'help_multiple_files':
          '• You can select or drag multiple CSV files at once.',

      // 버튼 텍스트
      'import_files_button': 'Import {count} Files',
      'importing_files': 'Importing...',

      // 처리 결과 메시지
      'partial_error_message':
          'Some file processing errors:\n{errors}\n\nSuccess: {count} words imported',
      'success_import_message':
          'Success: {count} words imported from {fileCount} files!',
      'no_processable_files': 'No processable files.',
      'csv_files_only': 'Only CSV files can be uploaded.',

      // 중복 처리 메시지
      'duplicate_vocabulary_title': 'Duplicate Vocabulary Found',
      'duplicate_vocabulary_message':
          'Vocabulary "{name}" already exists.\nWhat would you like to do?',
      'replace_vocabulary': 'Replace Existing',
      'merge_vocabulary': 'Merge with Existing',
      'rename_vocabulary': 'Save with New Name',
      'multiple_vocabularies': '{count} vocabularies',
      'duplicate_list': 'Duplicates: {list}',

      // 오류 키워드 (상태 메시지 색상 판별용)
      'error_keyword': 'error',
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

  // 다이얼로그 제목
  static String get dialogTitle => get('dialog_title');

  // 드래그앤드롭 영역
  static String get dragDropInstruction => get('drag_drop_instruction');
  static String get dragDropActive => get('drag_drop_active');
  static String get csvOnlySupport => get('csv_only_support');

  // 구분선
  static String get orDivider => get('or_divider');

  // 파일 선택 버튼
  static String get selectFileButton => get('select_file_button');

  // 로딩 상태
  static String get processingFile => get('processing_file');

  // 도움말 섹션
  static String get helpTitle => get('help_title');
  static String get helpHeaderRule => get('help_header_rule');
  static String get helpRequiredColumns => get('help_required_columns');
  static String get helpOptionalColumns => get('help_optional_columns');
  static String get helpEncoding => get('help_encoding');

  // 성공 메시지
  static String successWordsAdded(int count) =>
      get('success_words_added', params: {'count': count});
  static String get vocabAddedSuccess => get('vocab_added_success');

  // 오류 메시지
  static String errorFileSelection(String error) =>
      get('error_file_selection', params: {'error': error});
  static String errorFileProcessing(String error) =>
      get('error_file_processing', params: {'error': error});
  static String get errorEmptyFile => get('error_empty_file');
  static String get errorMissingRequiredColumns =>
      get('error_missing_required_columns');
  static String get errorNoValidData => get('error_no_valid_data');

  // 파일 미리보기 관련
  static String get previewTitle => get('preview_title');
  static String previewTitleWithCount(int count) =>
      get('preview_title_with_count', params: {'count': count});
  static String selectedFiles(int count) =>
      get('selected_files', params: {'count': count});
  static String totalWords(int count) =>
      get('total_words', params: {'count': count});
  static String fileList(String list) =>
      get('file_list', params: {'list': list});
  static String get dataPreview => get('data_preview');
  static String get dragMultipleFiles => get('drag_multiple_files');
  static String get selectFiles => get('select_files');
  static String get helpMultipleFiles => get('help_multiple_files');

  // 버튼 텍스트
  static String importFilesButton(int count) =>
      get('import_files_button', params: {'count': count});
  static String get importingFiles => get('importing_files');

  // 처리 결과 메시지
  static String partialErrorMessage(String errors, int count) =>
      get('partial_error_message', params: {'errors': errors, 'count': count});
  static String successImportMessage(int count, int fileCount) =>
      get('success_import_message',
          params: {'count': count, 'fileCount': fileCount});
  static String get noProcessableFiles => get('no_processable_files');
  static String get csvFilesOnly => get('csv_files_only');

  // 중복 처리 관련
  static String get duplicateVocabularyTitle =>
      get('duplicate_vocabulary_title');
  static String duplicateVocabularyMessage(String name) =>
      get('duplicate_vocabulary_message', params: {'name': name});
  static String get replaceVocabulary => get('replace_vocabulary');
  static String get mergeVocabulary => get('merge_vocabulary');
  static String get renameVocabulary => get('rename_vocabulary');
  static String multipleVocabularies(int count) =>
      get('multiple_vocabularies', params: {'count': count});
  static String duplicateList(String list) =>
      get('duplicate_list', params: {'list': list});

  // 오류 키워드 (상태 메시지 색상 판별용)
  static String get errorKeyword => get('error_keyword');
}
