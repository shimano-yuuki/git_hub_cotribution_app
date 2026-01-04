import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 緑と黒のグラデーションと網代麻の葉の模様の背景ウィジェット
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
    // グラデーション背景（テーマに応じて変更）
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              AppColors.darkGrey, // ダークグレー
              AppColors.darkGreenBlack, // 薄い緑がかったグレー
              AppColors.darkGreen, // 薄い緑
              AppColors.darkGrey, // ダークグレーに戻る
            ]
          : [
              AppColors.grey(200), // 明るいグレー
              Color.lerp(AppColors.grey(100), Colors.red, 0.1) ??
                  AppColors.grey(100), // 薄い赤がかったグレー
              Color.lerp(AppColors.grey(50), Colors.red, 0.15) ??
                  AppColors.grey(50), // より薄い赤がかった色
              AppColors.grey(200), // 明るいグレーに戻る
            ],
      stops: const [0.0, 0.4, 0.6, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 網代模様（斜めの平行線）
    _drawAjiroPattern(canvas, size);

    // 麻の葉模様（六角形の中心から放射状に線を引く）
    _drawAsanohaPattern(canvas, size);
  }

  /// 網代模様: 斜めの平行線を複数方向に重ねる
  void _drawAjiroPattern(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark
          ? AppColors.terminalGreen.withValues(alpha: 0.25)
          : AppColors.githubGreen.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final spacing = 40.0;
    final diagonalLength = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    // 右斜め下方向の平行線
    for (double i = -diagonalLength; i < diagonalLength; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.577, size.height), // tan(30°) ≈ 0.577
        linePaint,
      );
    }

    // 左斜め下方向の平行線
    final leftLinePaint = Paint()
      ..color = isDark
          ? AppColors.terminalGreen.withValues(alpha: 0.20)
          : AppColors.githubGreen.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (double i = -diagonalLength; i < diagonalLength; i += spacing) {
      canvas.drawLine(
        Offset(size.width + i, 0),
        Offset(size.width + i - size.height * 0.577, size.height),
        leftLinePaint,
      );
    }
  }

  /// 麻の葉模様: 六角形の中心から各頂点に向かって線を引く
  void _drawAsanohaPattern(Canvas canvas, Size size) {
    final asanohaPaint = Paint()
      ..color = isDark
          ? AppColors.terminalGreen.withValues(alpha: 0.30)
          : AppColors.githubGreen.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final hexSize = 80.0; // 六角形のサイズ
    final hexRadius = hexSize / 2;
    final hexHeight = hexSize * math.sqrt(3) / 2; // 正六角形の高さ

    // 六角形のグリッドを計算
    final cols = (size.width / hexSize).ceil() + 2;
    final rows = (size.height / hexHeight).ceil() + 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // 六角形の中心座標を計算（ハニカム構造）
        final x = col * hexSize + (row % 2 == 0 ? 0 : hexSize / 2);
        final y = row * hexHeight;
        final center = Offset(x, y);

        // 六角形の各頂点を計算
        final vertices = <Offset>[];
        for (int i = 0; i < 6; i++) {
          final angle = (math.pi / 3) * i - math.pi / 6; // 30度回転して上向きに
          final vertexX = center.dx + hexRadius * math.cos(angle);
          final vertexY = center.dy + hexRadius * math.sin(angle);
          vertices.add(Offset(vertexX, vertexY));
        }

        // 中心から各頂点に向かって線を引く（麻の葉模様）
        for (final vertex in vertices) {
          canvas.drawLine(center, vertex, asanohaPaint);
        }

        // 六角形の輪郭を描画
        final hexPath = Path();
        hexPath.moveTo(vertices[0].dx, vertices[0].dy);
        for (int i = 1; i < vertices.length; i++) {
          hexPath.lineTo(vertices[i].dx, vertices[i].dy);
        }
        hexPath.close();
        canvas.drawPath(hexPath, asanohaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricPatternPainter oldDelegate) =>
      animate || oldDelegate.isDark != isDark;
}
