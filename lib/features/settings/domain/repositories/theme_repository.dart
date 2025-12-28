import '../entities/theme_mode.dart';

/// テーマ設定のリポジトリインターフェース
abstract class ThemeRepository {
  /// テーマモードを保存する
  Future<void> saveThemeMode(AppThemeMode themeMode);

  /// テーマモードを取得する
  Future<AppThemeMode> getThemeMode();
}
