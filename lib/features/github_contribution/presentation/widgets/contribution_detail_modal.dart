import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'contribution_detail_content.dart';

/// Contribution詳細を表示するモーダル
class ContributionDetailModal extends StatefulWidget {
  final DateTime date;
  final int count;

  const ContributionDetailModal({
    super.key,
    required this.date,
    required this.count,
  });

  /// モーダルを表示する
  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required int count,
  }) {
    debugPrint('🎯 ContributionDetailModal.show called');
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6), // 背景マスクを濃くする
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: false,
      builder: (context) {
        debugPrint('🏗️ Building modal widget');
        return ContributionDetailModal(date: date, count: count);
      },
    );
  }

  @override
  State<ContributionDetailModal> createState() =>
      _ContributionDetailModalState();
}

class _ContributionDetailModalState extends State<ContributionDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.55, // 画面の55%に調整（ボタンが確実に収まるように）
            minHeight: 300, // 最小高さを設定
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.githubDarkSurface.withValues(alpha: 0.95),
                            AppColors.githubDarkSurface.withValues(alpha: 0.9),
                          ]
                        : [
                            AppColors.white.withValues(alpha: 0.95),
                            AppColors.white.withValues(alpha: 0.9),
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.githubDarkBorder.withValues(alpha: 0.5)
                          : AppColors.githubLightBorder.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ドラッグハンドル
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textColor(
                                  brightness,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 共通コンテンツを使用
                          ContributionDetailContent(
                            date: widget.date,
                            count: widget.count,
                            showCloseButton: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
