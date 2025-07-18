import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/i18n/simple_i18n.dart';
import '../dialogs/daily_goals_dialog.dart';
import '../../services/home/study_status/study_status_service.dart';

class StudyStatusSection extends StatefulWidget {
  const StudyStatusSection({super.key});

  @override
  State<StudyStatusSection> createState() => _StudyStatusSectionState();
}

class _StudyStatusSectionState extends State<StudyStatusSection> {
  final StudyStatusService _studyStatusService = StudyStatusService.instance;
  StreamSubscription<StudyStatusStats>? _statsSubscription;
  StudyStatusStats _currentStats = const StudyStatusStats();

  @override
  void initState() {
    super.initState();
    _subscribeToStats();
    _initializeStats();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }

  /// 통계 스트림 구독
  void _subscribeToStats() {
    _statsSubscription = _studyStatusService.statsStream.listen(
      (stats) {
        if (mounted) {
          setState(() {
            _currentStats = stats;
          });
          print('🔍 StudyStatusSection: 통계 업데이트됨 - 총 ${stats.totalWords}개 단어');
        }
      },
      onError: (error) {
        print('❌ StudyStatusSection: 통계 스트림 오류 - $error');
      },
    );
  }

  /// 통계 초기화
  void _initializeStats() async {
    setState(() {
      _currentStats = _studyStatusService.currentStats;
    });
    
    // 최신 통계로 새로고침
    await _studyStatusService.refreshStats();
  }

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
                    tr('stats.total_words', namespace: 'home/study_status'), 
                    '${_formatNumber(_currentStats.totalWords)}${tr('units.words', namespace: 'common')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.total_favorites', namespace: 'home/study_status'), 
                    '${_formatNumber(_currentStats.totalFavorites)}${tr('units.words', namespace: 'common')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.total_wrong_words', namespace: 'home/study_status'), 
                    '${_currentStats.totalWrongWords}${tr('units.words', namespace: 'common')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.total_wrong_count', namespace: 'home/study_status'), 
                    '${_currentStats.totalWrongCount}${tr('units.count', namespace: 'common')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(tr('stats.average_accuracy', namespace: 'home/study_status'),
                    '${_currentStats.averageAccuracy.toStringAsFixed(1)}${tr('units.percent', namespace: 'common')}')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildStatCard(
                    tr('stats.study_streak', namespace: 'home/study_status'), 
                    '${_currentStats.studyStreak}${tr('units.days', namespace: 'common')}')),
          ],
        ),
      ],
        );
      },
    );
  }

  /// 숫자를 천 단위 콤마로 포맷팅
  String _formatNumber(int number) {
    if (number == 0) return '0';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
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
