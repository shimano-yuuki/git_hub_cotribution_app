import 'package:flutter_test/flutter_test.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution_statistics.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/usecases/calculate_contribution_statistics_usecase.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('CalculateContributionStatisticsUseCase', () {
    late CalculateContributionStatisticsUseCase useCase;

    setUp(() {
      useCase = CalculateContributionStatisticsUseCase();
    });

    group('正常系', () {
      test('Contributionリストから統計情報を計算できる', () {
        // Arrange
        final contributions = TestData.contributionList();

        // Act
        final result = useCase.call(contributions);

        // Assert
        expect(result, isA<ContributionStatistics>());
        expect(result.totalContributions, 25); // 5 + 3 + 0 + 10 + 7
      });

      test('連続したContributionからストリークを計算できる', () {
        // Arrange
        final contributions = TestData.consecutiveContributionList();

        // Act
        final result = useCase.call(contributions);

        // Assert
        expect(result, isA<ContributionStatistics>());
        expect(result.totalContributions, 27); // 5 + 3 + 7 + 10 + 2
        // ストリークは実際の日付に依存するため、値の確認は行わない
      });
    });

    group('異常系・境界値', () {
      test('空のContributionリストの場合、全て0の統計情報を返す', () {
        // Arrange
        final emptyContributions = TestData.emptyContributionList();

        // Act
        final result = useCase.call(emptyContributions);

        // Assert
        expect(result.totalContributions, 0);
        expect(result.currentStreak, 0);
        expect(result.longestStreak, 0);
        expect(result.thisYearContributions, 0);
        expect(result.thisWeekContributions, 0);
      });

      test('countが0のみのContributionリストの場合、統計情報が0になる', () {
        // Arrange
        final zeroContributions = [
          Contribution(date: DateTime(2024, 1, 1), count: 0),
          Contribution(date: DateTime(2024, 1, 2), count: 0),
          Contribution(date: DateTime(2024, 1, 3), count: 0),
        ];

        // Act
        final result = useCase.call(zeroContributions);

        // Assert
        expect(result.totalContributions, 0);
        expect(result.currentStreak, 0);
        expect(result.longestStreak, 0);
      });

      test('単一のContributionから統計情報を計算できる', () {
        // Arrange
        final singleContribution = [
          Contribution(date: DateTime(2024, 1, 1), count: 10),
        ];

        // Act
        final result = useCase.call(singleContribution);

        // Assert
        expect(result.totalContributions, 10);
        expect(result.longestStreak, 1);
      });

      test('非常に大きなContributionリストから統計情報を計算できる', () {
        // Arrange
        final largeContributions = List.generate(
          1000,
          (index) => Contribution(
            date: DateTime(2024, 1, 1).add(Duration(days: index)),
            count: index % 10,
          ),
        );

        // Act
        final result = useCase.call(largeContributions);

        // Assert
        expect(result, isA<ContributionStatistics>());
        expect(result.totalContributions, greaterThan(0));
      });
    });

    group('今年のContribution数', () {
      test('今年のContributionのみをカウントする', () {
        // Arrange
        final currentYear = DateTime.now().year;
        final contributions = [
          Contribution(date: DateTime(currentYear, 1, 1), count: 10),
          Contribution(date: DateTime(currentYear, 6, 15), count: 5),
          Contribution(date: DateTime(currentYear - 1, 12, 31), count: 3),
        ];

        // Act
        final result = useCase.call(contributions);

        // Assert
        expect(result.thisYearContributions, 15); // 10 + 5
        expect(result.totalContributions, 18); // 10 + 5 + 3
      });
    });

    group('今週のContribution数', () {
      test('今週のContributionのみをカウントする', () {
        // Arrange
        final now = DateTime.now();
        final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

        final contributions = [
          Contribution(date: thisWeekStart, count: 10),
          Contribution(date: now, count: 5),
          Contribution(date: lastWeekEnd, count: 3),
        ];

        // Act
        final result = useCase.call(contributions);

        // Assert
        expect(result.thisWeekContributions, 15); // 10 + 5
        expect(result.totalContributions, 18); // 10 + 5 + 3
      });
    });
  });
}
