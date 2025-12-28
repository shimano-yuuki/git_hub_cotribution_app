import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// セクションのタイトルと説明を表示するウィジェット
class SectionTitle extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Color? textColor;
  final Color? iconColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultTextColor = textColor ?? AppColors.textColor(brightness);
    final defaultIconColor = iconColor ?? AppColors.iconColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: defaultIconColor, size: 24),
              const SizedBox(width: 16),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: defaultTextColor,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            style: TextStyle(fontSize: 12, color: defaultTextColor),
          ),
        ],
      ],
    );
  }
}
