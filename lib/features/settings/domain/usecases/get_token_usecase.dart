import '../entities/token.dart';
import '../repositories/token_repository.dart';

/// トークンを取得するUseCase
class GetTokenUseCase {
  final TokenRepository repository;

  GetTokenUseCase(this.repository);

  /// 保存されているトークンを取得する
  /// 
  /// Returns [Token] if exists, null otherwise
  Future<Token?> call() async {
    return await repository.getToken();
  }
}




