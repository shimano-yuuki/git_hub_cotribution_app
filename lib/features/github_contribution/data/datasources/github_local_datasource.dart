import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_ranking.dart';

/// GitHub Contributionデータのローカルキャッシュ管理
class GithubLocalDataSource {
  static const String _contributionsKeyPrefix = 'contributions_';
  static const String _lastUpdatedKeyPrefix = 'last_updated_';
  static const String _followingUsersKey = 'following_users';
  static const String _weeklyRankingsKey = 'weekly_rankings';
  static const String _allTimeRankingsKey = 'all_time_rankings';

  /// Contributionデータをキャッシュに保存
  Future<void> cacheContributions(
    int year,
    List<Contribution> contributions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_contributionsKeyPrefix$year';

      // ContributionリストをJSONに変換
      final jsonList = contributions
          .map((c) => {'date': c.date.toIso8601String(), 'count': c.count})
          .toList();

      final jsonString = jsonEncode(jsonList);
      await prefs.setString(key, jsonString);

      // 最終更新日時を保存
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$year';
      await prefs.setString(lastUpdatedKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('キャッシュの保存に失敗しました: $e');
    }
  }

  /// キャッシュからContributionデータを取得
  Future<List<Contribution>?> getCachedContributions(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_contributionsKeyPrefix$year';
      final jsonString = prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) {
        final dateStr = json['date'] as String;
        final count = json['count'] as int;
        return Contribution(date: DateTime.parse(dateStr), count: count);
      }).toList();
    } catch (e) {
      return null;
    }
  }

  /// 最終更新日時を取得
  Future<DateTime?> getLastUpdated(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_lastUpdatedKeyPrefix$year';
      final dateStr = prefs.getString(key);

      if (dateStr == null) {
        return null;
      }

      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// キャッシュをクリア
  Future<void> clearCache(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contributionsKey = '$_contributionsKeyPrefix$year';
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$year';

      await prefs.remove(contributionsKey);
      await prefs.remove(lastUpdatedKey);
    } catch (e) {
      throw Exception('キャッシュの削除に失敗しました: $e');
    }
  }

  /// フォロー中のユーザーをキャッシュに保存
  Future<void> cacheFollowingUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = users.map((user) {
        return {
          'login': user.login,
          'name': user.name,
          'avatarUrl': user.avatarUrl,
          'bio': user.bio,
          'publicRepos': user.publicRepos,
          'followers': user.followers,
          'following': user.following,
        };
      }).toList();

      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_followingUsersKey, jsonString);
    } catch (e) {
      throw Exception('フォロー中のユーザーのキャッシュ保存に失敗しました: $e');
    }
  }

  /// キャッシュからフォロー中のユーザーを取得
  Future<List<User>?> getCachedFollowingUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_followingUsersKey);

      if (jsonString == null) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) {
        return User(
          login: json['login'] as String,
          name: json['name'] as String,
          avatarUrl: json['avatarUrl'] as String?,
          bio: json['bio'] as String?,
          publicRepos: json['publicRepos'] as int?,
          followers: json['followers'] as int?,
          following: json['following'] as int?,
        );
      }).toList();
    } catch (e) {
      return null;
    }
  }

  /// ランキングをキャッシュに保存
  Future<void> cacheRankings(
    List<UserRanking> weeklyRankings,
    List<UserRanking> allTimeRankings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 週間ランキングを保存
      final weeklyJsonList = weeklyRankings.map((ranking) {
        return {
          'user': {
            'login': ranking.user.login,
            'name': ranking.user.name,
            'avatarUrl': ranking.user.avatarUrl,
            'bio': ranking.user.bio,
            'publicRepos': ranking.user.publicRepos,
            'followers': ranking.user.followers,
            'following': ranking.user.following,
          },
          'contributionCount': ranking.contributionCount,
          'rank': ranking.rank,
        };
      }).toList();

      // 全期間ランキングを保存
      final allTimeJsonList = allTimeRankings.map((ranking) {
        return {
          'user': {
            'login': ranking.user.login,
            'name': ranking.user.name,
            'avatarUrl': ranking.user.avatarUrl,
            'bio': ranking.user.bio,
            'publicRepos': ranking.user.publicRepos,
            'followers': ranking.user.followers,
            'following': ranking.user.following,
          },
          'contributionCount': ranking.contributionCount,
          'rank': ranking.rank,
        };
      }).toList();

      await prefs.setString(_weeklyRankingsKey, jsonEncode(weeklyJsonList));
      await prefs.setString(_allTimeRankingsKey, jsonEncode(allTimeJsonList));
    } catch (e) {
      throw Exception('ランキングのキャッシュ保存に失敗しました: $e');
    }
  }

  /// キャッシュからランキングを取得
  Future<Map<String, List<UserRanking>>?> getCachedRankings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weeklyJsonString = prefs.getString(_weeklyRankingsKey);
      final allTimeJsonString = prefs.getString(_allTimeRankingsKey);

      if (weeklyJsonString == null || allTimeJsonString == null) {
        return null;
      }

      final weeklyJsonList = jsonDecode(weeklyJsonString) as List<dynamic>;
      final allTimeJsonList = jsonDecode(allTimeJsonString) as List<dynamic>;

      final weeklyRankings = weeklyJsonList.map((json) {
        final userJson = json['user'] as Map<String, dynamic>;
        return UserRanking(
          user: User(
            login: userJson['login'] as String,
            name: userJson['name'] as String,
            avatarUrl: userJson['avatarUrl'] as String?,
            bio: userJson['bio'] as String?,
            publicRepos: userJson['publicRepos'] as int?,
            followers: userJson['followers'] as int?,
            following: userJson['following'] as int?,
          ),
          contributionCount: json['contributionCount'] as int,
          rank: json['rank'] as int,
        );
      }).toList();

      final allTimeRankings = allTimeJsonList.map((json) {
        final userJson = json['user'] as Map<String, dynamic>;
        return UserRanking(
          user: User(
            login: userJson['login'] as String,
            name: userJson['name'] as String,
            avatarUrl: userJson['avatarUrl'] as String?,
            bio: userJson['bio'] as String?,
            publicRepos: userJson['publicRepos'] as int?,
            followers: userJson['followers'] as int?,
            following: userJson['following'] as int?,
          ),
          contributionCount: json['contributionCount'] as int,
          rank: json['rank'] as int,
        );
      }).toList();

      return {'weekly': weeklyRankings, 'allTime': allTimeRankings};
    } catch (e) {
      return null;
    }
  }
}
