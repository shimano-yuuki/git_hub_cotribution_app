import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../core/theme/app_colors.dart';
import 'geometric_background.dart';

class MainNavigation extends HookWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPos = useState(0);
    final isLoading = useState<bool>(false);
    final navigationController = useMemoized(
      () => CircularBottomNavigationController(0),
    );

    useEffect(() {
      return () {
        navigationController.dispose();
      };
    }, []);

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // テーマに応じた色を設定
    final barBackgroundColor = isDark
        ? AppColors.githubDarkSurface
        : AppColors.white;
    final selectedIconColor = AppColors.terminalGreen;
    final normalIconColor = isDark
        ? AppColors.githubUnselectedDark
        : AppColors.githubUnselectedLight;
    final circleColor = isDark ? AppColors.githubDarkSurface : AppColors.white;
    final labelColor = isDark
        ? AppColors.githubLightText
        : AppColors.githubDarkText;

    final tabItems = [
      TabItem(
        Icons.person,
        "Contribution",
        circleColor,
        circleStrokeColor: circleColor,
        labelStyle: TextStyle(color: labelColor),
      ),
      TabItem(
        Icons.settings,
        "Settings",
        circleColor,
        circleStrokeColor: circleColor,
        labelStyle: TextStyle(color: labelColor),
      ),
    ];

    final screens = [
      ProfileScreen(
        onLoadingChanged: (loading) {
          isLoading.value = loading;
        },
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: GeometricBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.1, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(selectedPos.value),
            child: screens[selectedPos.value],
          ),
        ),
      ),
      bottomNavigationBar: Opacity(
        opacity: isLoading.value ? 0.5 : 1.0,
        child: CircularBottomNavigation(
          tabItems,
          controller: navigationController,
          selectedPos: selectedPos.value,
          barHeight: 80.0,
          barBackgroundColor: barBackgroundColor,
          selectedIconColor: selectedIconColor,
          normalIconColor: normalIconColor,
          animationDuration: const Duration(milliseconds: 300),
          selectedCallback: (int? selectedPosValue) {
            selectedPos.value = selectedPosValue ?? 0;
            navigationController.value = selectedPos.value;
          },
        ),
      ),
    );
  }
}
