import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import 'contribution_detail_modal.dart';
import 'contribution_detail_content.dart';
import 'dart:math' as math;

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

class _ContributionCalendarWidgetState extends State<ContributionCalendarWidget>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late int _selectedYear;
  bool _hasScrolled = false;
  CalendarCell? _tappedCell;
  CalendarCell? _selectedCell; // 選択されたセルを保持

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear ?? DateTime.now().year;
    // 今日の日付を初期選択状態にする
    _initializeSelectedCell();
  }

  @override
  void didUpdateWidget(ContributionCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // contributionsが更新されたら、選択セルも更新
    if (oldWidget.contributions != widget.contributions) {
      _initializeSelectedCell();
    }
  }

  /// 今日の日付を選択状態に初期化
  void _initializeSelectedCell() {
    if (widget.contributions.isEmpty) {
      // データがまだ読み込まれていない場合は何もしない
      debugPrint('⚠️ Contributions list is empty');
      return;
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // 今日のContribution数を取得
    int todayCount = 0;
    bool found = false;

    debugPrint('');
    debugPrint('🔍🔍🔍 ===== INVESTIGATING TODAY\'S CONTRIBUTION ===== 🔍🔍🔍');
    debugPrint('📅 Current time: $today');
    debugPrint('📅 Today normalized: $todayNormalized');
    debugPrint('📊 Total contributions: ${widget.contributions.length}');

    // データの日付範囲を確認
    if (widget.contributions.isNotEmpty) {
      final allDates = widget.contributions.map((c) => c.date).toList();
      allDates.sort((a, b) => a.compareTo(b));
      debugPrint('📅 Date range in data:');
      debugPrint('   Min: ${allDates.first}');
      debugPrint('   Max: ${allDates.last}');
      debugPrint('   Expected today: $todayNormalized');
      debugPrint(
        '   Today is after max? ${todayNormalized.isAfter(allDates.last)}',
      );
    }
    debugPrint('');

    // 最初の5件のデータを表示
    debugPrint('📅 First 5 dates in data:');
    for (int i = 0; i < math.min(5, widget.contributions.length); i++) {
      final c = widget.contributions[i];
      final normalized = DateTime(c.date.year, c.date.month, c.date.day);
      debugPrint(
        '  [$i] Original: ${c.date} | Normalized: $normalized | Count: ${c.count}',
      );
    }

    // 最後の5件のデータを表示
    debugPrint('');
    debugPrint('📅 Last 5 dates in data:');
    final startIdx = math.max(0, widget.contributions.length - 5);
    for (int i = startIdx; i < widget.contributions.length; i++) {
      final c = widget.contributions[i];
      final normalized = DateTime(c.date.year, c.date.month, c.date.day);
      debugPrint(
        '  [$i] Original: ${c.date} | Normalized: $normalized | Count: ${c.count}',
      );
    }

    debugPrint('');
    debugPrint('🔎 Searching for today ($todayNormalized)...');

    int checkCount = 0;
    for (final c in widget.contributions) {
      final cDate = DateTime(c.date.year, c.date.month, c.date.day);

      // 今日に近い日付をログ出力（前後2日）
      final daysDiff = todayNormalized.difference(cDate).inDays.abs();
      if (daysDiff <= 2) {
        debugPrint(
          '  Nearby date: ${c.date} (normalized: $cDate) | Count: ${c.count} | Days diff: $daysDiff',
        );
      }

      // デバッグ: 日付を出力
      if (cDate.year == todayNormalized.year &&
          cDate.month == todayNormalized.month &&
          cDate.day == todayNormalized.day) {
        todayCount = c.count;
        found = true;
        debugPrint('');
        debugPrint('✅✅✅ FOUND TODAY\'S CONTRIBUTION! ✅✅✅');
        debugPrint('   Original date: ${c.date}');
        debugPrint('   Normalized date: $cDate');
        debugPrint('   Count: $todayCount');
        break;
      }
      checkCount++;
    }

    debugPrint('');
    if (!found) {
      debugPrint('❌❌❌ TODAY\'S CONTRIBUTION NOT FOUND! ❌❌❌');
      debugPrint('   Looking for: $todayNormalized');
      debugPrint('   Checked ${checkCount} items');
    }

    debugPrint('');
    debugPrint('📝 Creating _selectedCell:');
    debugPrint('   Date: $todayNormalized');
    debugPrint('   Count: $todayCount');
    debugPrint('   isEmpty: false');

    setState(() {
      _selectedCell = CalendarCell(
        date: todayNormalized,
        count: todayCount,
        isEmpty: false,
      );
    });

    debugPrint('🔍🔍🔍 ===== INVESTIGATION COMPLETE ===== 🔍🔍🔍');
    debugPrint('');
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

    // 選択された年の1月1日を含む週の日曜日を計算（GitHubのように前年と繋がる）
    final yearStart = DateTime(_selectedYear, 1, 1);
    final yearStartWeekday = yearStart.weekday;
    // 1月1日を含む週の日曜日を取得
    final weekStartSunday = yearStartWeekday == 7
        ? yearStart
        : yearStart.subtract(Duration(days: yearStartWeekday));
    
    // 表示開始日は週の日曜日（前年にある場合も含む）
    final displayStartDate = weekStartSunday;
    
    // 今日の終わり（23:59:59）まで含める
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final yearEnd = DateTime(_selectedYear, 12, 31, 23, 59, 59);
    final endDate = yearEnd.isAfter(todayEnd) ? todayEnd : yearEnd;

    // 選択された年の範囲（表示用のフィルタリング）
    final selectedYearStart = DateTime(_selectedYear, 1, 1);
    final selectedYearEnd = DateTime(_selectedYear, 12, 31);

    final weeks = _generateWeeks(
      displayStartDate,
      endDate,
      contributionMap,
      selectedYearStart,
      selectedYearEnd,
    );
    final availableYears = List.generate(6, (i) => today.year - i);

    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize = widget.cellSize;

        if (!_hasScrolled) {
          _scrollToEnd();
        }

        final total = widget.contributions
            .where((c) => c.date.year == _selectedYear)
            .fold<int>(0, (sum, c) => sum + c.count);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  // 年選択ボタン
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: AppColors.textColor(brightness),
                        ),
                        onPressed: _selectedYear > availableYears.last
                            ? () {
                                setState(() {
                                  _selectedYear--;
                                  _hasScrolled = false;
                                });
                                widget.onYearChanged?.call(_selectedYear);
                                _scrollToEnd();
                              }
                            : null,
                      ),
                      Text(
                        '$_selectedYear年',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor(brightness),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: AppColors.textColor(brightness),
                        ),
                        onPressed: _selectedYear < availableYears.first
                            ? () {
                      setState(() {
                                  _selectedYear++;
                                  _hasScrolled = false;
                      });
                                widget.onYearChanged?.call(_selectedYear);
                      _scrollToEnd();
                    }
                            : null,
                      ),
                    ],
                ),
              ],
            ),
            const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
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

              // 凡例
              const SizedBox(height: 16),
              _buildLegend(brightness),

              // 選択された日付の詳細表示
              if (_selectedCell != null && !_selectedCell!.isEmpty) ...[
                const SizedBox(height: 24),
                ContributionDetailContent(
                  date: _selectedCell!.date,
                  count: _selectedCell!.count,
                  onPreviousDay: _canMoveToPreviousDay()
                      ? () => _moveToDay(_selectedCell!.date.subtract(const Duration(days: 1)))
                      : null,
                  onNextDay: _canMoveToNextDay()
                      ? () => _moveToDay(_selectedCell!.date.add(const Duration(days: 1)))
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }

  /// 前の日に移動可能かチェック
  bool _canMoveToPreviousDay() {
    if (_selectedCell == null) return false;
    final yearStart = DateTime(_selectedYear, 1, 1);
    final previousDay = _selectedCell!.date.subtract(const Duration(days: 1));
    return !previousDay.isBefore(yearStart);
  }

  /// 次の日に移動可能かチェック
  bool _canMoveToNextDay() {
    if (_selectedCell == null) return false;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final nextDay = _selectedCell!.date.add(const Duration(days: 1));
    return !nextDay.isAfter(todayNormalized) && nextDay.year == _selectedYear;
  }

  /// 指定した日付に移動
  void _moveToDay(DateTime date) {
    final dateNormalized = DateTime(date.year, date.month, date.day);
    
    // その日のContribution数を取得
    int count = 0;
    for (final c in widget.contributions) {
      final cDate = DateTime(c.date.year, c.date.month, c.date.day);
      if (cDate == dateNormalized) {
        count = c.count;
        break;
      }
    }

    setState(() {
      _selectedCell = CalendarCell(
        date: dateNormalized,
        count: count,
        isEmpty: false,
      );
    });
  }

  /// 凡例を構築
  Widget _buildLegend(Brightness brightness) {
    final textColor = AppColors.textColor(brightness);
    return Row(
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final count = index * 5;
          final color = _getLegendColor(count, brightness);
          return Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
      child: Container(
              width: 11,
              height: 11,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// 凡例用の色を取得
  Color _getLegendColor(int count, Brightness brightness) {
    if (brightness == Brightness.dark) {
      if (count == 0) {
        return AppColors.githubDarkBorder.withValues(alpha: 0.3);
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
        return const Color(0xFF9BE9A8);
      } else if (count <= 9) {
        return const Color(0xFF40C463);
      } else if (count <= 19) {
        return const Color(0xFF30A14E);
      } else {
        return const Color(0xFF216E39);
      }
    }
  }

  Widget _buildCell(CalendarCell cell, double size, Brightness brightness) {
    // 空のセルの場合はタップ不可
    if (cell.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getColor(cell.count, brightness),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    final isTapped = _tappedCell?.date == cell.date;

    return Tooltip(
      message: cell.count > 0
          ? '${cell.date.year}/${cell.date.month}/${cell.date.day}: ${cell.count} contributions'
          : '${cell.date.year}/${cell.date.month}/${cell.date.day}: No contributions',
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween<double>(begin: 1.0, end: isTapped ? 0.85 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _tappedCell = cell;
                });
              },
              onTap: () {
                debugPrint(
                  '📅 Tapped: ${cell.date} - ${cell.count} contributions',
                );
                // アニメーションをリセット
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) {
                    setState(() {
                      _tappedCell = null;
                    });
                  }
                });
                // 選択されたセルを更新
                setState(() {
                  _selectedCell = cell;
                });
                // モーダルを表示
                _showContributionDetail(cell);
              },
              onTapCancel: () {
                setState(() {
                  _tappedCell = null;
                });
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _getColor(cell.count, brightness),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isTapped
                      ? [
                          BoxShadow(
                            color: _getColor(
                              cell.count,
                              brightness,
                            ).withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Contribution詳細を表示
  void _showContributionDetail(CalendarCell cell) {
    debugPrint(
      '🚀 Showing modal for: ${cell.date} - ${cell.count} contributions',
    );

    // デバッグ: 簡易ダイアログでテスト（問題を切り分けるため）
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Debug'),
    //     content: Text('Date: ${cell.date}\nCount: ${cell.count}'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: Text('Close'),
    //       ),
    //     ],
    //   ),
    // );

    try {
      ContributionDetailModal.show(context, date: cell.date, count: cell.count)
          .then((_) {
            debugPrint('✅ Modal closed');
          })
          .catchError((error) {
            debugPrint('❌ Error showing modal: $error');
          });
    } catch (e) {
      debugPrint('❌ Exception: $e');
    }
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
    DateTime selectedYearStart,
    DateTime selectedYearEnd,
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
        
        // 表示範囲内かチェック（前年の週も含む）
        final isInDisplayRange =
            date.isAfter(start.subtract(const Duration(days: 1))) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end));
        
        // 選択された年の範囲内かチェック
        final isInSelectedYear = date.isAfter(
              selectedYearStart.subtract(const Duration(days: 1)),
            ) &&
            (date.isBefore(selectedYearEnd) ||
                date.isAtSameMomentAs(selectedYearEnd));

        // 選択された年の範囲外でも、データがあれば表示（前年の週を表示）
        final hasData = map.containsKey(date);
        final count = hasData ? (map[date] ?? 0) : 0;
        
        // isEmptyは選択された年の範囲外でデータがない場合のみtrue
        final isEmpty = !isInSelectedYear && !hasData;

        week.add(
          CalendarCell(
            date: date,
            count: isInDisplayRange ? count : 0,
            isEmpty: !isInDisplayRange || isEmpty,
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
