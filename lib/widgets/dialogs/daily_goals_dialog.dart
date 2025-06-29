import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../../services/dialogs/daily_goals_service.dart';

class DailyGoalsDialog extends StatefulWidget {
  const DailyGoalsDialog({super.key});

  @override
  State<DailyGoalsDialog> createState() => _DailyGoalsDialogState();
}

class _DailyGoalsDialogState extends State<DailyGoalsDialog> {
  final DailyGoalsService _service = DailyGoalsService.instance;
  
  late final TextEditingController _dailyNewWordsController;
  late final TextEditingController _dailyReviewWordsController;
  late final TextEditingController _dailyPerfectAnswersController;
  late final TextEditingController _weeklyGoalController;
  late final TextEditingController _monthlyGoalController;

  @override
  void initState() {
    super.initState();
    
    final goals = _service.getCurrentGoals();
    _dailyNewWordsController = TextEditingController(text: goals.dailyNewWords.toString());
    _dailyReviewWordsController = TextEditingController(text: goals.dailyReviewWords.toString());
    _dailyPerfectAnswersController = TextEditingController(text: goals.dailyPerfectAnswers.toString());
    _weeklyGoalController = TextEditingController(text: goals.weeklyGoal.toString());
    _monthlyGoalController = TextEditingController(text: goals.monthlyGoal.toString());
  }

  @override
  void dispose() {
    _dailyNewWordsController.dispose();
    _dailyReviewWordsController.dispose();
    _dailyPerfectAnswersController.dispose();
    _weeklyGoalController.dispose();
    _monthlyGoalController.dispose();
    super.dispose();
  }

  Widget _buildGoalField({
    required String labelKey,
    required TextEditingController controller,
    required String unitKey,
    int? min,
    int? max,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              tr(labelKey, namespace: 'dialogs/daily_goals'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                suffix: Text(
                  tr(unitKey, namespace: 'dialogs/daily_goals'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return tr('messages.invalid_value', namespace: 'dialogs/daily_goals');
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return tr('messages.invalid_value', namespace: 'dialogs/daily_goals');
                }
                if (min != null && number < min) {
                  return '최소 $min 이상 입력해주세요.';
                }
                if (max != null && number > max) {
                  return '최대 $max 이하 입력해주세요.';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveGoals() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newGoals = DailyGoals(
      dailyNewWords: int.parse(_dailyNewWordsController.text),
      dailyReviewWords: int.parse(_dailyReviewWordsController.text),
      dailyPerfectAnswers: int.parse(_dailyPerfectAnswersController.text),
      weeklyGoal: int.parse(_weeklyGoalController.text),
      monthlyGoal: int.parse(_monthlyGoalController.text),
    );

    _service.saveGoals(newGoals);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('messages.save_success', namespace: 'dialogs/daily_goals')),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  void _resetGoals() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('actions.reset', namespace: 'dialogs/daily_goals')),
        content: Text(tr('messages.reset_confirm', namespace: 'dialogs/daily_goals')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('actions.cancel', namespace: 'dialogs/daily_goals')),
          ),
          TextButton(
            onPressed: () {
              final defaultGoals = DailyGoals.defaultGoals();
              _dailyNewWordsController.text = defaultGoals.dailyNewWords.toString();
              _dailyReviewWordsController.text = defaultGoals.dailyReviewWords.toString();
              _dailyPerfectAnswersController.text = defaultGoals.dailyPerfectAnswers.toString();
              _weeklyGoalController.text = defaultGoals.weeklyGoal.toString();
              _monthlyGoalController.text = defaultGoals.monthlyGoal.toString();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: Text(tr('actions.reset', namespace: 'dialogs/daily_goals')),
          ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('title', namespace: 'dialogs/daily_goals')),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('description', namespace: 'dialogs/daily_goals'),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                _buildGoalField(
                  labelKey: 'goals.daily_new_words',
                  controller: _dailyNewWordsController,
                  unitKey: 'units.words',
                  min: 1,
                  max: 100,
                ),
                
                _buildGoalField(
                  labelKey: 'goals.daily_review_words',
                  controller: _dailyReviewWordsController,
                  unitKey: 'units.words',
                  min: 1,
                  max: 100,
                ),
                
                _buildGoalField(
                  labelKey: 'goals.daily_perfect_answers',
                  controller: _dailyPerfectAnswersController,
                  unitKey: 'units.count',
                  min: 1,
                  max: 100,
                ),
                
                _buildGoalField(
                  labelKey: 'goals.weekly_goal',
                  controller: _weeklyGoalController,
                  unitKey: 'units.words',
                  min: 10,
                  max: 1000,
                ),
                
                _buildGoalField(
                  labelKey: 'goals.monthly_goal',
                  controller: _monthlyGoalController,
                  unitKey: 'units.words',
                  min: 50,
                  max: 5000,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetGoals,
          child: Text(tr('actions.reset', namespace: 'dialogs/daily_goals')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('actions.cancel', namespace: 'dialogs/daily_goals')),
        ),
        ElevatedButton(
          onPressed: _saveGoals,
          child: Text(tr('actions.save', namespace: 'dialogs/daily_goals')),
        ),
      ],
    );
  }
}