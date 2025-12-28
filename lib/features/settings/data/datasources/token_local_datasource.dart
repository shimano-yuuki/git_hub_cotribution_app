import 'package:shared_preferences/shared_preferences.dart';

/// ローカルストレージ（SharedPreferences）へのアクセスを管理するDataSource
class TokenLocalDataSource {
  static const String _tokenKey = 'github_personal_access_token';

  /// トークンを保存する
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// トークンを取得する
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// トークンを削除する
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
