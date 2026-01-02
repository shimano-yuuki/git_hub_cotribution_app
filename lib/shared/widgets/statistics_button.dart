import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/github_contribution/domain/entities/contribution_statistics.dart';
import 'glass_container.dart';
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
    final textColor = AppColors.textColor(brightness);

    return AnimatedFadeIn(
      delay: 350.0,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.push(
                '/statistics',
                extra: {'statistics': statistics, 'year': year},
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '統計データを確認する',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
