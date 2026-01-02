import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_remote_datasource.dart';
import '../datasources/github_local_datasource.dart';

/// GithubRepositoryの実装
class GithubRepositoryImpl implements GithubRepository {
  final GithubRemoteDataSource remoteDataSource;
  final GithubLocalDataSource localDataSource;

  GithubRepositoryImpl({
    GithubRemoteDataSource? remoteDataSource,
    GithubLocalDataSource? localDataSource,
  })  : remoteDataSource = remoteDataSource ?? GithubRemoteDataSource(),
        localDataSource = localDataSource ?? GithubLocalDataSource();

  @override
  Future<Either<Failure, User>> getAuthenticatedUser(String token) async {
    try {
      final user = await remoteDataSource.getAuthenticatedUser(token);
      return Right(user);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('認証に失敗') || errorMessage.contains('トークンが無効')) {
        return Left(AuthenticationFailure(errorMessage));
      } else if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続')) {
        return Left(NetworkFailure(errorMessage));
      } else {
        return Left(ServerFailure(errorMessage));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) async {
    try {
      final isValid = await remoteDataSource.validateToken(token);
      if (isValid) {
        return const Right(true);
      } else {
        return Left(const AuthenticationFailure('トークンが無効です'));
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('ネットワーク') || errorMessage.contains('接続')) {
        return Left(NetworkFailure(errorMessage));
      } else {
        return Left(ServerFailure(errorMessage));
      }
    }
  }

  @override
  Future<Either<Failure, List<Contribution>>> getContributions(
    String token,
    int year,
  ) async {
    try {
      // リモートからデータを取得
      final contributions = await remoteDataSource.getContributions(
        token,
        year,
      );
      
      // 成功したらキャッシュに保存
      await localDataSource.cacheContributions(year, contributions);
      
      return Right(contributions);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // ネットワークエラーの場合はキャッシュから取得を試みる
      if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続') ||
          errorMessage.contains('タイムアウト')) {
        try {
          final cachedContributions =
              await localDataSource.getCachedContributions(year);
          if (cachedContributions != null && cachedContributions.isNotEmpty) {
            // キャッシュがあればそれを返す（NetworkFailureとして返すが、キャッシュデータは利用可能）
            // ProfileScreen側でキャッシュを取得して表示する
            return Left(NetworkFailure(
              'オフラインです。キャッシュされたデータを表示しています。',
            ));
          }
        } catch (_) {
          // キャッシュ取得に失敗した場合はそのままエラーを返す
        }
        return Left(NetworkFailure(errorMessage));
      } else if (errorMessage.contains('認証に失敗') ||
          errorMessage.contains('トークンが無効')) {
        return Left(AuthenticationFailure(errorMessage));
      } else {
        return Left(ServerFailure(errorMessage));
      }
    }
  }

  /// キャッシュからContributionデータを取得
  Future<Either<Failure, List<Contribution>>> getCachedContributions(
    int year,
  ) async {
    try {
      final cachedContributions =
          await localDataSource.getCachedContributions(year);
      if (cachedContributions == null || cachedContributions.isEmpty) {
        return Left(const CacheFailure('キャッシュされたデータがありません'));
      }
      return Right(cachedContributions);
    } catch (e) {
      return Left(CacheFailure('キャッシュの取得に失敗しました: $e'));
    }
  }

  @override
  Future<DateTime?> getLastUpdated(int year) async {
    try {
      return await localDataSource.getLastUpdated(year);
    } catch (e) {
      return null;
    }
  }
}
