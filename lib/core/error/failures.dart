abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// サーバーエラー
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// ネットワークエラー
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 認証エラー（無効なトークンなど）
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// キャッシュエラー
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
