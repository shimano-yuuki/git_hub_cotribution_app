import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_logger.dart';
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
  }) : remoteDataSource = remoteDataSource ?? GithubRemoteDataSource(),
       localDataSource = localDataSource ?? GithubLocalDataSource();

  @override
  Future<Either<Failure, User>> getAuthenticatedUser(String token) async {
    try {
      final user = await remoteDataSource.getAuthenticatedUser(token);
      return Right(user);
    } catch (e, stackTrace) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Failure failure;

      if (errorMessage.contains('認証に失敗') || errorMessage.contains('トークンが無効')) {
        failure = AuthenticationFailure(
          '認証に失敗しました。GitHubのアクセストークンが無効または期限切れの可能性があります。設定画面でトークンを確認してください。',
        );
      } else if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続')) {
        failure = NetworkFailure('ネットワーク接続エラーが発生しました。インターネット接続を確認してください。');
      } else {
        failure = ServerFailure('サーバーエラーが発生しました。しばらく時間をおいてから再度お試しください。');
      }

      // エラーログを記録
      ErrorLogger().logError(
        failure: failure,
        context: 'getAuthenticatedUser',
        stackTrace: stackTrace,
        additionalData: {'error': errorMessage},
      );

      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) async {
    try {
      final isValid = await remoteDataSource.validateToken(token);
      if (isValid) {
        return const Right(true);
      } else {
        final failure = const AuthenticationFailure(
          'トークンが無効です。GitHubのアクセストークンを確認してください。',
        );
        ErrorLogger().logError(failure: failure, context: 'validateToken');
        return Left(failure);
      }
    } catch (e, stackTrace) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Failure failure;

      if (errorMessage.contains('ネットワーク') || errorMessage.contains('接続')) {
        failure = NetworkFailure('ネットワーク接続エラーが発生しました。インターネット接続を確認してください。');
      } else {
        failure = ServerFailure('サーバーエラーが発生しました。しばらく時間をおいてから再度お試しください。');
      }

      ErrorLogger().logError(
        failure: failure,
        context: 'validateToken',
        stackTrace: stackTrace,
        additionalData: {'error': errorMessage},
      );

      return Left(failure);
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
    } catch (e, stackTrace) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // ネットワークエラーの場合はキャッシュから取得を試みる
      if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続') ||
          errorMessage.contains('タイムアウト')) {
        try {
          final cachedContributions = await localDataSource
              .getCachedContributions(year);
          if (cachedContributions != null && cachedContributions.isNotEmpty) {
            // キャッシュがあればそれを返す（NetworkFailureとして返すが、キャッシュデータは利用可能）
            // ProfileScreen側でキャッシュを取得して表示する
            final failure = NetworkFailure(
              'ネットワーク接続エラーが発生しました。キャッシュされたデータを表示しています。インターネット接続を確認して、更新ボタンを押してください。',
            );
            ErrorLogger().logError(
              failure: failure,
              context: 'getContributions',
              stackTrace: stackTrace,
              additionalData: {
                'error': errorMessage,
                'year': year,
                'usingCache': true,
              },
            );
            return Left(failure);
          }
        } catch (_) {
          // キャッシュ取得に失敗した場合はそのままエラーを返す
        }
        final failure = NetworkFailure(
          'ネットワーク接続エラーが発生しました。インターネット接続を確認してください。',
        );
        ErrorLogger().logError(
          failure: failure,
          context: 'getContributions',
          stackTrace: stackTrace,
          additionalData: {'error': errorMessage, 'year': year},
        );
        return Left(failure);
      } else if (errorMessage.contains('認証に失敗') ||
          errorMessage.contains('トークンが無効')) {
        final failure = AuthenticationFailure(
          '認証に失敗しました。GitHubのアクセストークンが無効または期限切れの可能性があります。設定画面でトークンを確認してください。',
        );
        ErrorLogger().logError(
          failure: failure,
          context: 'getContributions',
          stackTrace: stackTrace,
          additionalData: {'error': errorMessage, 'year': year},
        );
        return Left(failure);
      } else {
        final failure = ServerFailure(
          'Contributionデータの取得に失敗しました。しばらく時間をおいてから再度お試しください。',
        );
        ErrorLogger().logError(
          failure: failure,
          context: 'getContributions',
          stackTrace: stackTrace,
          additionalData: {'error': errorMessage, 'year': year},
        );
        return Left(failure);
      }
    }
  }

  /// キャッシュからContributionデータを取得
  @override
  Future<Either<Failure, List<Contribution>>> getCachedContributions(
    int year,
  ) async {
    try {
      final cachedContributions = await localDataSource.getCachedContributions(
        year,
      );
      if (cachedContributions == null || cachedContributions.isEmpty) {
        final failure = const CacheFailure(
          'キャッシュされたデータがありません。ネットワーク接続を確認して、データを取得してください。',
        );
        ErrorLogger().logError(
          failure: failure,
          context: 'getCachedContributions',
          additionalData: {'year': year},
        );
        return Left(failure);
      }
      return Right(cachedContributions);
    } catch (e, stackTrace) {
      final failure = CacheFailure(
        'キャッシュの取得に失敗しました。アプリを再起動するか、ネットワーク接続を確認してデータを再取得してください。',
      );
      ErrorLogger().logError(
        failure: failure,
        context: 'getCachedContributions',
        stackTrace: stackTrace,
        additionalData: {'error': e.toString(), 'year': year},
      );
      return Left(failure);
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

  @override
  Future<Either<Failure, User>> getUser(String token, String username) async {
    try {
      final user = await remoteDataSource.getUser(token, username);
      return Right(user);
    } catch (e, stackTrace) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Failure failure;

      if (errorMessage.contains('ユーザーが見つかりません')) {
        failure = CacheFailure('ユーザーが見つかりませんでした。ユーザー名を確認してください。');
      } else if (errorMessage.contains('認証に失敗') ||
          errorMessage.contains('トークンが無効')) {
        failure = AuthenticationFailure(
          '認証に失敗しました。GitHubのアクセストークンが無効または期限切れの可能性があります。設定画面でトークンを確認してください。',
        );
      } else if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続')) {
        failure = NetworkFailure('ネットワーク接続エラーが発生しました。インターネット接続を確認してください。');
      } else {
        failure = ServerFailure('サーバーエラーが発生しました。しばらく時間をおいてから再度お試しください。');
      }

      ErrorLogger().logError(
        failure: failure,
        context: 'getUser',
        stackTrace: stackTrace,
        additionalData: {'error': errorMessage, 'username': username},
      );

      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Contribution>>> getUserContributions(
    String token,
    String username,
    int year,
  ) async {
    try {
      final contributions = await remoteDataSource.getUserContributions(
        token,
        username,
        year,
      );
      return Right(contributions);
    } catch (e, stackTrace) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      Failure failure;

      if (errorMessage.contains('ユーザーが見つかりません')) {
        failure = CacheFailure('ユーザーが見つかりませんでした。ユーザー名を確認してください。');
      } else if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続') ||
          errorMessage.contains('タイムアウト')) {
        failure = NetworkFailure('ネットワーク接続エラーが発生しました。インターネット接続を確認してください。');
      } else if (errorMessage.contains('認証に失敗') ||
          errorMessage.contains('トークンが無効')) {
        failure = AuthenticationFailure(
          '認証に失敗しました。GitHubのアクセストークンが無効または期限切れの可能性があります。設定画面でトークンを確認してください。',
        );
      } else {
        failure = ServerFailure(
          'Contributionデータの取得に失敗しました。しばらく時間をおいてから再度お試しください。',
        );
      }

      ErrorLogger().logError(
        failure: failure,
        context: 'getUserContributions',
        stackTrace: stackTrace,
        additionalData: {
          'error': errorMessage,
          'username': username,
          'year': year,
        },
      );

      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowingUsers(String token) async {
    try {
      final users = await remoteDataSource.getFollowingUsers(token);
      return Right(users);
    } catch (e, stackTrace) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Failure failure;

      if (errorMessage.contains('認証に失敗') || errorMessage.contains('トークンが無効')) {
        failure = AuthenticationFailure(
          '認証に失敗しました。GitHubのアクセストークンが無効または期限切れの可能性があります。設定画面でトークンを確認してください。',
        );
      } else if (errorMessage.contains('ネットワーク') ||
          errorMessage.contains('接続')) {
        failure = NetworkFailure('ネットワーク接続エラーが発生しました。インターネット接続を確認してください。');
      } else {
        failure = ServerFailure(
          'フォロー中のユーザー一覧の取得に失敗しました。しばらく時間をおいてから再度お試しください。',
        );
      }

      ErrorLogger().logError(
        failure: failure,
        context: 'getFollowingUsers',
        stackTrace: stackTrace,
        additionalData: {'error': errorMessage},
      );

      return Left(failure);
    }
  }
}
