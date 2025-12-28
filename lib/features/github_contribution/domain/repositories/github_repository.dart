import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

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
}

