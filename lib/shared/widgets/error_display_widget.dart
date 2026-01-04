import 'package:flutter/material.dart';
import '../../core/error/failures.dart';
import '../../core/theme/app_colors.dart';
import 'glass_container.dart';
import 'animated_fade_in.dart';

/// エラー情報
class ErrorInfo {
  final String title;
  final String message;
  final String actionMessage;
  final IconData icon;
  final Color color;
  final bool canRetry;

  const ErrorInfo({
    required this.title,
    required this.message,
    required this.actionMessage,
    required this.icon,
    required this.color,
    this.canRetry = true,
  });
}

/// エラータイプに応じた情報を取得
class ErrorInfoProvider {
  static ErrorInfo getErrorInfo(Failure failure, Brightness brightness) {
    if (failure is NetworkFailure) {
      return ErrorInfo(
        title: 'ネットワークエラー',
        message: failure.message,
        actionMessage: 'インターネット接続を確認して、もう一度お試しください。',
        icon: Icons.wifi_off,
        color: Colors.orange,
        canRetry: true,
      );
    } else if (failure is AuthenticationFailure) {
      return ErrorInfo(
        title: '認証エラー',
        message: failure.message,
        actionMessage: '設定画面でトークンを確認・更新してください。',
        icon: Icons.lock_outline,
        color: AppColors.githubErrorLight,
        canRetry: false,
      );
    } else if (failure is ServerFailure) {
      return ErrorInfo(
        title: 'サーバーエラー',
        message: failure.message,
        actionMessage: 'しばらく時間をおいてから、もう一度お試しください。',
        icon: Icons.error_outline,
        color: AppColors.githubErrorLight,
        canRetry: true,
      );
    } else if (failure is CacheFailure) {
      return ErrorInfo(
        title: 'データ取得エラー',
        message: failure.message,
        actionMessage: 'ネットワーク接続を確認して、データを再取得してください。',
        icon: Icons.storage_outlined,
        color: Colors.orange,
        canRetry: true,
      );
    } else {
      return ErrorInfo(
        title: 'エラーが発生しました',
        message: failure.message,
        actionMessage: 'もう一度お試しください。問題が続く場合は、アプリを再起動してください。',
        icon: Icons.warning_amber_rounded,
        color: AppColors.githubErrorLight,
        canRetry: true,
      );
    }
  }
}

/// エラーを表示するウィジェット（リトライ機能付き）
class ErrorDisplayWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final String? customTitle;
  final String? customMessage;
  final String? customActionMessage;
  final bool showRetryButton;

  const ErrorDisplayWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.customTitle,
    this.customMessage,
    this.customActionMessage,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);
    final errorInfo = ErrorInfoProvider.getErrorInfo(failure, brightness);

    final title = customTitle ?? errorInfo.title;
    final message = customMessage ?? errorInfo.message;
    final actionMessage = customActionMessage ?? errorInfo.actionMessage;
    final canRetry = errorInfo.canRetry && showRetryButton;

    return AnimatedFadeIn(
      delay: 0.0,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // エラーアイコンとタイトル
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorInfo.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    errorInfo.icon,
                    color: errorInfo.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: errorInfo.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // エラーメッセージ
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // アクション案内
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorInfo.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: errorInfo.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: errorInfo.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      actionMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // リトライボタン
            if (canRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('もう一度試す'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorInfo.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// コンパクトなエラー表示ウィジェット（インライン表示用）
class CompactErrorDisplayWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const CompactErrorDisplayWidget({
    super.key,
    required this.failure,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);
    final errorInfo = ErrorInfoProvider.getErrorInfo(failure, brightness);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorInfo.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            errorInfo.icon,
            size: 20,
            color: errorInfo.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorInfo.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: errorInfo.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorInfo.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (errorInfo.canRetry && onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                size: 20,
                color: errorInfo.color,
              ),
              tooltip: '再試行',
            ),
          ],
        ],
      ),
    );
  }
}



