import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/github_repository.dart';

/// 指定されたユーザー情報を取得するUseCase
class GetUserUseCase {
  final GithubRepository repository;

  GetUserUseCase(this.repository);

  /// 指定されたユーザー情報を取得する
  ///
  /// [token] GitHub Personal Access Token
  /// [username] 取得するユーザー名
  ///
  /// Returns [Either<Failure, User>]
  Future<Either<Failure, User>> call(String token, String username) {
    return repository.getUser(token, username);
  }
}
