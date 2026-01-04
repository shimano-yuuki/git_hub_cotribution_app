import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/contribution.dart';

/// GitHub Contributionデータのローカルキャッシュ管理
class GithubLocalDataSource {
  static const String _contributionsKeyPrefix = 'contributions_';
  static const String _lastUpdatedKeyPrefix = 'last_updated_';

  /// Contributionデータをキャッシュに保存
  Future<void> cacheContributions(
    int year,
    List<Contribution> contributions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_contributionsKeyPrefix$year';
      
      // ContributionリストをJSONに変換
      final jsonList = contributions.map((c) => {
        'date': c.date.toIso8601String(),
        'count': c.count,
      }).toList();
      
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(key, jsonString);
      
      // 最終更新日時を保存
      final lastUpdatedKey = '$_lastUpdatedKeyPrefix$year';
      await prefs.setString(
        lastUpdatedKey,
        DateTime.now().toIso8601String(),
      );
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
        return Contribution(
          date: DateTime.parse(dateStr),
          count: count,
        );
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
}



