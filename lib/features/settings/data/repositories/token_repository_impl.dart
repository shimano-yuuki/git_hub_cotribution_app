import '../../domain/entities/token.dart';
import '../../domain/repositories/token_repository.dart';
import '../datasources/token_local_datasource.dart';

/// TokenRepositoryの実装
class TokenRepositoryImpl implements TokenRepository {
  final TokenLocalDataSource dataSource;

  TokenRepositoryImpl(this.dataSource);

  @override
  Future<void> saveToken(Token token) async {
    await dataSource.saveToken(token.value);
  }

  @override
  Future<Token?> getToken() async {
    final tokenValue = await dataSource.getToken();
    if (tokenValue == null) return null;
    return Token(tokenValue);
  }

  @override
  Future<void> deleteToken() async {
    await dataSource.deleteToken();
  }
}
