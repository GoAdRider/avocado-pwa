import 'package:flutter/material.dart';
import '../../utils/i18n/simple_i18n.dart';
import '../dialogs/daily_goals_dialog.dart';

class StudyStatusSection extends StatefulWidget {
  const StudyStatusSection({super.key});

  @override
  State<StudyStatusSection> createState() => _StudyStatusSectionState();
}

class _StudyStatusSectionState extends State<StudyStatusSection> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageNotifier.instance,
      builder: (context, _) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr('section.title', namespace: 'home/study_status'),
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
                  tr('stats.todays_goal', namespace: 'home/study_status'),
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
                  tr('stats.detailed_stats', namespace: 'home/study_status'),
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
                    tr('stats.total_words', namespace: 'home/study_status'), '1,234${tr('units.words')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.total_favorites', namespace: 'home/study_status'), '45${tr('units.words')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.total_wrong_words', namespace: 'home/study_status'), '0${tr('units.words')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.total_wrong_count', namespace: 'home/study_status'), '0${tr('units.count')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(tr('stats.average_accuracy', namespace: 'home/study_status'),
                    '85.2${tr('units.percent')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.study_streak', namespace: 'home/study_status'), '7${tr('units.days')}')),
          ],
        ),
      ],
        );
      },
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
        return const DailyGoalsDialog();
      },
    );
  }

}
