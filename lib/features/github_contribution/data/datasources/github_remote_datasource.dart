import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
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
        return UserModel.fromJson(response.data as Map<String, dynamic>)
            .toEntity();
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
}


