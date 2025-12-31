import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import 'dart:math';

class ContributionCalendarWidget extends StatefulWidget {
  final List<Contribution> contributions;
  final double cellSize;
  final double cellSpacing;
  final int? initialYear;
  final ValueChanged<int>? onYearChanged;

  const ContributionCalendarWidget({
    super.key,
    required this.contributions,
    this.cellSize = 18.0,
    this.cellSpacing = 3.0,
    this.initialYear,
    this.onYearChanged,
  });

  @override
  State<ContributionCalendarWidget> createState() =>
      _ContributionCalendarWidgetState();
}

class _ContributionCalendarWidgetState
    extends State<ContributionCalendarWidget> {
  final ScrollController _scrollController = ScrollController();
  late int _selectedYear;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear ?? DateTime.now().year;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _hasScrolled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final today = DateTime.now();

    final contributionMap = <DateTime, int>{};
    for (final c in widget.contributions) {
      contributionMap[DateTime(c.date.year, c.date.month, c.date.day)] =
          c.count;
    }

    final startDate = DateTime(_selectedYear, 1, 1);
    final endDate = DateTime(_selectedYear, 12, 31).isAfter(today)
        ? today
        : DateTime(_selectedYear, 12, 31);

    final weeks = _generateWeeks(startDate, endDate, contributionMap);
    final availableYears = List.generate(6, (i) => today.year - i);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? max(0.0, constraints.maxWidth - 40)
            : double.infinity;
        final availableHeight = constraints.maxHeight.isFinite
            ? max(0.0, constraints.maxHeight - 120)
            : double.infinity;

        double cellSize = widget.cellSize;
        if (availableWidth > 0 && availableHeight > 0 && weeks.isNotEmpty) {
          final widthPerCell =
              availableWidth /
              (weeks.length * (widget.cellSize + widget.cellSpacing));
          final heightPerCell =
              availableHeight / (7 * (widget.cellSize + widget.cellSpacing));
          cellSize = max(
            12.0,
            min(widget.cellSize, min(widthPerCell, heightPerCell)),
          );
        }

        final height = 7 * (cellSize + widget.cellSpacing);

        if (!_hasScrolled) {
          _scrollToEnd();
        }

        final total = widget.contributions
            .where((c) => c.date.year == _selectedYear)
            .fold<int>(0, (sum, c) => sum + c.count);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedYear年のContribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor(brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total contributions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor(
                          brightness,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: availableYears.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        '$year年',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor(brightness),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null && year != _selectedYear) {
                      setState(() {
                        _selectedYear = year;
                        _hasScrolled = false;
                      });
                      widget.onYearChanged?.call(year);
                      _scrollToEnd();
                    }
                  },
                  underline: Container(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textColor(brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? AppColors.githubDarkSurface.withOpacity(0.85)
                    : AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderColor(brightness),
                  width: 1,
                ),
              ),
              child: SizedBox(
                height: constraints.maxHeight.isFinite
                    ? min(height, constraints.maxHeight - 100)
                    : height,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollController,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: weeks.map((week) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: week.map((cell) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: widget.cellSpacing,
                              bottom: widget.cellSpacing,
                            ),
                            child: _buildCell(cell, cellSize, brightness),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCell(CalendarCell cell, double size, Brightness brightness) {
    return Tooltip(
      message: cell.count > 0
          ? '${cell.date.year}/${cell.date.month}/${cell.date.day}: ${cell.count} contributions'
          : '${cell.date.year}/${cell.date.month}/${cell.date.day}: No contributions',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getColor(cell.count, brightness),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Color _getColor(int count, Brightness brightness) {
    if (brightness == Brightness.dark) {
      if (count == 0) return AppColors.githubDarkBorder.withValues(alpha: 0.2);
      if (count <= 3) return const Color(0xFF0E4429);
      if (count <= 9) return const Color(0xFF006D32);
      if (count <= 19) return const Color(0xFF26A641);
      return const Color(0xFF39D353);
    } else {
      if (count == 0) return AppColors.githubDarkBorder.withValues(alpha: 0.2);
      if (count <= 3) return const Color(0xFF9BE9A8);
      if (count <= 9) return const Color(0xFF40C463);
      if (count <= 19) return const Color(0xFF30A14E);
      return const Color(0xFF216E39);
    }
  }

  List<List<CalendarCell>> _generateWeeks(
    DateTime start,
    DateTime end,
    Map<DateTime, int> map,
  ) {
    final weeks = <List<CalendarCell>>[];

    // 開始日を含む週の日曜日を取得
    final startWeekday = start.weekday;
    var weekStart = start.subtract(
      Duration(days: startWeekday == 7 ? 0 : startWeekday),
    );
    if (weekStart.weekday != 7) {
      weekStart = weekStart.subtract(Duration(days: weekStart.weekday));
    }

    // 終了日を含む週の日曜日を取得
    final endWeekday = end.weekday;
    final endWeekStart = endWeekday == 7
        ? end
        : end.subtract(Duration(days: endWeekday));

    while (weekStart.isBefore(endWeekStart) ||
        weekStart.isAtSameMomentAs(endWeekStart)) {
      final week = <CalendarCell>[];
      for (int i = 0; i < 7; i++) {
        final date = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + i,
        );
        final isInRange =
            date.isAfter(start.subtract(const Duration(days: 1))) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end));

        week.add(
          CalendarCell(
            date: date,
            count: isInRange ? (map[date] ?? 0) : 0,
            isEmpty: !isInRange,
          ),
        );
      }
      weeks.add(week);
      weekStart = weekStart.add(const Duration(days: 7));
      if (weekStart.isAfter(endWeekStart)) break;
    }

    return weeks;
  }
}

class CalendarCell {
  final DateTime date;
  final int count;
  final bool isEmpty;

  CalendarCell({required this.date, required this.count, this.isEmpty = false});
}
