import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class MainNavigation extends HookWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);

    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Contribution App')),
      body: TabBarView(
        controller: tabController,
        children: const [ProfileScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'プロフィール'),
              Tab(icon: Icon(Icons.settings), text: '設定'),
            ],
          ),
        ),
      ),
    );
  }
}
