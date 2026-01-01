import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Contribution詳細コンテンツ（モーダルとカレンダー下部で共有）
class ContributionDetailContent extends StatelessWidget {
  final DateTime date;
  final int count;
  final bool showCloseButton;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;

  const ContributionDetailContent({
    super.key,
    required this.date,
    required this.count,
    this.showCloseButton = false,
    this.onPreviousDay,
    this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付ヘッダーと前後ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDateNavigationButton(
                icon: Icons.chevron_left,
                onPressed: onPreviousDay,
                brightness: brightness,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(brightness),
                    ),
                  ),
                ),
              ),
              _buildDateNavigationButton(
                icon: Icons.chevron_right,
                onPressed: onNextDay,
                brightness: brightness,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contribution数の表示
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.githubDarkBorder.withValues(alpha: 0.2),
                        AppColors.githubDarkBorder.withValues(alpha: 0.1),
                      ]
                    : [
                        AppColors.githubLightBorder.withValues(alpha: 0.15),
                        AppColors.githubLightBorder.withValues(alpha: 0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor(brightness).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getContributionColor(count, brightness),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.code,
                      size: 28,
                      color: _getIconColor(count, brightness),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contributions',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor(
                            brightness,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(brightness),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getContributionLevelText(count),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getContributionColor(count, brightness),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 統計情報
          Text(
            '活動レベル',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(brightness).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityBar(count, brightness),
          const SizedBox(height: 16),

          // 閉じるボタン（モーダルのみ）
          if (showCloseButton)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.githubGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '閉じる',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 ($weekday)';
  }

  /// Contributionレベルに応じた色を取得
  Color _getContributionColor(int count, Brightness brightness) {
    if (brightness == Brightness.dark) {
      if (count == 0) return AppColors.githubDarkBorder.withValues(alpha: 0.4);
      if (count <= 3) return const Color(0xFF0E4429);
      if (count <= 9) return const Color(0xFF006D32);
      if (count <= 19) return const Color(0xFF26A641);
      return const Color(0xFF39D353);
    } else {
      if (count == 0) return AppColors.githubDarkBorder.withValues(alpha: 0.4);
      if (count <= 3) return const Color(0xFF9BE9A8);
      if (count <= 9) return const Color(0xFF40C463);
      if (count <= 19) return const Color(0xFF30A14E);
      return const Color(0xFF216E39);
    }
  }

  /// アイコンの色を取得
  Color _getIconColor(int count, Brightness brightness) {
    if (count == 0) {
      return AppColors.textColor(brightness).withValues(alpha: 0.3);
    }
    return Colors.white;
  }

  /// Contributionレベルのテキストを取得
  String _getContributionLevelText(int count) {
    if (count == 0) return 'アクティビティなし';
    if (count <= 3) return '少しアクティブ';
    if (count <= 9) return 'やや活発';
    if (count <= 19) return '活発';
    return '非常に活発';
  }

  /// 活動レベルバーを構築
  Widget _buildActivityBar(int contributionCount, Brightness brightness) {
    final levels = [
      {'label': '低', 'min': 0, 'max': 3},
      {'label': '中', 'min': 4, 'max': 9},
      {'label': '高', 'min': 10, 'max': 19},
      {'label': '最高', 'min': 20, 'max': 999},
    ];

    int activeIndex = 0;
    for (int i = 0; i < levels.length; i++) {
      final min = levels[i]['min'] as int;
      final max = levels[i]['max'] as int;
      if (contributionCount >= min && contributionCount <= max) {
        activeIndex = i;
        break;
      }
    }

    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= activeIndex && contributionCount > 0;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
            child: Column(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _getContributionColor(
                            levels[index]['max'] as int,
                            brightness,
                          )
                        : AppColors.githubDarkBorder.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  levels[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive
                        ? AppColors.textColor(brightness)
                        : AppColors.textColor(
                            brightness,
                          ).withValues(alpha: 0.4),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// 日付ナビゲーションボタンを構築
  Widget _buildDateNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.githubDarkBorder.withValues(alpha: 0.1)
                : AppColors.githubLightBorder.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? AppColors.borderColor(brightness).withValues(alpha: 0.3)
                  : AppColors.borderColor(brightness).withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.1 : 0.05,
                      ),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 24,
            color: isEnabled
                ? AppColors.textColor(brightness)
                : AppColors.textColor(brightness).withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
