import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:async';
import '../../services/common/hive_service.dart';
import '../../services/common/vocabulary_import_service.dart';
import '../../utils/i18n/simple_i18n.dart';

class AddVocabularyDialog extends StatefulWidget {
  const AddVocabularyDialog({super.key});

  @override
  State<AddVocabularyDialog> createState() => _AddVocabularyDialogState();
}

class _AddVocabularyDialogState extends State<AddVocabularyDialog> {
  final HiveService _hiveService = HiveService.instance;
  final VocabularyImportService _importService =
      VocabularyImportService.instance;

  // UI 상태 관리
  bool _isDragOver = false;
  bool _isLoading = false;
  String _statusMessage = '';
  List<VocabularyImportResult> _importResults = [];
  int _totalWords = 0;
  Timer? _statusMessageTimer;

  @override
  void initState() {
    print('🔧 DEBUG: AddVocabularyDialog initState 호출됨');
    super.initState();
    
    // 임시로 드래그앤드롭 비활성화 (디버깅용)
    try {
      _setupDragAndDrop();
    } catch (e) {
      print('⚠️ WARNING: 드래그앤드롭 설정 실패, 계속 진행: $e');
    }
    
    print('🔧 DEBUG: AddVocabularyDialog initState 완료');
  }

  @override
  void dispose() {
    _statusMessageTimer?.cancel();
    super.dispose();
  }

  // ===== UI 헬퍼 메서드들 =====

  /// 상태 메시지를 설정하고 자동으로 사라지게 하는 헬퍼 메서드
  void _setTemporaryStatusMessage(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
    });

    _statusMessageTimer?.cancel();

    if (isError) {
      _statusMessageTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });
    }
  }

  /// 로딩 상태 변경
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  /// 성공 메시지 표시 후 다이얼로그 닫기
  void _showSuccessAndClose(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B8E23),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop(true);
  }

  // ===== 드래그앤드롭 이벤트 처리 =====

  void _setupDragAndDrop() {
    print('🔧 DEBUG: _setupDragAndDrop 시작');
    try {
      final window = web.window;
      print('🔧 DEBUG: web.window 접근 성공');

      // 전체 창에서 기본 드래그 동작 방지
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
      print('🔧 DEBUG: 드래그앤드롭 이벤트 리스너 설정 완료');
    } catch (e, stackTrace) {
      print('❌ ERROR: 드래그앤드롭 설정 오류: $e');
      print('❌ StackTrace: $stackTrace');
    }
  }

  void _setupDropZoneEvents(BuildContext context) {
    try {
      final body = web.document.body;
      if (body == null) return;

      // 드래그 진입
      body.addEventListener(
          'dragenter',
          (web.Event e) {
            e.preventDefault();
            e.stopPropagation();

            final dragEvent = e as web.DragEvent;
            if ((dragEvent.dataTransfer?.types.length ?? 0) > 0) {
              setState(() => _isDragOver = true);
            }
          }.toJS);

      // 드래그 오버
      body.addEventListener(
          'dragover',
          (web.Event e) {
            e.preventDefault();
            e.stopPropagation();

            final dragEvent = e as web.DragEvent;
            if ((dragEvent.dataTransfer?.types.length ?? 0) > 0) {
              dragEvent.dataTransfer?.dropEffect = 'copy';
              if (!_isDragOver) {
                setState(() => _isDragOver = true);
              }
            }
          }.toJS);

      // 드래그 탈출
      body.addEventListener(
          'dragleave',
          (web.Event e) {
            e.preventDefault();
            e.stopPropagation();

            final mouseEvent = e as web.MouseEvent;
            if (mouseEvent.clientX <= 0 ||
                mouseEvent.clientY <= 0 ||
                mouseEvent.clientX >= web.window.innerWidth ||
                mouseEvent.clientY >= web.window.innerHeight) {
              setState(() => _isDragOver = false);
            }
          }.toJS);

      // 파일 드롭
      body.addEventListener(
          'drop',
          (web.Event e) {
            e.preventDefault();
            e.stopPropagation();

            setState(() => _isDragOver = false);

            final dataTransfer = (e as web.DragEvent).dataTransfer;
            if (dataTransfer != null && dataTransfer.files.length > 0) {
              _handleFileSelection(dataTransfer.files);
            }
          }.toJS);
    } catch (e) {
      debugPrint('드래그앤드롭 이벤트 설정 실패: $e');
    }
  }

  // ===== 파일 처리 메서드들 =====

  /// 파일 선택 버튼 클릭 처리
  Future<void> _pickFiles() async {
    try {
      final uploadInput = web.HTMLInputElement()
        ..type = 'file'
        ..accept = '.csv'
        ..multiple = true;

      uploadInput.click();

      uploadInput.addEventListener(
          'change',
          (web.Event event) {
            final files = uploadInput.files;
            if (files != null && files.length > 0) {
              _handleFileSelection(files);
            }
          }.toJS);
    } catch (e) {
      _setTemporaryStatusMessage(
          tr('errors.file_selection', namespace: 'dialogs/vocabulary_import', params: {'error': e.toString()}),
          isError: true);
    }
  }

  /// 파일 선택 통합 처리 (드롭 & 클릭)
  void _handleFileSelection(web.FileList files) async {
    _setLoading(true);
    setState(() {
      _statusMessage = '';
      _importResults.clear();
      _totalWords = 0;
    });

    try {
      // WebFileList를 List<web.File>로 변환
      final fileList = <web.File>[];
      for (int i = 0; i < files.length; i++) {
        final file = files.item(i);
        if (file != null) fileList.add(file);
      }

      // 서비스를 통해 파일 파싱
      final results = await _importService.parseMultipleCSVFiles(fileList);

      if (results.isEmpty) {
        _setLoading(false);
        _setTemporaryStatusMessage(tr('errors.csv_files_only', namespace: 'dialogs/vocabulary_import'),
            isError: true);
        return;
      }

      final successResults = results.where((r) => r.isSuccess).toList();
      final errorResults = results.where((r) => !r.isSuccess).toList();

      if (successResults.isEmpty) {
        _setLoading(false);
        _setTemporaryStatusMessage(tr('errors.no_processable_files', namespace: 'dialogs/vocabulary_import'),
            isError: true);
        return;
      }

      // 상태 업데이트
      setState(() {
        _importResults = successResults;
        _totalWords =
            successResults.fold(0, (sum, result) => sum + result.wordCount);
      });
      _setLoading(false);

      // 부분 오류 알림
      if (errorResults.isNotEmpty) {
        final errorMessage =
            errorResults.map((r) => _cleanErrorMessage(r.errorMessage ?? '알 수 없는 오류')).join('\n');
        _setTemporaryStatusMessage(
            tr('errors.partial_error_message', namespace: 'dialogs/vocabulary_import', params: {'errors': errorMessage, 'successCount': _totalWords}),
            isError: true);
      }
    } catch (e) {
      _setLoading(false);
      _setTemporaryStatusMessage(
          tr('errors.file_processing', namespace: 'dialogs/vocabulary_import', params: {'error': e.toString()}),
          isError: true);
    }
  }

  // ===== 가져오기 처리 메서드들 =====

  /// 가져오기 확인 및 실행
  Future<void> _confirmImport() async {
    if (_importResults.isEmpty) return;

    // 중복 파일 확인
    final duplicateFiles = _importResults
        .where((result) =>
            _hiveService.vocabularyFileExists(result.vocabularyFile))
        .map((result) => result.vocabularyFile)
        .toList();

    if (duplicateFiles.isNotEmpty) {
      final action = await _showDuplicateDialog(duplicateFiles);
      if (action == null || action == 'cancel') return;

      await _processDuplicateAction(action, duplicateFiles);
    } else {
      await _processImport();
    }
  }

  /// 중복 처리 다이얼로그 표시
  Future<String?> _showDuplicateDialog(List<String> duplicateFiles) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(tr('duplicates.title', namespace: 'dialogs/vocabulary_import')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('duplicates.message', namespace: 'dialogs/vocabulary_import', params: {
                  'name': duplicateFiles.length == 1
                      ? duplicateFiles.first
                      : tr('duplicates.multiple_vocabularies', namespace: 'dialogs/vocabulary_import', params: {'count': duplicateFiles.length})
              })),
              if (duplicateFiles.length > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tr('duplicates.duplicate_list', namespace: 'dialogs/vocabulary_import', params: {'list': duplicateFiles.join(', ')}),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text(tr('dialog.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('replace'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(tr('duplicates.replace_vocabulary', namespace: 'dialogs/vocabulary_import')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('merge'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text(tr('duplicates.merge_vocabulary', namespace: 'dialogs/vocabulary_import')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('rename'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: Text(tr('duplicates.rename_vocabulary', namespace: 'dialogs/vocabulary_import')),
            ),
          ],
        );
      },
    );
  }

  /// 중복 처리 액션 실행
  Future<void> _processDuplicateAction(
      String action, List<String> duplicateFiles) async {
    _setLoading(true);

    try {
      await _importService.handleDuplicateVocabulary(
          action, duplicateFiles, _importResults);
      await _processImport(isMerge: action == 'merge');
    } catch (e) {
      _setLoading(false);
      _setTemporaryStatusMessage(
          tr('errors.file_processing', namespace: 'dialogs/vocabulary_import', params: {'error': e.toString()}),
          isError: true);
    }
  }

  /// 실제 가져오기 처리
  Future<void> _processImport({bool isMerge = false}) async {
    _setLoading(true);
    setState(() => _statusMessage = '');

    try {
      int totalImported = 0;
      final errorMessages = <String>[];

      // 모든 결과 처리
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

      _setLoading(false);

      if (errorMessages.isNotEmpty) {
        _setTemporaryStatusMessage(
            tr('errors.partial_error_message', namespace: 'dialogs/vocabulary_import', params: {
                'errors': errorMessages.map(_cleanErrorMessage).join('\n'),
                'successCount': totalImported
            }),
            isError: true);

        // 부분 성공 시 2초 후 닫기
        Timer(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      } else {
        _showSuccessAndClose(tr('success.vocab_added', namespace: 'dialogs/vocabulary_import'));
      }
    } catch (e) {
      _setLoading(false);
      _setTemporaryStatusMessage(
          tr('errors.file_processing', namespace: 'dialogs/vocabulary_import', params: {'error': e.toString()}),
          isError: true);
    }
  }

  /// 미리보기 취소
  void _cancelPreview() {
    setState(() {
      _importResults.clear();
      _totalWords = 0;
      _statusMessage = '';
      _isLoading = false;
    });
  }

  // ===== UI 빌드 메서드들 =====

  @override
  Widget build(BuildContext context) {
    print('🔧 DEBUG: AddVocabularyDialog build 호출됨');
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: _importResults.isEmpty
            ? _buildFileSelectionView()
            : _buildFilePreviewView(),
      ),
    );
  }

  /// 파일 선택 화면
  Widget _buildFileSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDialogHeader(
          icon: Icons.add_circle_outline,
          title: tr('title', namespace: 'dialogs/vocabulary_import'),
        ),
        const SizedBox(height: 24),
        _buildDropZone(),
        const SizedBox(height: 16),
        _buildOrDivider(),
        const SizedBox(height: 16),
        _buildFilePickerButton(),
        const SizedBox(height: 24),
        if (_statusMessage.isNotEmpty) ...[
          _buildStatusMessage(),
          const SizedBox(height: 16),
        ],
        if (_statusMessage.isEmpty) _buildHelpSection(),
        if (_isLoading) ...[
          const SizedBox(height: 16),
          _buildLoadingIndicator(tr('processing_file', namespace: 'dialogs/vocabulary_import')),
        ],
      ],
    );
  }

  /// 파일 미리보기 화면
  Widget _buildFilePreviewView() {
    return SizedBox(
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDialogHeader(
            icon: Icons.preview_outlined,
            title: tr('file_info.preview_title_with_count', namespace: 'dialogs/vocabulary_import', params: {
                'count': _importResults.length
            }),
          ),
          const SizedBox(height: 16),
          _buildFileSummary(),
          const SizedBox(height: 16),
          Expanded(
            child: _statusMessage.isNotEmpty
                ? _buildStatusMessage(isExpanded: true)
                : _buildPreviewContent(),
          ),
          const SizedBox(height: 16),
          _buildPreviewActionButtons(),
        ],
      ),
    );
  }

  /// 다이얼로그 헤더
  Widget _buildDialogHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B8E23), size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B8E23),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          tooltip: tr('dialog.close'),
        ),
      ],
    );
  }

  /// 드래그앤드롭 영역
  Widget _buildDropZone() {
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setupDropZoneEvents(context);
        });

        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? const Color(0xFF6B8E23) : Colors.grey[300]!,
              width: _isDragOver ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _isDragOver
                ? const Color(0xFF6B8E23).withValues(alpha: 0.1)
                : Colors.grey[50],
          ),
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
                    ? tr('drag_drop_active', namespace: 'dialogs/vocabulary_import')
                    : tr('drag_multiple_files', namespace: 'dialogs/vocabulary_import'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      _isDragOver ? const Color(0xFF6B8E23) : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                tr('csv_only_support', namespace: 'dialogs/vocabulary_import'),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 구분선
  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            tr('or_divider', namespace: 'dialogs/vocabulary_import'),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  /// 파일 선택 버튼
  Widget _buildFilePickerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _pickFiles,
        icon: const Icon(Icons.folder_open),
        label: Text(tr('select_files', namespace: 'dialogs/vocabulary_import')),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B8E23),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }

  /// 상태 메시지
  Widget _buildStatusMessage({bool isExpanded = false}) {
    final isError = _statusMessage.contains(tr('errors.error_keyword', namespace: 'dialogs/vocabulary_import'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red[200]! : Colors.green[200]!,
        ),
      ),
      child: isExpanded
          ? SingleChildScrollView(
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: isError ? Colors.red[700] : Colors.green[700],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            )
          : Text(
              _statusMessage,
              style: TextStyle(
                color: isError ? Colors.red[700] : Colors.green[700],
                fontSize: 14,
              ),
            ),
    );
  }

  /// 도움말 섹션
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
                tr('help.title', namespace: 'dialogs/vocabulary_import'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${tr('help.header_rule', namespace: 'dialogs/vocabulary_import')}\n'
            '${tr('help.required_columns', namespace: 'dialogs/vocabulary_import')}\n'
            '${tr('help.optional_columns', namespace: 'dialogs/vocabulary_import')}\n'
            '${tr('help.encoding', namespace: 'dialogs/vocabulary_import')}\n'
            '${tr('help.multiple_files', namespace: 'dialogs/vocabulary_import')}',
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

  /// 로딩 인디케이터
  Widget _buildLoadingIndicator(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(message),
      ],
    );
  }

  /// 파일 요약 정보
  Widget _buildFileSummary() {
    return Container(
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
              const Icon(Icons.folder_copy, color: Color(0xFF6B8E23), size: 20),
              const SizedBox(width: 8),
              Text(
                tr('file_info.selected_files', namespace: 'dialogs/vocabulary_import', params: {'count': _importResults.length}),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(tr('file_info.total_words', namespace: 'dialogs/vocabulary_import', params: {'count': _totalWords})),
          const SizedBox(height: 8),
          Text(
            tr('file_info.file_list', namespace: 'dialogs/vocabulary_import', params: {
                'list': _importResults.map((r) => r.fileName).join(', ')
            }),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// 미리보기 내용
  Widget _buildPreviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('file_info.data_preview', namespace: 'dialogs/vocabulary_import'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _importResults
                  .map((result) => _buildFilePreviewCard(result))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 개별 파일 미리보기 카드
  Widget _buildFilePreviewCard(VocabularyImportResult result) {
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
          Row(
            children: [
              const Icon(Icons.description, color: Color(0xFF6B8E23), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  result.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B8E23),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${result.wordCount}${tr('units.words')}',
                  style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...result.previewData.take(3).map((data) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['TargetVoca'] ?? ''} → ${data['ReferenceVoca'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (data['POS']?.isNotEmpty == true ||
                      data['Type']?.isNotEmpty == true)
                    Text(
                      '${data['POS'] ?? ''} ${data['Type'] ?? ''}'.trim(),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 미리보기 액션 버튼들
  Widget _buildPreviewActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _cancelPreview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(tr('dialog.cancel')),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? _buildLoadingIndicator(tr('importing_files', namespace: 'dialogs/vocabulary_import'))
                : Text(tr('import_files_button', namespace: 'dialogs/vocabulary_import', params: {
                    'count': _importResults.length
                })),
          ),
        ),
      ],
    );
  }

  /// 오류 메시지에서 불필요한 정보 제거
  String _cleanErrorMessage(String errorMessage) {
    // 번역 키가 표시되는 경우 처리
    if (errorMessage.contains('[dialogs/vocabulary_import/errors:')) {
      if (errorMessage.contains('missing_required_columns')) {
        return tr('errors.missing_required_columns', namespace: 'dialogs/vocabulary_import');
      }
      if (errorMessage.contains('empty_file')) {
        return tr('errors.empty_file', namespace: 'dialogs/vocabulary_import');
      }
      if (errorMessage.contains('no_valid_data')) {
        return tr('errors.no_valid_data', namespace: 'dialogs/vocabulary_import');
      }
    }
    
    // 디렉토리 경로 제거 (파일명만 유지)
    String cleaned = errorMessage.replaceAllMapped(
      RegExp(r'[C-Z]:[\\\/].*[\\\/]([^\\\/]+\.csv)', caseSensitive: false),
      (match) => match.group(1) ?? match.group(0) ?? '',
    );
    
    // Unix 스타일 경로 제거
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\/.*\/([^\/]+\.csv)'),
      (match) => match.group(1) ?? match.group(0) ?? '',
    );
    
    // \n을 실제 줄바꿈으로 변환 (이중 백슬래시도 처리)
    cleaned = cleaned.replaceAll('\\\\n', '\n');
    cleaned = cleaned.replaceAll('\\n', '\n');
    
    // 추가 정리: 연속된 공백이나 줄바꿈 정리
    cleaned = cleaned.replaceAll(RegExp(r'\n+'), '\n').trim();
    
    return cleaned;
  }
}
