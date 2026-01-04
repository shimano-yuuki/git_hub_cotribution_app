import 'package:flutter_test/flutter_test.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution_statistics.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('ContributionStatistics Entity', () {
    group('コンストラクタ', () {
      test('全てのフィールドが設定されたContributionStatisticsを作成できる', () {
        // Arrange
        const statistics = ContributionStatistics(
          totalContributions: 100,
          currentStreak: 5,
          longestStreak: 10,
          thisYearContributions: 80,
          thisWeekContributions: 20,
        );

        // Assert
        expect(statistics.totalContributions, 100);
        expect(statistics.currentStreak, 5);
        expect(statistics.longestStreak, 10);
        expect(statistics.thisYearContributions, 80);
        expect(statistics.thisWeekContributions, 20);
      });
    });

    group('境界値テスト', () {
      test('全てのフィールドが0のContributionStatisticsを作成できる', () {
        // Arrange
        const statistics = ContributionStatistics(
          totalContributions: 0,
          currentStreak: 0,
          longestStreak: 0,
          thisYearContributions: 0,
          thisWeekContributions: 0,
        );

        // Assert
        expect(statistics.totalContributions, 0);
        expect(statistics.currentStreak, 0);
        expect(statistics.longestStreak, 0);
        expect(statistics.thisYearContributions, 0);
        expect(statistics.thisWeekContributions, 0);
      });

      test('非常に大きな値のContributionStatisticsを作成できる', () {
        // Arrange
        const statistics = ContributionStatistics(
          totalContributions: 999999,
          currentStreak: 365,
          longestStreak: 1000,
          thisYearContributions: 500000,
          thisWeekContributions: 10000,
        );

        // Assert
        expect(statistics.totalContributions, 999999);
        expect(statistics.currentStreak, 365);
        expect(statistics.longestStreak, 1000);
        expect(statistics.thisYearContributions, 500000);
        expect(statistics.thisWeekContributions, 10000);
      });

      test('負の値のContributionStatisticsを作成できる（実装によっては制約がある可能性）', () {
        // Arrange
        const statistics = ContributionStatistics(
          totalContributions: -1,
          currentStreak: -1,
          longestStreak: -1,
          thisYearContributions: -1,
          thisWeekContributions: -1,
        );

        // Assert
        expect(statistics.totalContributions, -1);
        expect(statistics.currentStreak, -1);
        expect(statistics.longestStreak, -1);
        expect(statistics.thisYearContributions, -1);
        expect(statistics.thisWeekContributions, -1);
      });
    });

    group('TestDataヘルパー', () {
      test('validContributionStatisticsが正しく作成される', () {
        // Arrange
        final statistics = TestData.validContributionStatistics();

        // Assert
        expect(statistics.totalContributions, 100);
        expect(statistics.currentStreak, 5);
        expect(statistics.longestStreak, 10);
        expect(statistics.thisYearContributions, 80);
        expect(statistics.thisWeekContributions, 20);
      });

      test('zeroContributionStatisticsが正しく作成される', () {
        // Arrange
        final statistics = TestData.zeroContributionStatistics();

        // Assert
        expect(statistics.totalContributions, 0);
        expect(statistics.currentStreak, 0);
        expect(statistics.longestStreak, 0);
        expect(statistics.thisYearContributions, 0);
        expect(statistics.thisWeekContributions, 0);
      });
    });
  });
}
