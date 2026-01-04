import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/settings/data/datasources/theme_local_datasource.dart';
import 'features/settings/data/repositories/theme_repository_impl.dart';
import 'features/settings/domain/repositories/theme_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final themeRepository =
      ThemeRepositoryImpl(ThemeLocalDataSource()) as ThemeRepository;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    // テーマ変更を監視
    themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _loadThemeMode() async {
    try {
      final savedThemeMode = await themeRepository.getThemeMode();
      themeNotifier.updateThemeMode(savedThemeMode.toThemeMode());
    } catch (e) {
      // エラー時はデフォルトのsystemを使用
      themeNotifier.updateThemeMode(ThemeMode.system);
    }
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          title: 'GitHub Contribution App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
