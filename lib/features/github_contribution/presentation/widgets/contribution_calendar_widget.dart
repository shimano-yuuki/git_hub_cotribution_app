import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import 'dart:math';

/// GitHub風のContributionカレンダーウィジェット
class ContributionCalendarWidget extends StatefulWidget {
  /// Contributionデータのリスト
  /// 各Contributionは日付とカウント数を持つ
  final List<Contribution> contributions;

  /// セルのサイズ（デフォルト: 18.0）
  final double cellSize;

  /// セル間のスペース（デフォルト: 3.0）
  final double cellSpacing;

  /// 初期年（デフォルト: 現在年）
  final int? initialYear;

  /// 年変更時のコールバック
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
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _monthLabelScrollController = ScrollController();
  late int _selectedYear;
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear ?? DateTime.now().year;
    // カレンダーグリッドのスクロールを監視して月ラベルに同期
    _calendarScrollController.addListener(() {
      if (_monthLabelScrollController.hasClients) {
        _monthLabelScrollController.jumpTo(_calendarScrollController.offset);
      }
    });
  }

  /// カレンダーを右端（今日の日付）にスクロール
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarScrollController.hasClients &&
          _monthLabelScrollController.hasClients) {
        final maxScrollExtent =
            _calendarScrollController.position.maxScrollExtent;
        _calendarScrollController.jumpTo(maxScrollExtent);
        _monthLabelScrollController.jumpTo(maxScrollExtent);
        _hasScrolledToEnd = true;
      }
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    _monthLabelScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Contributionデータをマップに変換（日付をキーとして高速検索）
    final contributionMap = <DateTime, int>{};
    for (final contribution in widget.contributions) {
      final date = DateTime(
        contribution.date.year,
        contribution.date.month,
        contribution.date.day,
      );
      contributionMap[date] = contribution.count;
    }

    // 選択された年のデータを生成
    final yearStart = DateTime(_selectedYear, 1, 1);
    final yearEnd = DateTime(_selectedYear, 12, 31);
    final today = DateTime.now();
    final endDate = yearEnd.isAfter(today) ? today : yearEnd;
    final startDate = yearStart;

    // カレンダーデータを生成（週ごとにグループ化）
    final weeks = _generateWeeks(startDate, endDate, contributionMap);

    // 月ラベルの位置を計算
    final monthLabels = _calculateMonthLabels(weeks, startDate);

    // 利用可能な年のリストを生成（現在年から5年前まで）
    final availableYears = List.generate(6, (index) => today.year - index);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面サイズに応じてセルサイズを調整
        final availableWidth = max(
          0,
          constraints.maxWidth.isFinite
              ? constraints.maxWidth - 40
              : double.infinity,
        ); // 週ラベルとマージンのスペース
        final availableHeight = max(
          0,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight - 120
              : double.infinity,
        ); // 年選択、月ラベルとマージンのスペース

        // セルサイズを計算（より適切な計算方法）
        double adjustedCellSize = widget.cellSize;
        if (availableWidth > 0 && availableHeight > 0 && weeks.isNotEmpty) {
          final widthPerCell =
              availableWidth /
              (weeks.length * (widget.cellSize + widget.cellSpacing));
          final heightPerCell =
              availableHeight / (7 * (widget.cellSize + widget.cellSpacing));
          adjustedCellSize = max(
            12.0, // 最小サイズを12.0に設定（見やすくするため）
            min(widget.cellSize, min(widthPerCell, heightPerCell)),
          );
        }

        // 実際の高さを計算
        final actualHeight = 7 * (adjustedCellSize + widget.cellSpacing);

        // 初回表示時または年変更時に右端にスクロール
        if (!_hasScrolledToEnd) {
          _scrollToEnd();
        }

        // 総Contribution数を計算
        final totalContributions = widget.contributions
            .where((c) => c.date.year == _selectedYear)
            .fold<int>(0, (sum, contribution) => sum + contribution.count);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 年選択とタイトル
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
                      '$totalContributions contributions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor(brightness).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                // 年選択ドロップダウン
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
                  onChanged: (int? newYear) {
                    if (newYear != null && newYear != _selectedYear) {
                      setState(() {
                        _selectedYear = newYear;
                        _hasScrolledToEnd = false;
                      });
                      // 年変更を親に通知
                      widget.onYearChanged?.call(newYear);
                      // 年変更後、右端にスクロール
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
            // 月ラベル（上部に横並び）
            Padding(
              padding: const EdgeInsets.only(
                left: 54,
              ), // 週ラベルのスペース(30) + カレンダーの左パディング(24)
              child: _buildMonthLabelsHorizontal(
                monthLabels,
                weeks,
                adjustedCellSize,
                brightness,
                _monthLabelScrollController,
              ),
            ),
            const SizedBox(height: 8),
            // カレンダー本体（草の部分だけをContainerで囲む）
            Container(
              padding: const EdgeInsets.all(24),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カレンダーグリッド（横スクロール可能）
                  Expanded(
                    child: SizedBox(
                      height: constraints.maxHeight.isFinite
                          ? min(actualHeight, constraints.maxHeight - 100)
                          : actualHeight,
                      child: _buildCalendarGrid(
                        weeks,
                        adjustedCellSize,
                        brightness,
                        actualHeight,
                        _calendarScrollController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 週ラベル（左側に縦並び、月、水、金のみ表示）を構築
  Widget _buildWeekLabelsVertical(double cellSize, Brightness brightness) {
    const weekLabels = ['', '月', '', '水', '', '金', ''];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (index) {
        return SizedBox(
          width: 30,
          height: cellSize + widget.cellSpacing,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                weekLabels[index],
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textColor(brightness).withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 月ラベルを構築（上部に横並び）
  Widget _buildMonthLabelsHorizontal(
    Map<int, String> monthLabels,
    List<List<CalendarCell>> weeks,
    double cellSize,
    Brightness brightness,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      child: Row(
        children: List.generate(weeks.length, (weekIndex) {
          final monthLabel = monthLabels[weekIndex];
          return SizedBox(
            width: cellSize + widget.cellSpacing,
            child: monthLabel != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      monthLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textColor(brightness).withOpacity(0.6),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }

  /// カレンダーグリッドを構築
  Widget _buildCalendarGrid(
    List<List<CalendarCell>> weeks,
    double cellSize,
    Brightness brightness,
    double height,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: SizedBox(
        height: height,
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
    );
  }

  /// 個別のセルを構築
  Widget _buildCell(CalendarCell cell, double cellSize, Brightness brightness) {
    final color = _getContributionColor(cell.count, brightness);

    return Tooltip(
      message: cell.count > 0
          ? '${cell.date.year}/${cell.date.month}/${cell.date.day}: ${cell.count} contributions'
          : '${cell.date.year}/${cell.date.month}/${cell.date.day}: No contributions',
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Contribution数に応じた色を取得
  Color _getContributionColor(int count, Brightness brightness) {
    if (brightness == Brightness.dark) {
      // ダークモード
      if (count == 0) {
        return Colors.grey; // グレー
      } else if (count >= 1 && count <= 3) {
        return const Color(0xFF0E4429);
      } else if (count >= 4 && count <= 9) {
        return const Color(0xFF006D32);
      } else if (count >= 10 && count <= 19) {
        return const Color(0xFF26A641);
      } else {
        return const Color(0xFF39D353);
      }
    } else {
      // ライトモード
      if (count == 0) {
        return Colors.grey; // グレー
      } else if (count >= 1 && count <= 3) {
        return const Color(0xFF9BE9A8);
      } else if (count >= 4 && count <= 9) {
        return const Color(0xFF40C463);
      } else if (count >= 10 && count <= 19) {
        return const Color(0xFF30A14E);
      } else {
        return const Color(0xFF216E39);
      }
    }
  }

  /// 週データを生成
  List<List<CalendarCell>> _generateWeeks(
    DateTime startDate,
    DateTime endDate,
    Map<DateTime, int> contributionMap,
  ) {
    final weeks = <List<CalendarCell>>[];

    // 開始日の前の日曜日を取得（週の開始）
    // DateTime.weekday: 1=月曜日, 7=日曜日
    // GitHubのカレンダーは日曜日から始まる
    final startWeekday = startDate.weekday;
    // 日曜日から始まる週を作るため、開始日が日曜日でない場合は前の日曜日まで戻る
    // weekday: 1(月)=1日前, 2(火)=2日前, ..., 6(土)=6日前, 7(日)=0日前
    final daysToSubtract = startWeekday == 7 ? 0 : startWeekday;
    var currentWeekStart = startDate.subtract(Duration(days: daysToSubtract));

    // 週の開始日が日曜日であることを確認（必要に応じて調整）
    // currentWeekStartが日曜日でない場合、前の日曜日まで戻る
    if (currentWeekStart.weekday != 7) {
      final adjustment = currentWeekStart.weekday;
      currentWeekStart = currentWeekStart.subtract(Duration(days: adjustment));
    }

    // 終了日を含む週の日曜日までループ
    while (currentWeekStart.isBefore(endDate) ||
        currentWeekStart.isAtSameMomentAs(endDate) ||
        currentWeekStart.add(const Duration(days: 6)).isBefore(endDate) ||
        currentWeekStart
            .add(const Duration(days: 6))
            .isAtSameMomentAs(endDate)) {
      final week = <CalendarCell>[];

      // 週の7日間を生成（日曜日から始まる）
      // i=0: 日曜日(weekday=7), i=1: 月曜日(weekday=1), ..., i=6: 土曜日(weekday=6)
      for (int i = 0; i < 7; i++) {
        final date = currentWeekStart.add(Duration(days: i));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final count = contributionMap[normalizedDate] ?? 0;

        // 選択された年の範囲内の日付かチェック
        if (normalizedDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            (normalizedDate.isBefore(endDate) ||
                normalizedDate.isAtSameMomentAs(endDate))) {
          week.add(CalendarCell(date: normalizedDate, count: count));
        } else {
          week.add(CalendarCell(date: normalizedDate, count: 0, isEmpty: true));
        }
      }

      weeks.add(week);

      // 次の週の開始日（次の日曜日）に移動
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));

      // 最後の週の日曜日が終了日を超えたら終了
      if (currentWeekStart.isAfter(endDate)) {
        break;
      }

      // 最大53週まで（GitHubの草カレンダーは通常53週まで）
      if (weeks.length >= 53) {
        break;
      }
    }

    return weeks;
  }

  /// 月ラベルの位置を計算
  Map<int, String> _calculateMonthLabels(
    List<List<CalendarCell>> weeks,
    DateTime startDate,
  ) {
    final monthLabels = <int, String>{};
    final monthNames = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];

    // 各月の1日が含まれる週のインデックスを計算
    final year = startDate.year;
    final endDate = DateTime.now();

    // 各月の1日をチェック
    for (int month = 1; month <= 12; month++) {
      final firstDayOfMonth = DateTime(year, month, 1);

      // 終了日を超えている場合はスキップ
      if (firstDayOfMonth.isAfter(endDate)) {
        break;
      }

      // 開始日より前の場合はスキップ
      if (firstDayOfMonth.isBefore(startDate)) {
        continue;
      }

      // 各月の1日が含まれる週のインデックスを探す
      for (int weekIndex = 0; weekIndex < weeks.length; weekIndex++) {
        final week = weeks[weekIndex];
        if (week.isEmpty) continue;

        // 週の中に月の1日が含まれているかチェック
        bool found = false;
        for (final cell in week) {
          // 月の1日が含まれているか、または週の最初の日（日曜日）が月の1日以降の場合
          if (cell.date.year == year &&
              cell.date.month == month &&
              cell.date.day == 1) {
            // 月の1日が見つかった場合、その週のインデックスから3を引いた位置に月ラベルを配置
            // 3マス左にずらす
            final labelIndex = weekIndex - 3;
            if (labelIndex >= 0) {
              monthLabels[labelIndex] = monthNames[month - 1];
            }
            found = true;
            break;
          }
        }
        if (found) break;
      }
    }

    return monthLabels;
  }
}

/// カレンダーセルのデータクラス
class CalendarCell {
  final DateTime date;
  final int count;
  final bool isEmpty;

  CalendarCell({required this.date, required this.count, this.isEmpty = false});
}
