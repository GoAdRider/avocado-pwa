import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:async';
import '../services/hive_service.dart';
import '../services/vocabulary_import_service.dart';
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
  final VocabularyImportService _importService =
      VocabularyImportService.instance;

  bool _isDragOver = false;
  bool _isLoading = false;
  String _statusMessage = '';

  // 파일 미리보기 상태
  List<VocabularyImportResult> _importResults = [];
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
        child: _importResults.isEmpty
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
              setState(() {
                _isLoading = true;
                _statusMessage = '';
              });
              _processFiles(files);
            }
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
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _importResults.clear();
      _totalWords = 0;
    });
    _processFiles(files);
  }

  // 여러 파일을 처리하는 통합 메서드 (서비스 사용)
  void _processFiles(web.FileList files) async {
    try {
      // 웹 FileList를 List<web.File>로 변환
      List<web.File> fileList = [];
      for (int i = 0; i < files.length; i++) {
        final file = files.item(i);
        if (file != null) {
          fileList.add(file);
        }
      }

      // 서비스를 통해 파일 처리
      final results = await _importService.parseMultipleCSVFiles(fileList);

      if (results.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _setTemporaryStatusMessage(AddVocabularyStrings.csvFilesOnly,
            isError: true);
        return;
      }

      // 성공한 결과만 필터링
      final successResults = results.where((r) => r.isSuccess).toList();
      final errorResults = results.where((r) => !r.isSuccess).toList();

      if (successResults.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _setTemporaryStatusMessage(AddVocabularyStrings.noProcessableFiles,
            isError: true);
        return;
      }

      setState(() {
        _importResults = successResults;
        _totalWords =
            successResults.fold(0, (sum, result) => sum + result.wordCount);
        _isLoading = false;
      });

      // 에러가 있으면 상태 메시지로 표시
      if (errorResults.isNotEmpty) {
        _setTemporaryStatusMessage(
            AddVocabularyStrings.partialErrorMessage(
                errorResults
                    .map((r) => r.errorMessage ?? '알 수 없는 오류')
                    .join('\n'),
                _totalWords),
            isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _setTemporaryStatusMessage(
          AddVocabularyStrings.errorFileProcessing(e.toString()),
          isError: true);
    }
  }

  // 파일 미리보기 화면 (서비스 결과 사용)
  Widget _buildFilePreviewView() {
    return SizedBox(
      height: 600,
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
                    _importResults.length),
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
                      AddVocabularyStrings.selectedFiles(_importResults.length),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(AddVocabularyStrings.totalWords(_totalWords)),
                const SizedBox(height: 8),
                Text(
                  AddVocabularyStrings.fileList(
                      _importResults.map((r) => r.fileName).join(', ')),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 메인 컨텐츠 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                else if (_importResults.isNotEmpty) ...[
                  Text(
                    AddVocabularyStrings.dataPreview,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _importResults.map((result) {
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
                                  '📄 ${result.fileName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B8E23),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...result.previewData.take(3).map((data) {
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
                          _importResults.length)),
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
      _importResults.clear();
      _totalWords = 0;
      _statusMessage = '';
      _isLoading = false;
    });
  }

  // 여러 파일 가져오기 확인 (서비스 사용)
  Future<void> _confirmImport() async {
    if (_importResults.isNotEmpty) {
      // 중복 어휘집 확인
      List<String> duplicateFiles = [];
      for (final result in _importResults) {
        if (_hiveService.vocabularyFileExists(result.vocabularyFile)) {
          duplicateFiles.add(result.vocabularyFile);
        }
      }

      // 중복이 있으면 사용자에게 확인
      if (duplicateFiles.isNotEmpty) {
        final action = await _showDuplicateDialog(duplicateFiles);
        if (action == null || action == 'cancel') {
          return; // 사용자가 취소한 경우
        }
        await _processDuplicateAction(action, duplicateFiles);
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

  // 중복 처리 액션 실행 (서비스 사용)
  Future<void> _processDuplicateAction(
      String action, List<String> duplicateFiles) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 서비스에서 중복 처리
      await _importService.handleDuplicateVocabulary(
          action, duplicateFiles, _importResults);

      await _processImport(isMerge: action == 'merge');
    } catch (e) {
      setState(() {
        _statusMessage = AddVocabularyStrings.errorFileProcessing(e.toString());
        _isLoading = false;
      });
    }
  }

  // 실제 가져오기 처리 (서비스 사용)
  Future<void> _processImport({bool isMerge = false}) async {
    setState(() {
      _statusMessage = '';
    });

    try {
      int totalImported = 0;
      List<String> errorMessages = [];

      // 모든 결과의 단어들을 서비스를 통해 저장
      for (final result in _importResults) {
        try {
          final imported = await _importService.importVocabularyData(
            result.words,
            isMerge: isMerge,
          );
          totalImported += imported;
        } catch (e) {
          errorMessages.add('${result.fileName}: ${e.toString()}');
        }
      }

      setState(() {
        if (errorMessages.isNotEmpty) {
          _statusMessage = AddVocabularyStrings.partialErrorMessage(
              errorMessages.join('\n'), totalImported);
          _isLoading = false;
        } else {
          _isLoading = false;

          // 성공 시 SnackBar 표시
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
    } catch (e) {
      setState(() {
        _statusMessage = AddVocabularyStrings.errorFileProcessing(e.toString());
        _isLoading = false;
      });
    }
  }
}
