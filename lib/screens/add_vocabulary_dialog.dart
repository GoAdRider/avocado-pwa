import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:async';
import '../services/hive_service.dart';
import '../models/vocabulary_word.dart';
import '../utils/strings/add_vocabulary_strings.dart';
import '../utils/strings/base_strings.dart';

class AddVocabularyDialog extends StatefulWidget {
  const AddVocabularyDialog({super.key});

  @override
  State<AddVocabularyDialog> createState() => _AddVocabularyDialogState();
}

class _AddVocabularyDialogState extends State<AddVocabularyDialog> {
  final HiveService _hiveService = HiveService.instance;
  bool _isDragOver = false;
  bool _isLoading = false;
  String _statusMessage = '';

  // 파일 미리보기 상태 (여러 파일 지원)
  final List<String> _selectedFileNames = [];
  final List<String> _selectedFileContents = [];
  final List<List<Map<String, String>>> _previewDataList = [];
  int _totalWords = 0;
  Timer? _statusMessageTimer;

  @override
  void initState() {
    super.initState();
    _setupDragAndDrop();
  }

  @override
  void dispose() {
    _statusMessageTimer?.cancel();
    super.dispose();
  }

  // 상태 메시지를 설정하고 자동으로 사라지게 하는 헬퍼 메서드
  void _setTemporaryStatusMessage(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
    });

    // 기존 타이머 취소
    _statusMessageTimer?.cancel();

    // 에러 메시지인 경우에만 자동으로 사라지게 함
    if (isError) {
      _statusMessageTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });
    }
  }

  void _setupDragAndDrop() {
    // 웹 드래그앤드롭 이벤트 설정
    try {
      final window = web.window;

      // 전체 창에서 드래그오버 이벤트 방지 (파일이 브라우저에서 열리는 것 방지)
      window.addEventListener(
          'dragover',
          (web.Event e) {
            e.preventDefault();
          }.toJS);

      window.addEventListener(
          'drop',
          (web.Event e) {
            e.preventDefault();
          }.toJS);
    } catch (e) {
      print('드래그앤드롭 설정 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: _selectedFileNames.isEmpty
            ? _buildFileSelectionView()
            : _buildFilePreviewView(),
      ),
    );
  }

  Widget _buildFileSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 제목
        Row(
          children: [
            const Icon(Icons.add_circle_outline,
                color: Color(0xFF6B8E23), size: 28),
            const SizedBox(width: 12),
            Text(
              AddVocabularyStrings.dialogTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B8E23),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 드래그앤드롭 영역
        _buildDropZone(),

        const SizedBox(height: 16),

        // 또는 구분선
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AddVocabularyStrings.orDivider,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        // 파일 선택 버튼
        _buildFilePickerButton(),

        const SizedBox(height: 24),

        // 상태 메시지
        if (_statusMessage.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusMessage.contains(AddVocabularyStrings.errorKeyword)
                  ? Colors.red[50]
                  : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _statusMessage.contains(AddVocabularyStrings.errorKeyword)
                        ? Colors.red[200]!
                        : Colors.green[200]!,
              ),
            ),
            child: Text(
              _statusMessage,
              style: TextStyle(
                color:
                    _statusMessage.contains(AddVocabularyStrings.errorKeyword)
                        ? Colors.red[700]
                        : Colors.green[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 도움말 (상태 메시지가 있을 때는 숨김)
        if (_statusMessage.isEmpty) _buildHelpSection(),

        // 로딩 인디케이터
        if (_isLoading) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(AddVocabularyStrings.processingFile),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDropZone() {
    return MouseRegion(
      child: Listener(
        onPointerDown: (details) {},
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? const Color(0xFF6B8E23) : Colors.grey[300]!,
              width: _isDragOver ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _isDragOver
                ? const Color(0xFF6B8E23).withValues(alpha: 0.2)
                : Colors.grey[50],
            boxShadow: _isDragOver
                ? [
                    BoxShadow(
                      color: const Color(0xFF6B8E23).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: _buildDropZoneContentWithEvents(),
        ),
      ),
    );
  }

  Widget _buildDropZoneContentWithEvents() {
    return Builder(
      builder: (context) {
        // HTML 요소에 직접 드래그앤드롭 이벤트 연결
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setupDropZoneEvents(context);
        });

        return _buildDropZoneContent();
      },
    );
  }

  void _setupDropZoneEvents(BuildContext context) {
    try {
      // 전체 다이얼로그 영역에 드래그앤드롭 이벤트 추가
      final body = web.document.body;

      if (body != null) {
        // 드래그 진입
        body.addEventListener(
            'dragenter',
            (web.Event e) {
              e.preventDefault();
              e.stopPropagation();

              final dragEvent = e as web.DragEvent;
              final types = dragEvent.dataTransfer?.types;
              if (types != null && types.length > 0) {
                setState(() {
                  _isDragOver = true;
                });
              }
            }.toJS);

        // 드래그 오버 (계속 드래그 중)
        body.addEventListener(
            'dragover',
            (web.Event e) {
              e.preventDefault();
              e.stopPropagation();

              final dragEvent = e as web.DragEvent;
              final types = dragEvent.dataTransfer?.types;
              if (types != null && types.length > 0) {
                dragEvent.dataTransfer?.dropEffect = 'copy';
                if (!_isDragOver) {
                  setState(() {
                    _isDragOver = true;
                  });
                }
              }
            }.toJS);

        // 드래그 탈출 (더 정확한 감지)
        body.addEventListener(
            'dragleave',
            (web.Event e) {
              e.preventDefault();
              e.stopPropagation();

              // 창 경계를 벗어날 때만 상태 변경
              final mouseEvent = e as web.MouseEvent;
              if (mouseEvent.clientX <= 0 ||
                  mouseEvent.clientY <= 0 ||
                  mouseEvent.clientX >= web.window.innerWidth ||
                  mouseEvent.clientY >= web.window.innerHeight) {
                setState(() {
                  _isDragOver = false;
                });
              }
            }.toJS);

        // 파일 드롭
        body.addEventListener(
            'drop',
            (web.Event e) {
              e.preventDefault();
              e.stopPropagation();

              setState(() {
                _isDragOver = false;
              });

              final dataTransfer = (e as web.DragEvent).dataTransfer;
              if (dataTransfer != null && dataTransfer.files.length > 0) {
                _handleDroppedFiles(dataTransfer.files);
              }
            }.toJS);
      }
    } catch (e) {
      print('드래그앤드롭 이벤트 설정 실패: $e');
    }
  }

  Widget _buildDropZoneContent() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: _isDragOver ? const Color(0xFF6B8E23) : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _isDragOver
                ? AddVocabularyStrings.dragDropActive
                : AddVocabularyStrings.dragMultipleFiles,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _isDragOver ? const Color(0xFF6B8E23) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AddVocabularyStrings.csvOnlySupport,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _pickFile,
        icon: const Icon(Icons.folder_open),
        label: Text(AddVocabularyStrings.selectFiles),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B8E23),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                AddVocabularyStrings.helpTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${AddVocabularyStrings.helpHeaderRule}\n'
            '${AddVocabularyStrings.helpRequiredColumns}\n'
            '${AddVocabularyStrings.helpOptionalColumns}\n'
            '${AddVocabularyStrings.helpEncoding}\n'
            '${AddVocabularyStrings.helpMultipleFiles}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      // 웹에서 파일 선택 (package:web 방식) - 여러 파일 선택 지원
      final uploadInput = web.HTMLInputElement()
        ..type = 'file'
        ..accept = '.csv'
        ..multiple = true; // 여러 파일 선택 허용

      uploadInput.click();

      uploadInput.addEventListener(
          'change',
          (web.Event event) {
            final files = uploadInput.files;
            if (files != null && files.length > 0) {
              // 파일이 선택된 경우에만 로딩 시작
              setState(() {
                _isLoading = true;
                _statusMessage = '';
              });
              _handleSelectedFiles(files);
            }
            // 파일이 선택되지 않은 경우 (취소된 경우)는 아무것도 하지 않음
          }.toJS);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _setTemporaryStatusMessage(
          AddVocabularyStrings.errorFileSelection(e.toString()),
          isError: true);
    }
  }

  // 드래그앤드롭으로 여러 파일 처리
  void _handleDroppedFiles(web.FileList files) {
    _processFiles(files);
  }

  // 파일 선택으로 여러 파일 처리
  void _handleSelectedFiles(web.FileList files) {
    _processFiles(files);
  }

  // 여러 파일을 처리하는 통합 메서드
  void _processFiles(web.FileList files) {
    List<web.File> csvFiles = [];

    // CSV 파일만 필터링
    for (int i = 0; i < files.length; i++) {
      final file = files.item(i);
      if (file != null && file.name.toLowerCase().endsWith('.csv')) {
        csvFiles.add(file);
      }
    }

    if (csvFiles.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _setTemporaryStatusMessage(AddVocabularyStrings.csvFilesOnly,
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _selectedFileNames.clear();
      _selectedFileContents.clear();
      _previewDataList.clear();
      _totalWords = 0;
    });

    // 각 파일을 비동기로 처리
    int processedCount = 0;
    List<String> errorMessages = [];

    for (final file in csvFiles) {
      final reader = web.FileReader();

      reader.addEventListener(
          'loadend',
          (web.Event e) {
            try {
              final result = reader.result;
              if (result != null) {
                final content = result.toString();
                _processFileForPreview(content, file.name);
              }
            } catch (e) {
              errorMessages.add('${file.name}: ${e.toString()}');
            }

            processedCount++;

            // 모든 파일 처리 완료
            if (processedCount == csvFiles.length) {
              setState(() {
                _isLoading = false;
              });

              if (errorMessages.isNotEmpty) {
                _setTemporaryStatusMessage(
                    AddVocabularyStrings.partialErrorMessage(
                        errorMessages.join('\n'), 0),
                    isError: true);
              } else if (_selectedFileNames.isEmpty) {
                _setTemporaryStatusMessage(
                    AddVocabularyStrings.noProcessableFiles,
                    isError: true);
              }
            }
          }.toJS);

      reader.readAsText(file);
    }
  }

  // 개별 파일을 미리보기용으로 처리
  void _processFileForPreview(String content, String fileName) {
    try {
      // CSV 파싱해서 미리보기 데이터 생성
      List<String> lines = content.split('\n');
      if (lines.isEmpty) {
        throw Exception('파일이 비어있습니다.');
      }

      // 헤더 파싱
      List<String> headers =
          lines[0].split(',').map((h) => h.trim().replaceAll('"', '')).toList();

      // 필수 컬럼 확인
      if (!headers.contains('TargetVoca') ||
          !headers.contains('ReferenceVoca')) {
        throw Exception('필수 컬럼(TargetVoca, ReferenceVoca)이 없습니다.');
      }

      // 데이터 미리보기 생성 (최대 3개 라인 - 여러 파일이므로 줄임)
      List<Map<String, String>> previewData = [];
      int previewCount = 0;
      int validWordCount = 0;

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        List<String> values = _parseCSVLine(line);
        if (values.length < 2) continue;

        Map<String, String> rowData = {};
        for (int j = 0; j < headers.length && j < values.length; j++) {
          rowData[headers[j]] = values[j];
        }

        if (rowData['TargetVoca']?.isNotEmpty == true &&
            rowData['ReferenceVoca']?.isNotEmpty == true) {
          validWordCount++;
          if (previewCount < 3) {
            // 여러 파일이므로 각 파일당 3개만
            previewData.add(rowData);
            previewCount++;
          }
        }
      }

      if (validWordCount > 0) {
        setState(() {
          _selectedFileNames.add(fileName);
          _selectedFileContents.add(content);
          _previewDataList.add(previewData);
          _totalWords += validWordCount;
        });
      }
    } catch (e) {
      throw Exception('$fileName: ${e.toString()}');
    }
  }

  // 파일 미리보기 화면 (여러 파일 지원)
  Widget _buildFilePreviewView() {
    return SizedBox(
      height: 600, // 고정 높이로 다이얼로그 크기 변화 방지
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              const Icon(Icons.preview_outlined,
                  color: Color(0xFF6B8E23), size: 28),
              const SizedBox(width: 12),
              Text(
                AddVocabularyStrings.previewTitleWithCount(
                    _selectedFileNames.length),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8E23),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _cancelPreview,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 전체 파일 정보 요약
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_copy,
                        color: Color(0xFF6B8E23), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AddVocabularyStrings.selectedFiles(
                          _selectedFileNames.length),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(AddVocabularyStrings.totalWords(_totalWords)),
                const SizedBox(height: 8),
                Text(
                  AddVocabularyStrings.fileList(_selectedFileNames.join(', ')),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 메인 컨텐츠 영역 (고정 높이)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상태 메시지가 있으면 표시, 없으면 데이터 미리보기 표시
                if (_statusMessage.isNotEmpty)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _statusMessage
                                .contains(AddVocabularyStrings.errorKeyword)
                            ? Colors.red[50]
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _statusMessage
                                  .contains(AddVocabularyStrings.errorKeyword)
                              ? Colors.red[200]!
                              : Colors.green[200]!,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage
                                    .contains(AddVocabularyStrings.errorKeyword)
                                ? Colors.red[700]
                                : Colors.green[700],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_previewDataList.isNotEmpty) ...[
                  Text(
                    AddVocabularyStrings.dataPreview,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            _selectedFileNames.asMap().entries.map((entry) {
                          final index = entry.key;
                          final fileName = entry.value;
                          final previewData = _previewDataList[index];

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📄 $fileName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B8E23),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...previewData.take(3).map((data) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${data['TargetVoca'] ?? ''} → ${data['ReferenceVoca'] ?? ''}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        if (data['POS']?.isNotEmpty == true ||
                                            data['Type']?.isNotEmpty == true)
                                          Text(
                                            '${data['POS'] ?? ''} ${data['Type'] ?? ''}'
                                                .trim(),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600]),
                                          ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(BaseStrings.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmImport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E23),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text(AddVocabularyStrings.importingFiles),
                          ],
                        )
                      : Text(AddVocabularyStrings.importFilesButton(
                          _selectedFileNames.length)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 미리보기 취소
  void _cancelPreview() {
    setState(() {
      _selectedFileNames.clear();
      _selectedFileContents.clear();
      _previewDataList.clear();
      _totalWords = 0;
      _statusMessage = '';
      _isLoading = false;
    });
  }

  // 여러 파일 가져오기 확인
  Future<void> _confirmImport() async {
    if (_selectedFileContents.isNotEmpty && _selectedFileNames.isNotEmpty) {
      // 중복 어휘집 확인
      List<String> duplicateFiles = [];
      for (final fileName in _selectedFileNames) {
        final vocabularyFile = fileName.replaceAll('.csv', '');
        if (_hiveService.vocabularyFileExists(vocabularyFile)) {
          duplicateFiles.add(vocabularyFile);
        }
      }

      // 중복이 있으면 사용자에게 확인
      if (duplicateFiles.isNotEmpty) {
        final result = await _showDuplicateDialog(duplicateFiles);
        if (result == null || result == 'cancel') {
          return; // 사용자가 취소한 경우
        }
        await _processDuplicateAction(result, duplicateFiles);
      } else {
        await _processImport();
      }
    }
  }

  // 중복 어휘집 처리 다이얼로그
  Future<String?> _showDuplicateDialog(List<String> duplicateFiles) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AddVocabularyStrings.duplicateVocabularyTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AddVocabularyStrings.duplicateVocabularyMessage(
                  duplicateFiles.length == 1
                      ? duplicateFiles.first
                      : AddVocabularyStrings.multipleVocabularies(
                          duplicateFiles.length))),
              if (duplicateFiles.length > 1) ...[
                const SizedBox(height: 8),
                Text(
                    AddVocabularyStrings.duplicateList(
                        duplicateFiles.join(', ')),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text(BaseStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('replace'),
              child: Text(AddVocabularyStrings.replaceVocabulary),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('merge'),
              child: Text(AddVocabularyStrings.mergeVocabulary),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('rename'),
              child: Text(AddVocabularyStrings.renameVocabulary),
            ),
          ],
        );
      },
    );
  }

  // 중복 처리 액션 실행
  Future<void> _processDuplicateAction(
      String action, List<String> duplicateFiles) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (action == 'replace') {
        // 기존 어휘집 삭제 후 새로 추가
        for (final vocabularyFile in duplicateFiles) {
          await _hiveService.clearVocabularyData(vocabularyFile);
        }
        await _processImport();
      } else if (action == 'merge') {
        // 기존 어휘집에 병합 (중복 ID 처리)
        await _processImport(isMerge: true);
      } else if (action == 'rename') {
        // 새로운 이름으로 저장
        await _processImport(addTimestamp: true);
      }
    } catch (e) {
      setState(() {
        _statusMessage = AddVocabularyStrings.errorFileProcessing(e.toString());
        _isLoading = false;
      });
    }
  }

  // 실제 가져오기 처리
  Future<void> _processImport(
      {bool isMerge = false, bool addTimestamp = false}) async {
    setState(() {
      _statusMessage = '';
    });

    int totalImported = 0;
    List<String> errorMessages = [];

    // 모든 파일을 순차적으로 처리
    for (int i = 0; i < _selectedFileContents.length; i++) {
      try {
        final content = _selectedFileContents[i];
        String fileName = _selectedFileNames[i];

        // 타임스탬프 추가하는 경우
        if (addTimestamp) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          fileName = fileName.replaceAll('.csv', '_$timestamp.csv');
        }

        final imported =
            await _processFileContent(content, fileName, isMerge: isMerge);
        totalImported += imported;
      } catch (e) {
        errorMessages.add('${_selectedFileNames[i]}: ${e.toString()}');
      }
    }

    setState(() {
      if (errorMessages.isNotEmpty) {
        _statusMessage = AddVocabularyStrings.partialErrorMessage(
            errorMessages.join('\n'), totalImported);
        _isLoading = false;
      } else {
        // 성공한 경우 다이얼로그에서 직접 SnackBar 호출 (테스트)
        _isLoading = false;

        // 다이얼로그에서 SnackBar 호출
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AddVocabularyStrings.vocabAddedSuccess),
            backgroundColor: const Color(0xFF6B8E23),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop(true);
      }
    });

    // 에러가 있는 경우만 2초 후 다이얼로그 닫기
    if (errorMessages.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  Future<int> _processFileContent(String content, String fileName,
      {bool isMerge = false}) async {
    // CSV 파싱 (매우 간단한 버전)
    List<String> lines = content.split('\n');
    if (lines.isEmpty) {
      throw Exception(AddVocabularyStrings.errorEmptyFile);
    }

    // 헤더 파싱
    List<String> headers =
        lines[0].split(',').map((h) => h.trim().replaceAll('"', '')).toList();

    // 필수 컬럼 확인
    if (!headers.contains('TargetVoca') || !headers.contains('ReferenceVoca')) {
      throw Exception(AddVocabularyStrings.errorMissingRequiredColumns);
    }

    // 데이터 파싱 및 저장
    List<VocabularyWord> words = [];
    String vocabularyFile = fileName.replaceAll('.csv', '');

    for (int i = 1; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;

      // 간단한 CSV 파싱 (따옴표 처리 포함)
      List<String> values = _parseCSVLine(line);
      if (values.length < 2) continue; // 최소한 TargetVoca, ReferenceVoca는 있어야 함

      Map<String, String> rowData = {};
      for (int j = 0; j < headers.length && j < values.length; j++) {
        rowData[headers[j]] = values[j];
      }

      // 필수 필드 확인
      if (rowData['TargetVoca']?.isEmpty != false ||
          rowData['ReferenceVoca']?.isEmpty != false) {
        continue;
      }

      // 병합 모드에서는 기존 ID와 충돌하지 않도록 타임스탬프 추가
      final wordId = isMerge
          ? '${vocabularyFile}_${DateTime.now().millisecondsSinceEpoch}_${i}_merge'
          : '${vocabularyFile}_${DateTime.now().millisecondsSinceEpoch}_$i';

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
    }

    if (words.isEmpty) {
      throw Exception(AddVocabularyStrings.errorNoValidData);
    }

    // Hive에 저장
    for (VocabularyWord word in words) {
      await _hiveService.addVocabularyWord(word);
    }

    return words.length;
  }

  // 간단한 CSV 라인 파싱 (따옴표 처리)
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
