import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution.dart';
import '../repositories/github_repository.dart';

/// Contributionデータを取得するUseCase
class GetContributionsUseCase {
  final GithubRepository repository;

  GetContributionsUseCase(this.repository);

  /// Contributionデータを取得する
  ///
  /// [token] GitHub Personal Access Token
  /// [year] 取得する年
  ///
  /// Returns [Either<Failure, List<Contribution>>]
  Future<Either<Failure, List<Contribution>>> call(String token, int year) {
    return repository.getContributions(token, year);
  }
}
