import 'failures.dart';

/// エラーログを記録するクラス
class ErrorLogger {
  static final ErrorLogger _instance = ErrorLogger._internal();
  factory ErrorLogger() => _instance;
  ErrorLogger._internal();

  /// エラーログのリスト（メモリ内に保持）
  final List<ErrorLogEntry> _logs = [];

  /// 最大保持ログ数
  static const int maxLogs = 100;

  /// エラーを記録
  void logError({
    required Failure failure,
    String? context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final entry = ErrorLogEntry(
      failure: failure,
      context: context,
      stackTrace: stackTrace,
      additionalData: additionalData,
      timestamp: DateTime.now(),
    );

    _logs.add(entry);

    // 最大保持数を超えた場合は古いログを削除
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    // デバッグモードではコンソールにも出力
    // ignore: avoid_print
    print('ERROR LOG: ${entry.toString()}');
  }

  /// エラーログを取得
  List<ErrorLogEntry> getLogs({int? limit}) {
    if (limit != null && limit > 0) {
      return _logs.reversed.take(limit).toList();
    }
    return List.unmodifiable(_logs.reversed);
  }

  /// エラーログをクリア
  void clearLogs() {
    _logs.clear();
  }

  /// 特定のタイプのエラーログを取得
  List<ErrorLogEntry> getLogsByType(Type failureType) {
    return _logs
        .where((entry) => entry.failure.runtimeType == failureType)
        .toList()
        .reversed
        .toList();
  }
}

/// エラーログエントリ
class ErrorLogEntry {
  final Failure failure;
  final String? context;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  ErrorLogEntry({
    required this.failure,
    this.context,
    this.stackTrace,
    this.additionalData,
    required this.timestamp,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');
    buffer.writeln('Failure Type: ${failure.runtimeType}');
    buffer.writeln('Message: ${failure.message}');
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    if (additionalData != null && additionalData!.isNotEmpty) {
      buffer.writeln('Additional Data: $additionalData');
    }
    if (stackTrace != null) {
      buffer.writeln('Stack Trace: $stackTrace');
    }
    return buffer.toString();
  }
}

