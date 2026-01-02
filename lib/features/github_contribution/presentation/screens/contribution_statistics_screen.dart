import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution_statistics.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/animated_fade_in.dart';
import '../../../../shared/widgets/geometric_background.dart';

/// Contribution統計情報を表示する画面
class ContributionStatisticsScreen extends StatelessWidget {
  final ContributionStatistics statistics;

  const ContributionStatisticsScreen({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);

    return Scaffold(
      extendBody: true,
      body: GeometricBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // ヘッダー
                AnimatedFadeIn(
                  delay: 100.0,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: textColor,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '統計情報',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 統計情報カード
                AnimatedFadeIn(
                  delay: 150.0,
                  child: _buildStatCard(
                    context: context,
                    title: '総Contribution数',
                    value: _formatNumber(statistics.totalContributions),
                    icon: Icons.auto_awesome,
                    delay: 0.0,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedFadeIn(
                  delay: 200.0,
                  child: _buildStatCard(
                    context: context,
                    title: '現在のストリーク',
                    value: '${statistics.currentStreak}日',
                    icon: Icons.local_fire_department,
                    delay: 0.0,
                    highlight: true,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedFadeIn(
                  delay: 250.0,
                  child: _buildStatCard(
                    context: context,
                    title: '最長ストリーク',
                    value: '${statistics.longestStreak}日',
                    icon: Icons.emoji_events,
                    delay: 0.0,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedFadeIn(
                  delay: 300.0,
                  child: _buildStatCard(
                    context: context,
                    title: '今年のContribution数',
                    value: _formatNumber(statistics.thisYearContributions),
                    icon: Icons.calendar_today,
                    delay: 0.0,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedFadeIn(
                  delay: 350.0,
                  child: _buildStatCard(
                    context: context,
                    title: '今週のContribution数',
                    value: _formatNumber(statistics.thisWeekContributions),
                    icon: Icons.view_week,
                    delay: 0.0,
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 統計情報カードを構築
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required double delay,
    bool highlight = false,
  }) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // アイコン
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.terminalGreen.withValues(alpha: 0.2)
                  : textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: highlight
                  ? AppColors.terminalGreen
                  : textColor.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // タイトルと値
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: highlight
                        ? AppColors.terminalGreen
                        : textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 数値をフォーマット（3桁区切り）
  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final thousands = number / 1000;
      return '${thousands.toStringAsFixed(thousands % 1 == 0 ? 0 : 1)}K';
    } else {
      final millions = number / 1000000;
      return '${millions.toStringAsFixed(millions % 1 == 0 ? 0 : 1)}M';
    }
  }
}

