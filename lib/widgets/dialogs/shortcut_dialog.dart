import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/i18n/simple_i18n.dart';

class ShortcutDialog extends StatefulWidget {
  const ShortcutDialog({super.key});

  @override
  State<ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<ShortcutDialog> {
  bool _isEditingShortcut = false;
  String _editingKey = '';

  // 단축키 맵 (LocalStorage에서 로드되어야 함)
  Map<String, String> _cardShortcuts = {
    'card_flip': 'Space',
    'previous_card': 'ArrowLeft',
    'next_card': 'ArrowRight',
    'favorite_toggle': 'KeyS',
    'detail_toggle': 'KeyD',
    'shuffle': 'KeyR',
    'remove': 'Delete',
  };

  Map<String, String> _gameShortcuts = {
    'beginner_hint': 'F6',
    'intermediate_hint': 'F7',
    'advanced_hint': 'F8',
    'game_pause': 'F10',
    'answer_submit': 'Enter',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: LocalStorage에서 설정 로드
    // _cardShortcuts = localStorage.getStringMap('card_shortcuts') ?? defaultCardShortcuts;
    // _gameShortcuts = localStorage.getStringMap('game_shortcuts') ?? defaultGameShortcuts;
  }

  void _saveSettings() {
    // TODO: LocalStorage에 설정 저장
    // localStorage.setStringMap('card_shortcuts', _cardShortcuts);
    // localStorage.setStringMap('game_shortcuts', _gameShortcuts);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('dialog.save_success')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startEditingShortcut(String key) {
    setState(() {
      _isEditingShortcut = true;
      _editingKey = key;
    });
  }

  void _handleKeyPress(KeyEvent event) {
    if (!_isEditingShortcut) return;

    if (event is KeyDownEvent) {
      String newKey = event.logicalKey.keyLabel;

      // 유효성 검사
      if (_isValidKey(newKey) && !_isKeyInUse(newKey)) {
        setState(() {
          if (_cardShortcuts.containsKey(_editingKey)) {
            _cardShortcuts[_editingKey] = newKey;
          } else if (_gameShortcuts.containsKey(_editingKey)) {
            _gameShortcuts[_editingKey] = newKey;
          }
          _isEditingShortcut = false;
          _editingKey = '';
        });
        _saveSettings();
      } else {
        // 에러 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isKeyInUse(newKey)
                ? tr('key_conflict', namespace: 'dialogs/shortcuts')
                : tr('invalid_key', namespace: 'dialogs/shortcuts')),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidKey(String key) {
    // PWA에서 안전한 키들만 허용
    const validKeys = [
      'Space',
      'Enter',
      'Delete',
      'KeyA',
      'KeyB',
      'KeyC',
      'KeyD',
      'KeyE',
      'KeyF',
      'KeyG',
      'KeyH',
      'KeyI',
      'KeyJ',
      'KeyK',
      'KeyL',
      'KeyM',
      'KeyN',
      'KeyO',
      'KeyP',
      'KeyQ',
      'KeyR',
      'KeyS',
      'KeyT',
      'KeyU',
      'KeyV',
      'KeyW',
      'KeyX',
      'KeyY',
      'KeyZ',
      'F1',
      'F2',
      'F3',
      'F4',
      'F5',
      'F6',
      'F7',
      'F8',
      'F9',
      'F10',
      'F11',
      'F12',
      'ArrowLeft',
      'ArrowRight',
      'ArrowUp',
      'ArrowDown'
    ];
    return validKeys.contains(key);
  }

  bool _isKeyInUse(String key) {
    // 시스템 단축키는 사용 불가
    const systemKeys = ['F12', 'Escape'];
    if (systemKeys.contains(key)) return true;

    // 다른 단축키와 중복 확인
    List<String> allShortcuts = [
      ..._cardShortcuts.values,
      ..._gameShortcuts.values
    ];
    return allShortcuts.contains(key);
  }

  void _resetCardShortcuts() {
    setState(() {
      _cardShortcuts = {
        'card_flip': 'Space',
        'previous_card': 'ArrowLeft',
        'next_card': 'ArrowRight',
        'favorite_toggle': 'KeyS',
        'detail_toggle': 'KeyD',
        'shuffle': 'KeyR',
        'remove': 'Delete',
      };
    });
    _saveSettings();
  }

  void _resetGameShortcuts() {
    setState(() {
      _gameShortcuts = {
        'beginner_hint': 'F6',
        'intermediate_hint': 'F7',
        'advanced_hint': 'F8',
        'game_pause': 'F10',
        'answer_submit': 'Enter',
      };
    });
    _saveSettings();
  }

  void _resetAllShortcuts() {
    _resetCardShortcuts();
    _resetGameShortcuts();
  }

  String _formatKeyDisplay(String key) {
    // 키 표시를 사용자 친화적으로 변환
    switch (key) {
      case 'ArrowLeft':
        return '←';
      case 'ArrowRight':
        return '→';
      case 'ArrowUp':
        return '↑';
      case 'ArrowDown':
        return '↓';
      case 'Space':
        return 'Space';
      case 'Enter':
        return 'Enter';
      case 'Delete':
        return 'Delete';
      default:
        if (key.startsWith('Key')) {
          return key.substring(3); // KeyS -> S
        }
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyPress,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 600,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('title', namespace: 'dialogs/shortcuts'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 스크롤 가능한 컨텐츠
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 단축키 편집 섹션
                      _buildShortcutSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시스템 단축키 (편집 불가)
        _buildSystemShortcuts(),
        const SizedBox(height: 24),

        // 카드형 학습 단축키
        _buildCardShortcuts(),
        const SizedBox(height: 24),

        // 게임 전용 단축키
        _buildGameShortcuts(),
        const SizedBox(height: 24),

        // 전체 초기화 버튼
        ElevatedButton(
          onPressed: _resetAllShortcuts,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: Text(tr('reset_all_shortcuts', namespace: 'dialogs/shortcuts')),
        ),
      ],
    );
  }

  Widget _buildSystemShortcuts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('system_shortcuts', namespace: 'dialogs/shortcuts'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildShortcutItem(
              'F1', tr('toggle_edit_desc', namespace: 'dialogs/shortcuts'), false),
          _buildShortcutItem(
              'F2', tr('settings_shortcut_desc', namespace: 'dialogs/shortcuts'), false),
          _buildShortcutItem(
              'ESC', tr('escape_desc', namespace: 'dialogs/shortcuts'), false),
        ],
      ),
    );
  }

  Widget _buildCardShortcuts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('card_shortcuts', namespace: 'dialogs/shortcuts'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetCardShortcuts,
                child: Text(tr('reset_card_shortcuts', namespace: 'dialogs/shortcuts')),
              ),
            ],
          ),
          Text(
            tr('card_shortcuts_scope', namespace: 'dialogs/shortcuts'),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _buildEditableShortcutItem('card_flip', _cardShortcuts['card_flip']!,
              tr('card_flip_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem('previous_card',
              _cardShortcuts['previous_card']!, tr('previous_card_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem('next_card', _cardShortcuts['next_card']!,
              tr('next_card_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem(
              'favorite_toggle',
              _cardShortcuts['favorite_toggle']!,
              tr('favorite_toggle_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem('detail_toggle',
              _cardShortcuts['detail_toggle']!, tr('detail_toggle_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem(
              'shuffle', _cardShortcuts['shuffle']!, tr('shuffle_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem(
              'remove', _cardShortcuts['remove']!, tr('remove_desc', namespace: 'dialogs/shortcuts')),
        ],
      ),
    );
  }

  Widget _buildGameShortcuts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('game_shortcuts', namespace: 'dialogs/shortcuts'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetGameShortcuts,
                child: Text(tr('reset_game_shortcuts', namespace: 'dialogs/shortcuts')),
              ),
            ],
          ),
          Text(
            tr('game_shortcuts_scope', namespace: 'dialogs/shortcuts'),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _buildEditableShortcutItem('beginner_hint',
              _gameShortcuts['beginner_hint']!, tr('beginner_hint_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem(
              'intermediate_hint',
              _gameShortcuts['intermediate_hint']!,
              tr('intermediate_hint_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem('advanced_hint',
              _gameShortcuts['advanced_hint']!, tr('advanced_hint_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem('game_pause',
              _gameShortcuts['game_pause']!, tr('game_pause_desc', namespace: 'dialogs/shortcuts')),
          _buildEditableShortcutItem('answer_submit',
              _gameShortcuts['answer_submit']!, tr('answer_submit_desc', namespace: 'dialogs/shortcuts')),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(String key, String description, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  Widget _buildEditableShortcutItem(
      String keyId, String currentKey, String description) {
    bool isCurrentlyEditing = _isEditingShortcut && _editingKey == keyId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentlyEditing
                  ? Colors.blue.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border:
                  isCurrentlyEditing ? Border.all(color: Colors.blue) : null,
            ),
            child: Text(
              isCurrentlyEditing
                  ? tr('editing_key', namespace: 'dialogs/shortcuts')
                  : _formatKeyDisplay(currentKey),
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: isCurrentlyEditing ? Colors.blue : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
          const SizedBox(width: 8),
          TextButton(
            onPressed:
                isCurrentlyEditing ? null : () => _startEditingShortcut(keyId),
            child: Text(tr('edit_button', namespace: 'dialogs/shortcuts')),
          ),
        ],
      ),
    );
  }
}