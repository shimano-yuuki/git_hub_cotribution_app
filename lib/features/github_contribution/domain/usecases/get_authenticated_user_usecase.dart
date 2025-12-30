import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/github_repository.dart';

/// 認証されたユーザー情報を取得するUseCase
class GetAuthenticatedUserUseCase {
  final GithubRepository repository;

  GetAuthenticatedUserUseCase(this.repository);

  /// 認証されたユーザー情報を取得する
  ///
  /// [token] GitHub Personal Access Token
  ///
  /// Returns [Either<Failure, User>]
  Future<Either<Failure, User>> call(String token) async {
    if (token.isEmpty) {
      return Left(const AuthenticationFailure('トークンが入力されていません'));
    }
    return await repository.getAuthenticatedUser(token);
  }
}
