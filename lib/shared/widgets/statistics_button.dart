import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/github_contribution/domain/entities/contribution_statistics.dart';
import 'animated_fade_in.dart';

/// 統計データ確認ボタン
class StatisticsButton extends StatelessWidget {
  final ContributionStatistics statistics;
  final int year;

  const StatisticsButton({
    super.key,
    required this.statistics,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accentColor = AppColors.accentColor(brightness);

    return AnimatedFadeIn(
      delay: 350.0,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.push(
              '/statistics',
              extra: {'statistics': statistics, 'year': year},
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 20),
              const SizedBox(width: 8),
              Text(
                '統計データを確認する',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
