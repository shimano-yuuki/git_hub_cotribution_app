import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/contribution.dart';

/// GitHub API操作のリポジトリインターフェース
abstract class GithubRepository {
  /// 認証されたユーザー情報を取得する
  ///
  /// [token] GitHub Personal Access Token
  ///
  /// Returns [Either<Failure, User>]
  Future<Either<Failure, User>> getAuthenticatedUser(String token);

  /// トークンの有効性を検証する
  ///
  /// [token] GitHub Personal Access Token
  ///
  /// Returns [Either<Failure, bool>] true if valid, false otherwise
  Future<Either<Failure, bool>> validateToken(String token);

  /// Contributionデータを取得する
  ///
  /// [token] GitHub Personal Access Token
  /// [year] 取得する年
  ///
  /// Returns [Either<Failure, List<Contribution>>]
  Future<Either<Failure, List<Contribution>>> getContributions(
    String token,
    int year,
  );

  /// 最終更新日時を取得する
  ///
  /// [year] 取得する年
  ///
  /// Returns [DateTime?] 最終更新日時（キャッシュがない場合はnull）
  Future<DateTime?> getLastUpdated(int year);

  /// キャッシュからContributionデータを取得する
  ///
  /// [year] 取得する年
  ///
  /// Returns [Either<Failure, List<Contribution>>]
  Future<Either<Failure, List<Contribution>>> getCachedContributions(int year);

  /// 指定されたユーザー情報を取得する
  ///
  /// [token] GitHub Personal Access Token
  /// [username] 取得するユーザー名
  ///
  /// Returns [Either<Failure, User>]
  Future<Either<Failure, User>> getUser(String token, String username);

  /// 指定されたユーザーのContributionデータを取得する
  ///
  /// [token] GitHub Personal Access Token
  /// [username] 取得するユーザー名
  /// [year] 取得する年
  ///
  /// Returns [Either<Failure, List<Contribution>>]
  Future<Either<Failure, List<Contribution>>> getUserContributions(
    String token,
    String username,
    int year,
  );

  /// フォロー中のユーザー一覧を取得する
  ///
  /// [token] GitHub Personal Access Token
  ///
  /// Returns [Either<Failure, List<User>>]
  Future<Either<Failure, List<User>>> getFollowingUsers(String token);
}
