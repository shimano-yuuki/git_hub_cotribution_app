import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// ガラスデザインのContainer
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.githubDarkBorder.withValues(alpha: 0.3)
              : AppColors.githubLightBorder.withValues(alpha: 0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.githubDarkSurface.withValues(alpha: 0.3),
                  AppColors.githubDarkSurface.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.white.withValues(alpha: 0.3),
                  AppColors.white.withValues(alpha: 0.1),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }
}
