import 'package:shared_preferences/shared_preferences.dart';

/// テーマ設定のローカルストレージアクセス
class ThemeLocalDataSource {
  static const String _themeModeKey = 'app_theme_mode';

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }
}


