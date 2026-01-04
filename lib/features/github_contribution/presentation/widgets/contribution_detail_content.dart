import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ContributionDetailContent extends StatefulWidget {
  final DateTime date;
  final int count;
  final Map<DateTime, int> contributionMap;
  final DateTime yearStart;
  final DateTime yearEnd;

  const ContributionDetailContent({
    super.key,
    required this.date,
    required this.count,
    required this.contributionMap,
    required this.yearStart,
    required this.yearEnd,
  });

  @override
  State<ContributionDetailContent> createState() =>
      _ContributionDetailContentState();
}

class _ContributionDetailContentState extends State<ContributionDetailContent> {
  late DateTime _currentDate;
  late int _currentCount;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.date;
    _currentCount = widget.count;
  }

  bool _canMoveToPreviousDay() {
    final previousDay = _currentDate.subtract(const Duration(days: 1));
    return !previousDay.isBefore(widget.yearStart);
  }

  bool _canMoveToNextDay() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final nextDay = _currentDate.add(const Duration(days: 1));
    return !nextDay.isAfter(todayNormalized) &&
        nextDay.year == widget.yearStart.year;
  }

  void _moveToDay(DateTime date) {
    final dateNormalized = DateTime(date.year, date.month, date.day);
    final count = widget.contributionMap[dateNormalized] ?? 0;

    setState(() {
      _currentDate = dateNormalized;
      _currentCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);
    final isDark = brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日付表示とナビゲーション
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: _canMoveToPreviousDay()
                    ? textColor
                    : textColor.withValues(alpha: 0.3),
              ),
              onPressed: _canMoveToPreviousDay()
                  ? () => _moveToDay(
                      _currentDate.subtract(const Duration(days: 1)),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                '${_currentDate.year}年${_currentDate.month}月${_currentDate.day}日',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: _canMoveToNextDay()
                    ? textColor
                    : textColor.withValues(alpha: 0.3),
              ),
              onPressed: _canMoveToNextDay()
                  ? () => _moveToDay(_currentDate.add(const Duration(days: 1)))
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Contribution数表示
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColor(_currentCount, brightness),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _currentCount > 0
                  ? '$_currentCount contributions'
                  : 'No contributions',
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 活動レベル表示
        _buildActivityLevel(_currentCount, textColor, isDark),
      ],
    );
  }

  Widget _buildActivityLevel(int count, Color textColor, bool isDark) {
    String level;
    Color levelColor;

    if (count == 0) {
      level = '活動なし';
      levelColor = isDark
          ? AppColors.githubDarkBorder
          : AppColors.githubLightBorder;
    } else if (count <= 3) {
      level = 'もう少し頑張りましょう！';
      levelColor = const Color(0xFF0E4429);
    } else if (count <= 9) {
      level = '素晴らしい';
      levelColor = const Color(0xFF006D32);
    } else if (count <= 19) {
      level = 'すごい！';
      levelColor = const Color(0xFF26A641);
    } else {
      level = 'すごすぎる！';
      levelColor = const Color(0xFF39D353);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.githubDarkBorder.withValues(alpha: 0.2)
            : AppColors.githubLightBorder.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: levelColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(level, style: TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );
  }

  Color _getColor(int count, Brightness brightness) {
    if (brightness == Brightness.dark) {
      if (count == 0) {
        return AppColors.githubDarkBorder.withValues(alpha: 0.2);
      } else if (count <= 3) {
        return const Color(0xFF0E4429);
      } else if (count <= 9) {
        return const Color(0xFF006D32);
      } else if (count <= 19) {
        return const Color(0xFF26A641);
      } else {
        return const Color(0xFF39D353);
      }
    } else {
      if (count == 0) {
        return AppColors.githubDarkBorder.withValues(alpha: 0.3);
      } else if (count <= 3) {
        return const Color(0xFFACD5A2);
      } else if (count <= 9) {
        return const Color(0xFF6BCB77);
      } else if (count <= 19) {
        return const Color(0xFF26A641);
      } else {
        return const Color(0xFF006D32);
      }
    }
  }
}
