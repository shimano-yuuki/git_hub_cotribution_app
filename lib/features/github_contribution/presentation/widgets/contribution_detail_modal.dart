import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import 'contribution_detail_content.dart';

class ContributionDetailModal {
  static void show(
    BuildContext context, {
    required DateTime date,
    required int count,
    required Map<DateTime, int> contributionMap,
    required DateTime yearStart,
    required DateTime yearEnd,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContributionDetailModalContent(
        date: date,
        count: count,
        contributionMap: contributionMap,
        yearStart: yearStart,
        yearEnd: yearEnd,
      ),
    );
  }
}

class _ContributionDetailModalContent extends StatelessWidget {
  final DateTime date;
  final int count;
  final Map<DateTime, int> contributionMap;
  final DateTime yearStart;
  final DateTime yearEnd;

  const _ContributionDetailModalContent({
    required this.date,
    required this.count,
    required this.contributionMap,
    required this.yearStart,
    required this.yearEnd,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return FadeTransition(
              opacity: AlwaysStoppedAnimation(value),
              child: SlideTransition(
                position: AlwaysStoppedAnimation(
                  Offset(0, 1 - value),
                ),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                // ジオメトリック背景
                CustomPaint(
                  painter: _ModalGeometricPatternPainter(isDark: isDark),
                  size: Size.infinite,
                ),
                // ガラスモーフィズム効果
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                AppColors.githubDarkSurface.withValues(alpha: 0.85),
                                AppColors.githubDarkBg.withValues(alpha: 0.85),
                              ]
                            : [
                                AppColors.white.withValues(alpha: 0.85),
                                AppColors.githubLightBg.withValues(alpha: 0.85),
                              ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.githubDarkBorder
                              : AppColors.githubLightBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // ドラッグハンドル
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.githubDarkBorder
                                : AppColors.githubLightBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // コンテンツ
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            child: ContributionDetailContent(
                              date: date,
                              count: count,
                              contributionMap: contributionMap,
                              yearStart: yearStart,
                              yearEnd: yearEnd,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// モーダル用のジオメトリックパターンを描画するCustomPainter
class _ModalGeometricPatternPainter extends CustomPainter {
  final bool isDark;

  _ModalGeometricPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // グラデーション背景
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              AppColors.darkGrey.withValues(alpha: 0.3),
              AppColors.darkGreenBlack.withValues(alpha: 0.3),
              AppColors.darkGreen.withValues(alpha: 0.3),
            ]
          : [
              AppColors.grey(200).withValues(alpha: 0.2),
              AppColors.grey(100).withValues(alpha: 0.2),
            ],
      stops: const [0.0, 0.5, 1.0],
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
          ? AppColors.terminalGreen.withValues(alpha: 0.15)
          : AppColors.terminalGreen.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final spacing = 50.0;
    final diagonalLength = size.width + size.height;

    // 右斜め下方向の平行線
    for (double i = -diagonalLength; i < diagonalLength; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.577, size.height),
        linePaint,
      );
    }

    // 左斜め下方向の平行線
    final leftLinePaint = Paint()
      ..color = isDark
          ? AppColors.terminalGreen.withValues(alpha: 0.12)
          : AppColors.terminalGreen.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

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
          ? AppColors.terminalGreen.withValues(alpha: 0.20)
          : AppColors.terminalGreen.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final hexSize = 100.0;
    final hexRadius = hexSize / 2;
    final hexHeight = hexSize * math.sqrt(3) / 2; // 正六角形の高さ

    final cols = (size.width / hexSize).ceil() + 2;
    final rows = (size.height / hexHeight).ceil() + 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * hexSize + (row % 2 == 0 ? 0 : hexSize / 2);
        final y = row * hexHeight;
        final center = Offset(x, y);

        final vertices = <Offset>[];
        for (int i = 0; i < 6; i++) {
          final angle = (math.pi / 3) * i - math.pi / 6;
          final vertexX = center.dx + hexRadius * math.cos(angle);
          final vertexY = center.dy + hexRadius * math.sin(angle);
          vertices.add(Offset(vertexX, vertexY));
        }

        for (final vertex in vertices) {
          canvas.drawLine(center, vertex, asanohaPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ModalGeometricPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

