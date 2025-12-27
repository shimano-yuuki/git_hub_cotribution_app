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
    final navigationController = useMemoized(
      () => CircularBottomNavigationController(0),
    );

    useEffect(() {
      return () {
        navigationController.dispose();
      };
    }, []);

    final tabItems = [
      TabItem(
        Icons.person,
        "Contribution",
        AppColors.darkGreenBlack,
        circleStrokeColor: AppColors.darkGreenBlack,
        labelStyle: const TextStyle(color: AppColors.white),
      ),
      TabItem(
        Icons.settings,
        "Settings",
        AppColors.darkGreenBlack,
        circleStrokeColor: AppColors.darkGreenBlack,
        labelStyle: const TextStyle(color: AppColors.white),
      ),
    ];

    final screens = [const ProfileScreen(), const SettingsScreen()];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('GitHub Contribution App')),
      body: GeometricBackground(child: screens[selectedPos.value]),
      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: navigationController,
        selectedPos: selectedPos.value,
        barHeight: 80.0,
        barBackgroundColor: AppColors.darkGrey,
        selectedIconColor: AppColors.white,
        normalIconColor: AppColors.grey(400),
        animationDuration: const Duration(milliseconds: 300),
        selectedCallback: (int? selectedPosValue) {
          selectedPos.value = selectedPosValue ?? 0;
          navigationController.value = selectedPos.value;
        },
      ),
    );
  }
}
