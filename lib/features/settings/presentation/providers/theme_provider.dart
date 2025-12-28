import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../domain/entities/theme_mode.dart';
import '../../domain/usecases/save_theme_mode_usecase.dart';
import '../../domain/usecases/get_theme_mode_usecase.dart';

/// テーマ管理用のHook
ThemeState useTheme({
  required SaveThemeModeUseCase saveThemeModeUseCase,
  required GetThemeModeUseCase getThemeModeUseCase,
  required BuildContext context,
}) {
  final currentThemeMode = useState<AppThemeMode>(AppThemeMode.system);
  final isLoading = useState<bool>(false);

  /// 初期化時に保存されているテーマモードを読み込む
  useEffect(() {
    Future.microtask(() async {
      isLoading.value = true;
      try {
        final savedThemeMode = await getThemeModeUseCase();
        currentThemeMode.value = savedThemeMode;
      } catch (e) {
        // エラー時はデフォルトのsystemを使用
        currentThemeMode.value = AppThemeMode.system;
      } finally {
        isLoading.value = false;
      }
    });
    return null;
  }, []);

  /// テーマモードを変更する
  Future<void> changeThemeMode(AppThemeMode themeMode) async {
    if (currentThemeMode.value == themeMode) return;

    isLoading.value = true;
    try {
      await saveThemeModeUseCase(themeMode);
      currentThemeMode.value = themeMode;
      // グローバルなテーマNotifierを更新
      themeNotifier.updateThemeMode(themeMode.toThemeMode());
    } catch (e) {
      // エラーハンドリング
    } finally {
      isLoading.value = false;
    }
  }

  return ThemeState(
    currentThemeMode: currentThemeMode.value,
    isLoading: isLoading.value,
    changeThemeMode: changeThemeMode,
  );
}

/// テーマの状態を保持するクラス
class ThemeState {
  final AppThemeMode currentThemeMode;
  final bool isLoading;
  final Future<void> Function(AppThemeMode) changeThemeMode;

  ThemeState({
    required this.currentThemeMode,
    required this.isLoading,
    required this.changeThemeMode,
  });
}

