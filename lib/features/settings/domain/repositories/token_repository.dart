import '../entities/token.dart';

/// Token保存・取得のリポジトリインターフェース
abstract class TokenRepository {
  /// トークンを保存する
  Future<void> saveToken(Token token);

  /// トークンを取得する
  Future<Token?> getToken();

  /// トークンを削除する
  Future<void> deleteToken();
}
