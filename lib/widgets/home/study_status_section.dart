import 'package:flutter/material.dart';
import '../../utils/strings/base_strings.dart';
import '../../utils/strings/home_strings.dart';
import '../../utils/language_provider.dart';

class StudyStatusSection extends StatefulWidget {
  const StudyStatusSection({super.key});

  @override
  State<StudyStatusSection> createState() => _StudyStatusSectionState();
}

class _StudyStatusSectionState extends State<StudyStatusSection> {
  // 목표 설정 상태 변수들
  int _dailyNewWordsGoal = 20;
  int _dailyReviewWordsGoal = 10;
  int _dailyPerfectAnswersGoal = 12;
  int _weeklyGoal = 300;
  int _monthlyGoal = 1200;

  @override
  Widget build(BuildContext context) {
    LanguageProvider.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              HomeStrings.sectionStudyStatus,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // 오늘의 목표 링크버튼
            InkWell(
              onTap: () => _showTodaysGoalDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E23),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  HomeStrings.todaysGoal,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 상세통계 보기 링크버튼
            InkWell(
              onTap: () => print('상세통계 보기'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A2B8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  HomeStrings.detailedStats,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 통계 카드들
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalWords, '1,234${BaseStrings.wordsUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalFavorites, '45${BaseStrings.wordsUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalWrongWords, '0${BaseStrings.wordsUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.totalWrongCount, '0${BaseStrings.countUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(HomeStrings.averageAccuracy,
                    '85.2${BaseStrings.percentUnit}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    HomeStrings.studyStreak, '7${BaseStrings.daysUnit}')),
          ],
        ),
      ],
    );
  }

  // 통계 카드
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 오늘의 목표 다이얼로그
  void _showTodaysGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(HomeStrings.todaysGoal),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGoalItem(
                  '📝 ${HomeStrings.dailyNewWords}',
                  _dailyNewWordsGoal,
                  (value) => setState(() => _dailyNewWordsGoal = value),
                  BaseStrings.wordsUnit,
                ),
                _buildGoalItem(
                  '🔄 ${HomeStrings.dailyReviewWords}',
                  _dailyReviewWordsGoal,
                  (value) => setState(() => _dailyReviewWordsGoal = value),
                  BaseStrings.wordsUnit,
                ),
                _buildGoalItem(
                  '✅ ${HomeStrings.dailyPerfectAnswers}',
                  _dailyPerfectAnswersGoal,
                  (value) => setState(() => _dailyPerfectAnswersGoal = value),
                  BaseStrings.wordsUnit,
                ),
                _buildGoalItem(
                  '📅 ${HomeStrings.weeklyGoalLabel}',
                  _weeklyGoal,
                  (value) => setState(() => _weeklyGoal = value),
                  BaseStrings.wordsUnit,
                ),
                _buildGoalItem(
                  '📆 ${HomeStrings.monthlyGoalLabel}',
                  _monthlyGoal,
                  (value) => setState(() => _monthlyGoal = value),
                  BaseStrings.wordsUnit,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(BaseStrings.close),
            ),
          ],
        );
      },
    );
  }

  // 목표 설정 항목
  Widget _buildGoalItem(
    String title,
    int value,
    ValueChanged<int> onChanged,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14)),
          ),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: unit,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (newValue) {
                final intValue = int.tryParse(newValue) ?? value;
                onChanged(intValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}
