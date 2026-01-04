import '../entities/token.dart';
import '../repositories/token_repository.dart';

/// トークンを保存するUseCase
class SaveTokenUseCase {
  final TokenRepository repository;

  SaveTokenUseCase(this.repository);

  /// トークンを保存する
  /// 
  /// [token] 保存するトークン
  /// 
  /// Throws [Exception] if token is invalid
  Future<void> call(Token token) async {
    if (!token.isValid) {
      throw Exception('トークンが無効です。20文字以上の文字列を入力してください。');
    }
    await repository.saveToken(token);
  }
}








