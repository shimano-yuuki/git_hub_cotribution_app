import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'contribution_detail_content.dart';

/// Contribution詳細を表示するモーダル
class ContributionDetailModal extends StatefulWidget {
  final DateTime date;
  final int count;
  final Map<DateTime, int>? contributionMap;
  final DateTime? yearStart;
  final DateTime? yearEnd;

  const ContributionDetailModal({
    super.key,
    required this.date,
    required this.count,
    this.contributionMap,
    this.yearStart,
    this.yearEnd,
  });

  /// モーダルを表示する
  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required int count,
    Map<DateTime, int>? contributionMap,
    DateTime? yearStart,
    DateTime? yearEnd,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: false,
      builder: (context) {
        return ContributionDetailModal(
          date: date,
          count: count,
          contributionMap: contributionMap,
          yearStart: yearStart,
          yearEnd: yearEnd,
        );
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
  late DateTime _currentDate;
  late int _currentCount;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.date;
    _currentCount = widget.count;

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

  void _moveToDay(DateTime date) {
    final dateNormalized = DateTime(date.year, date.month, date.day);
    final count = widget.contributionMap?[dateNormalized] ?? 0;

    setState(() {
      _currentDate = dateNormalized;
      _currentCount = count;
    });
  }

  bool _canMoveToPreviousDay() {
    if (widget.yearStart == null) return false;
    final previousDay = _currentDate.subtract(const Duration(days: 1));
    return !previousDay.isBefore(widget.yearStart!);
  }

  bool _canMoveToNextDay() {
    if (widget.yearEnd == null) return false;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final nextDay = _currentDate.add(const Duration(days: 1));
    return !nextDay.isAfter(todayNormalized) &&
        nextDay.year == _currentDate.year;
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
          constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
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
                          date: _currentDate,
                          count: _currentCount,
                          showCloseButton: true,
                          onPreviousDay: _canMoveToPreviousDay()
                              ? () => _moveToDay(
                                  _currentDate.subtract(
                                    const Duration(days: 1),
                                  ),
                                )
                              : null,
                          onNextDay: _canMoveToNextDay()
                              ? () => _moveToDay(
                                  _currentDate.add(const Duration(days: 1)),
                                )
                              : null,
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
    );
  }
}
