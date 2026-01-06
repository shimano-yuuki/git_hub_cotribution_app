import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// シンプルな背景ウィジェット（単色背景と太い線・細い線を組み合わせたオシャレな斜め線パターン）
class GeometricBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const GeometricBackground({
    super.key,
    required this.child,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Stack(
      children: [
        CustomPaint(
          painter: _GeometricPatternPainter(animate: animate, isDark: isDark),
          size: Size.infinite,
        ),
        child,
      ],
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  final bool animate;
  final bool isDark;

  _GeometricPatternPainter({required this.animate, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // シンプルな単色背景（テーマに応じて変更）
    final backgroundColor = isDark
        ? Colors.black // 真っ黒
        : Colors.white; // 真っ白

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, paint);

    // シンプルな斜め線のみ（線の数を減らす）
    _drawSimpleLines(canvas, size);
  }

  /// 太い線と細い線を組み合わせたオシャレな斜め線パターン
  void _drawSimpleLines(Canvas canvas, Size size) {
    final diagonalLength = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    // 太い線の色（はっきりした緑）
    final thickLinePaint = Paint()
      ..color = isDark
          ? AppColors.terminalGreen.withValues(alpha: 0.55)
          : AppColors.githubGreen.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0; // 太い線

    // 細い線の色（少し控えめだがはっきりした緑）
    final thinLinePaint = Paint()
      ..color = isDark
          ? AppColors.terminalGreen.withValues(alpha: 0.40)
          : AppColors.githubGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5; // 細い線

    // 太い線の間隔（もっと広げて線を減らす）
    final thickSpacing = 250.0;
    // 細い線の間隔（太い線の間に数本入るように、間隔を広げる）
    final thinSpacing = 80.0;

    // 太い線を描画（右斜め下方向）
    for (double i = -diagonalLength; i < diagonalLength; i += thickSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.577, size.height), // tan(30°) ≈ 0.577
        thickLinePaint,
      );
    }

    // 細い線を描画（右斜め下方向、太い線の間を埋める）
    for (double i = -diagonalLength; i < diagonalLength; i += thinSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.577, size.height),
        thinLinePaint,
      );
    }

    // 細い線を左斜め下方向にも追加（間隔を広げて線を減らす）
    for (double i = -diagonalLength; i < diagonalLength; i += thinSpacing * 3) {
      canvas.drawLine(
        Offset(size.width + i, 0),
        Offset(size.width + i - size.height * 0.577, size.height),
        thinLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricPatternPainter oldDelegate) =>
      animate || oldDelegate.isDark != isDark;
}
