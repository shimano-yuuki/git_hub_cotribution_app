import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution.dart';
import '../repositories/github_repository.dart';

/// 指定されたユーザーのContributionデータを取得するUseCase
class GetUserContributionsUseCase {
  final GithubRepository repository;

  GetUserContributionsUseCase(this.repository);

  /// 指定されたユーザーのContributionデータを取得する
  ///
  /// [token] GitHub Personal Access Token
  /// [username] 取得するユーザー名
  /// [year] 取得する年
  ///
  /// Returns [Either<Failure, List<Contribution>>]
  Future<Either<Failure, List<Contribution>>> call(
    String token,
    String username,
    int year,
  ) {
    return repository.getUserContributions(token, username, year);
  }
}
