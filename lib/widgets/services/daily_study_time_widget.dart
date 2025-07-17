import 'package:flutter/material.dart';
import '../../services/common/daily_study_time_service.dart';

/// 당일 누적 공부 시간을 표시하는 위젯
class DailyStudyTimeWidget extends StatefulWidget {
  const DailyStudyTimeWidget({super.key});

  @override
  State<DailyStudyTimeWidget> createState() => _DailyStudyTimeWidgetState();
}

class _DailyStudyTimeWidgetState extends State<DailyStudyTimeWidget> {
  final DailyStudyTimeService _dailyTimeService =
      DailyStudyTimeService.instance;
  Duration _currentTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentTime = _dailyTimeService.getTodayStudyTime();
    _dailyTimeService.dailyTimeStream.listen((time) {
      if (mounted) {
        setState(() {
          _currentTime = time;
        });
      }
    });
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.today,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(_currentTime),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
}