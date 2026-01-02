import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../core/theme/app_colors.dart';

/// テーマカラーに応じたローディングアニメーション
/// progressiveDotsアニメーションを使用
class ThemedLoadingAnimation extends StatelessWidget {
  final double? size;
  final Color? color;

  const ThemedLoadingAnimation({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // カラーが指定されていない場合は、テーマに応じたカラーを使用
    final animationColor =
        color ??
        (brightness == Brightness.dark
            ? AppColors.terminalGreen
            : AppColors.terminalGreen);

    return LoadingAnimationWidget.progressiveDots(
      color: animationColor,
      size: size ?? 50.0,
    );
  }
}
