import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);
    final iconColor = AppColors.iconColor(brightness);
    final backgroundColor = brightness == Brightness.dark
        ? AppColors.githubDarkSurface.withOpacity(0.9)
        : AppColors.white.withOpacity(0.95);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor(brightness),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              'プロフィール画面',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ユーザー情報を表示します',
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
