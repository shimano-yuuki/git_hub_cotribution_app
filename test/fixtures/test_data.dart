import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/user.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution_statistics.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/user_ranking.dart';

/// テストデータを提供するヘルパークラス
class TestData {
  /// 有効なユーザーを返す
  static User validUser() => const User(
        login: 'testuser',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.png',
        bio: 'Test bio',
        publicRepos: 10,
        followers: 20,
        following: 15,
      );

  /// 最小限の情報のユーザーを返す
  static User minimalUser() => const User(
        login: 'minimaluser',
        name: 'Minimal User',
      );

  /// 無効なユーザー（空文字列を含む）を返す
  static User invalidUser() => const User(
        login: '',
        name: '',
      );

  /// ユーザーリストを返す
  static List<User> userList() => [
        validUser(),
        const User(
          login: 'user2',
          name: 'User 2',
          avatarUrl: 'https://example.com/user2.png',
          bio: 'Bio 2',
          publicRepos: 5,
          followers: 10,
          following: 8,
        ),
        const User(
          login: 'user3',
          name: 'User 3',
          publicRepos: 3,
          followers: 5,
          following: 2,
        ),
      ];

  /// 有効なContributionを返す
  static Contribution validContribution() => Contribution(
        date: DateTime(2024, 1, 1),
        count: 5,
      );

  /// Contributionリストを返す
  static List<Contribution> contributionList() => [
        Contribution(date: DateTime(2024, 1, 1), count: 5),
        Contribution(date: DateTime(2024, 1, 2), count: 3),
        Contribution(date: DateTime(2024, 1, 3), count: 0),
        Contribution(date: DateTime(2024, 1, 4), count: 10),
        Contribution(date: DateTime(2024, 1, 5), count: 7),
      ];

  /// 連続したContributionリストを返す（ストリークテスト用）
  static List<Contribution> consecutiveContributionList() => [
        Contribution(date: DateTime(2024, 1, 1), count: 5),
        Contribution(date: DateTime(2024, 1, 2), count: 3),
        Contribution(date: DateTime(2024, 1, 3), count: 7),
        Contribution(date: DateTime(2024, 1, 4), count: 10),
        Contribution(date: DateTime(2024, 1, 5), count: 2),
      ];

  /// 空のContributionリストを返す
  static List<Contribution> emptyContributionList() => [];

  /// 有効なContributionStatisticsを返す
  static ContributionStatistics validContributionStatistics() => const ContributionStatistics(
        totalContributions: 100,
        currentStreak: 5,
        longestStreak: 10,
        thisYearContributions: 80,
        thisWeekContributions: 20,
      );

  /// ゼロのContributionStatisticsを返す
  static ContributionStatistics zeroContributionStatistics() => const ContributionStatistics(
        totalContributions: 0,
        currentStreak: 0,
        longestStreak: 0,
        thisYearContributions: 0,
        thisWeekContributions: 0,
      );

  /// 有効なUserRankingを返す
  static UserRanking validUserRanking() => UserRanking(
        user: validUser(),
        contributionCount: 100,
        rank: 1,
      );

  /// UserRankingリストを返す
  static List<UserRanking> userRankingList() => [
        UserRanking(
          user: validUser(),
          contributionCount: 100,
          rank: 1,
        ),
        UserRanking(
          user: userList()[1],
          contributionCount: 80,
          rank: 2,
        ),
        UserRanking(
          user: userList()[2],
          contributionCount: 60,
          rank: 3,
        ),
      ];
}



