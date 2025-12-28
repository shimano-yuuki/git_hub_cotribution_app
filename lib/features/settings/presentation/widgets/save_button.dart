import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terminalGreen,
        foregroundColor: AppColors.githubDarkBg,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.githubDarkBg,
                ),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.githubDarkBg,
              ),
            ),
    );
  }
}

