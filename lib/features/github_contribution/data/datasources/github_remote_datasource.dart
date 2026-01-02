import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/contribution.dart';
import '../models/user_model.dart';

/// GitHub APIへのリモートアクセスを管理するDataSource
class GithubRemoteDataSource {
  static const String _baseUrl = 'https://api.github.com';

  final Dio _dio;

  GithubRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// 認証ヘッダーを設定
  void _setAuthHeader(String token) {
    _dio.options.headers['Authorization'] = 'token $token';
    _dio.options.headers['Accept'] = 'application/vnd.github.v3+json';
  }

  /// 認証されたユーザー情報を取得する
  Future<User> getAuthenticatedUser(String token) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.get('$_baseUrl/user');

      if (response.statusCode == 200) {
        return UserModel.fromJson(
          response.data as Map<String, dynamic>,
        ).toEntity();
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('認証に失敗しました。トークンが無効です。');
      } else if (e.response?.statusCode == 403) {
        throw Exception('アクセスが拒否されました。トークンの権限を確認してください。');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('接続がタイムアウトしました。ネットワーク接続を確認してください。');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('ネットワークエラーが発生しました。インターネット接続を確認してください。');
      } else {
        throw Exception('ユーザー情報の取得に失敗しました: ${e.message}');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  /// トークンの有効性を検証する
  Future<bool> validateToken(String token) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.get('$_baseUrl/user');
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false;
      }
      // ネットワークエラーなどはfalseを返す
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 指定されたユーザー情報を取得する
  Future<User> getUser(String token, String username) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.get('$_baseUrl/users/$username');

      if (response.statusCode == 200) {
        return UserModel.fromJson(
          response.data as Map<String, dynamic>,
        ).toEntity();
      } else if (response.statusCode == 404) {
        throw Exception('ユーザーが見つかりませんでした');
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('ユーザーが見つかりませんでした');
      } else if (e.response?.statusCode == 401) {
        throw Exception('認証に失敗しました。トークンが無効です。');
      } else if (e.response?.statusCode == 403) {
        throw Exception('アクセスが拒否されました。トークンの権限を確認してください。');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('接続がタイムアウトしました。ネットワーク接続を確認してください。');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('ネットワークエラーが発生しました。インターネット接続を確認してください。');
      } else {
        throw Exception('ユーザー情報の取得に失敗しました: ${e.message}');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  /// Contributionデータを取得する（GraphQL APIを使用）
  Future<List<Contribution>> getContributions(String token, int year) async {
    try {
      // GraphQL APIのエンドポイント
      const graphqlUrl = 'https://api.github.com/graphql';

      // GraphQL API用の認証ヘッダー（Bearerトークンを使用）
      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Accept'] = 'application/vnd.github.v3+json';

      // 開始日と終了日を計算（ISO 8601形式）
      final startDate = DateTime(year, 1, 1);
      final today = DateTime.now();

      // 今日のデータを確実に含めるため、翌日の開始時刻（UTC）を終了日として指定
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowStart = DateTime.utc(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
      );

      // 年末と翌日の開始時刻のうち、早い方を使用
      final yearEndUtc = DateTime.utc(year, 12, 31, 23, 59, 59);
      final actualEndDate = yearEndUtc.isAfter(tomorrowStart)
          ? tomorrowStart
          : yearEndUtc;

      // ISO 8601形式に変換
      final startDateStr = startDate.toUtc().toIso8601String();
      final endDateStr = actualEndDate.toIso8601String();

      // GraphQLクエリ
      final query =
          '''
        query {
          viewer {
            contributionsCollection(from: "$startDateStr", to: "$endDateStr") {
              contributionCalendar {
                totalContributions
                weeks {
                  contributionDays {
                    date
                    contributionCount
                  }
                }
              }
            }
          }
        }
      ''';

      final response = await _dio.post(graphqlUrl, data: {'query': query});

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null || data['viewer'] == null) {
          throw Exception('Contributionデータの取得に失敗しました');
        }

        final contributionsCollection =
            data['viewer']['contributionsCollection'];
        if (contributionsCollection == null) {
          throw Exception('Contributionデータの取得に失敗しました');
        }

        final contributionCalendar =
            contributionsCollection['contributionCalendar'];
        if (contributionCalendar == null) {
          throw Exception('Contributionデータの取得に失敗しました');
        }

        final weeks = contributionCalendar['weeks'] as List<dynamic>?;
        if (weeks == null) {
          return [];
        }

        final contributions = <Contribution>[];

        for (final week in weeks) {
          final contributionDays = week['contributionDays'] as List<dynamic>?;
          if (contributionDays == null) continue;

          for (final day in contributionDays) {
            final dateStr = day['date'] as String;
            final count = day['contributionCount'] as int? ?? 0;

            // 日付文字列をDateTimeに変換（YYYY-MM-DD形式）
            final dateParts = dateStr.split('-');
            if (dateParts.length == 3) {
              final date = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
              );
              contributions.add(Contribution(date: date, count: count));
            }
          }
        }

        contributions.sort((a, b) => a.date.compareTo(b.date));
        return contributions;
      } else {
        throw Exception('Contributionデータの取得に失敗しました');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('認証に失敗しました。トークンが無効です。');
      } else if (e.response?.statusCode == 403) {
        throw Exception('アクセスが拒否されました。トークンの権限を確認してください。');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('接続がタイムアウトしました。ネットワーク接続を確認してください。');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('ネットワークエラーが発生しました。インターネット接続を確認してください。');
      } else {
        final errorMessage =
            e.response?.data?['errors']?[0]?['message'] as String?;
        throw Exception(
          errorMessage ?? 'Contributionデータの取得に失敗しました: ${e.message}',
        );
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  /// 指定されたユーザーのContributionデータを取得する（GraphQL APIを使用）
  Future<List<Contribution>> getUserContributions(
    String token,
    String username,
    int year,
  ) async {
    try {
      // GraphQL APIのエンドポイント
      const graphqlUrl = 'https://api.github.com/graphql';

      // GraphQL API用の認証ヘッダー（Bearerトークンを使用）
      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Accept'] = 'application/vnd.github.v3+json';

      // 開始日と終了日を計算（ISO 8601形式）
      final startDate = DateTime(year, 1, 1);
      final today = DateTime.now();

      // 今日のデータを確実に含めるため、翌日の開始時刻（UTC）を終了日として指定
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowStart = DateTime.utc(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
      );

      // 年末と翌日の開始時刻のうち、早い方を使用
      final yearEndUtc = DateTime.utc(year, 12, 31, 23, 59, 59);
      final actualEndDate = yearEndUtc.isAfter(tomorrowStart)
          ? tomorrowStart
          : yearEndUtc;

      // ISO 8601形式に変換
      final startDateStr = startDate.toUtc().toIso8601String();
      final endDateStr = actualEndDate.toIso8601String();

      // GraphQLクエリ（特定のユーザーのContributionデータを取得）
      final query =
          '''
        query {
          user(login: "$username") {
            contributionsCollection(from: "$startDateStr", to: "$endDateStr") {
              contributionCalendar {
                totalContributions
                weeks {
                  contributionDays {
                    date
                    contributionCount
                  }
                }
              }
            }
          }
        }
      ''';

      final response = await _dio.post(graphqlUrl, data: {'query': query});

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Contributionデータの取得に失敗しました');
        }

        // エラーがある場合（例：ユーザーが見つからない）
        if (data['user'] == null) {
          final errors = response.data['errors'] as List<dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final errorMessage =
                errors[0]['message'] as String? ?? 'ユーザーが見つかりませんでした';
            throw Exception(errorMessage);
          }
          throw Exception('ユーザーが見つかりませんでした');
        }

        final contributionsCollection = data['user']['contributionsCollection'];
        if (contributionsCollection == null) {
          throw Exception('Contributionデータの取得に失敗しました');
        }

        final contributionCalendar =
            contributionsCollection['contributionCalendar'];
        if (contributionCalendar == null) {
          throw Exception('Contributionデータの取得に失敗しました');
        }

        final weeks = contributionCalendar['weeks'] as List<dynamic>?;
        if (weeks == null) {
          return [];
        }

        final contributions = <Contribution>[];

        for (final week in weeks) {
          final contributionDays = week['contributionDays'] as List<dynamic>?;
          if (contributionDays == null) continue;

          for (final day in contributionDays) {
            final dateStr = day['date'] as String;
            final count = day['contributionCount'] as int? ?? 0;

            // 日付文字列をDateTimeに変換（YYYY-MM-DD形式）
            final dateParts = dateStr.split('-');
            if (dateParts.length == 3) {
              final date = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
              );
              contributions.add(Contribution(date: date, count: count));
            }
          }
        }

        contributions.sort((a, b) => a.date.compareTo(b.date));
        return contributions;
      } else {
        throw Exception('Contributionデータの取得に失敗しました');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('認証に失敗しました。トークンが無効です。');
      } else if (e.response?.statusCode == 403) {
        throw Exception('アクセスが拒否されました。トークンの権限を確認してください。');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('接続がタイムアウトしました。ネットワーク接続を確認してください。');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('ネットワークエラーが発生しました。インターネット接続を確認してください。');
      } else {
        final errorMessage =
            e.response?.data?['errors']?[0]?['message'] as String?;
        throw Exception(
          errorMessage ?? 'Contributionデータの取得に失敗しました: ${e.message}',
        );
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }

  /// フォロー中のユーザー一覧を取得する
  Future<List<User>> getFollowingUsers(String token) async {
    try {
      _setAuthHeader(token);
      final List<User> followingUsers = [];
      int page = 1;
      const perPage = 100; // GitHub APIの最大値

      while (true) {
        final response = await _dio.get(
          '$_baseUrl/user/following',
          queryParameters: {'page': page, 'per_page': perPage},
        );

        if (response.statusCode == 200) {
          final List<dynamic> users = response.data as List<dynamic>;

          if (users.isEmpty) {
            break; // これ以上ユーザーがいない
          }

          for (final userJson in users) {
            followingUsers.add(
              UserModel.fromJson(userJson as Map<String, dynamic>).toEntity(),
            );
          }

          // 取得したユーザー数がperPage未満なら最後のページ
          if (users.length < perPage) {
            break;
          }

          page++;
        } else if (response.statusCode == 404) {
          break; // フォロー中のユーザーがいない
        } else {
          throw Exception('フォロー中のユーザー一覧の取得に失敗しました');
        }
      }

      return followingUsers;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('認証に失敗しました。トークンが無効です。');
      } else if (e.response?.statusCode == 403) {
        throw Exception('アクセスが拒否されました。トークンの権限を確認してください。');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('接続がタイムアウトしました。ネットワーク接続を確認してください。');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('ネットワークエラーが発生しました。インターネット接続を確認してください。');
      } else {
        throw Exception('フォロー中のユーザー一覧の取得に失敗しました: ${e.message}');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }
}
