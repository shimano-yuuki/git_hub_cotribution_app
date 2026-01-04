import 'package:flutter_test/flutter_test.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/user_ranking.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('UserRanking Entity', () {
    group('コンストラクタ', () {
      test('全てのフィールドが設定されたUserRankingを作成できる', () {
        // Arrange
        final user = TestData.validUser();
        const contributionCount = 100;
        const rank = 1;
        final userRanking = UserRanking(
          user: user,
          contributionCount: contributionCount,
          rank: rank,
        );

        // Assert
        expect(userRanking.user, user);
        expect(userRanking.contributionCount, contributionCount);
        expect(userRanking.rank, rank);
      });
    });

    group('境界値テスト', () {
      test('rankが1のUserRankingを作成できる', () {
        // Arrange
        final user = TestData.validUser();
        const rank = 1;
        final userRanking = UserRanking(
          user: user,
          contributionCount: 100,
          rank: rank,
        );

        // Assert
        expect(userRanking.rank, 1);
      });

      test('rankが0のUserRankingを作成できる（実装によっては制約がある可能性）', () {
        // Arrange
        final user = TestData.validUser();
        const rank = 0;
        final userRanking = UserRanking(
          user: user,
          contributionCount: 100,
          rank: rank,
        );

        // Assert
        expect(userRanking.rank, 0);
      });

      test('非常に大きなrank値のUserRankingを作成できる', () {
        // Arrange
        final user = TestData.validUser();
        const rank = 999999;
        final userRanking = UserRanking(
          user: user,
          contributionCount: 100,
          rank: rank,
        );

        // Assert
        expect(userRanking.rank, 999999);
      });

      test('contributionCountが0のUserRankingを作成できる', () {
        // Arrange
        final user = TestData.validUser();
        const contributionCount = 0;
        final userRanking = UserRanking(
          user: user,
          contributionCount: contributionCount,
          rank: 1,
        );

        // Assert
        expect(userRanking.contributionCount, 0);
      });

      test('非常に大きなcontributionCount値のUserRankingを作成できる', () {
        // Arrange
        final user = TestData.validUser();
        const contributionCount = 999999;
        final userRanking = UserRanking(
          user: user,
          contributionCount: contributionCount,
          rank: 1,
        );

        // Assert
        expect(userRanking.contributionCount, 999999);
      });
    });

    group('TestDataヘルパー', () {
      test('validUserRankingが正しく作成される', () {
        // Arrange
        final userRanking = TestData.validUserRanking();

        // Assert
        expect(userRanking.user, TestData.validUser());
        expect(userRanking.contributionCount, 100);
        expect(userRanking.rank, 1);
      });

      test('userRankingListが正しく作成される', () {
        // Arrange
        final userRankings = TestData.userRankingList();

        // Assert
        expect(userRankings.length, 3);
        expect(userRankings[0].rank, 1);
        expect(userRankings[1].rank, 2);
        expect(userRankings[2].rank, 3);
        expect(userRankings[0].contributionCount, 100);
        expect(userRankings[1].contributionCount, 80);
        expect(userRankings[2].contributionCount, 60);
      });
    });
  });
}
