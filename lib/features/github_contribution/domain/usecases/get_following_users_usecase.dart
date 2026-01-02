import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/github_repository.dart';

/// フォロー中のユーザー一覧を取得するUseCase
class GetFollowingUsersUseCase {
  final GithubRepository repository;

  GetFollowingUsersUseCase(this.repository);

  /// フォロー中のユーザー一覧を取得する
  ///
  /// [token] GitHub Personal Access Token
  ///
  /// Returns [Either<Failure, List<User>>]
  Future<Either<Failure, List<User>>> call(String token) async {
    return await repository.getFollowingUsers(token);
  }
}
