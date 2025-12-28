import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/github_repository.dart';

/// トークンの有効性を検証するUseCase
class ValidateTokenUseCase {
  final GithubRepository repository;

  ValidateTokenUseCase(this.repository);

  /// トークンの有効性を検証する
  /// 
  /// [token] GitHub Personal Access Token
  /// 
  /// Returns [Either<Failure, bool>] true if valid, false otherwise
  Future<Either<Failure, bool>> call(String token) async {
    if (token.isEmpty) {
      return Left(const AuthenticationFailure('トークンが入力されていません'));
    }
    return await repository.validateToken(token);
  }
}


