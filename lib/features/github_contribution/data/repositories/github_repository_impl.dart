import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_remote_datasource.dart';

/// GithubRepositoryの実装
class GithubRepositoryImpl implements GithubRepository {
  final GithubRemoteDataSource remoteDataSource;

  GithubRepositoryImpl({GithubRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? GithubRemoteDataSource();

  @override
  Future<Either<Failure, User>> getAuthenticatedUser(String token) async {
    try {
      final user = await remoteDataSource.getAuthenticatedUser(token);
      return Right(user);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (errorMessage.contains('認証に失敗') ||
          errorMessage.contains('トークンが無効')) {
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
      
      if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続')) {
        return Left(NetworkFailure(errorMessage));
      } else {
        return Left(ServerFailure(errorMessage));
      }
    }
  }
}

