import 'dart:async';
import 'dart:math';

/// リトライ設定
class RetryConfig {
  /// 最大リトライ回数
  final int maxRetries;

  /// 初回リトライまでの待機時間（ミリ秒）
  final Duration initialDelay;

  /// リトライ間隔の増加率（指数バックオフ）
  final double backoffMultiplier;

  /// 最大待機時間
  final Duration maxDelay;

  /// リトライ可能なエラーかどうかを判定する関数
  final bool Function(Object error) shouldRetry;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    bool Function(Object error)? shouldRetry,
  }) : shouldRetry = shouldRetry ?? _defaultShouldRetry;

  /// デフォルトのリトライ判定（ネットワークエラーのみリトライ）
  static bool _defaultShouldRetry(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('接続') ||
        errorString.contains('timeout') ||
        errorString.contains('タイムアウト');
  }
}

/// リトライハンドラー
class RetryHandler {
  /// リトライ設定を使用して関数を実行
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() action,
    RetryConfig? config,
  }) async {
    final retryConfig = config ?? const RetryConfig();
    int attempt = 0;
    Duration delay = retryConfig.initialDelay;

    while (attempt <= retryConfig.maxRetries) {
      try {
        return await action();
      } catch (error) {
        // 最後の試行またはリトライ不可能なエラーの場合はそのままスロー
        if (attempt >= retryConfig.maxRetries ||
            !retryConfig.shouldRetry(error)) {
          rethrow;
        }

        attempt++;
        // 指数バックオフで待機
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * retryConfig.backoffMultiplier).round(),
            retryConfig.maxDelay.inMilliseconds,
          ),
        );
      }
    }

    // ここには到達しないはずだが、念のため
    throw Exception('リトライが失敗しました');
  }

  /// リトライ可能かどうかを判定
  static bool canRetry(Object error, RetryConfig? config) {
    final retryConfig = config ?? const RetryConfig();
    return retryConfig.shouldRetry(error);
  }
}



