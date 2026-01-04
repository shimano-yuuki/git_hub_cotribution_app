import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_animation.dart';

/// ローディング状態を含む保存ボタンウィジェット
class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = '保存',
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accentColor = AppColors.accentColor(brightness);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: brightness == Brightness.dark
            ? AppColors.githubDarkBg
            : AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: isLoading
          ? ThemedLoadingAnimation(
              size: 24.0,
              color: brightness == Brightness.dark
                  ? AppColors.githubDarkBg
                  : AppColors.white,
            )
          : Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: brightness == Brightness.dark
                    ? AppColors.githubDarkBg
                    : AppColors.white,
              ),
            ),
    );
  }
}
