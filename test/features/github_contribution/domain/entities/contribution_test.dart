import 'package:flutter_test/flutter_test.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('Contribution Entity', () {
    group('コンストラクタ', () {
      test('有効なdateとcountでContributionを作成できる', () {
        // Arrange
        final date = DateTime(2024, 1, 1);
        const count = 5;
        final contribution = Contribution(date: date, count: count);

        // Assert
        expect(contribution.date, date);
        expect(contribution.count, count);
      });
    });

    group('equality', () {
      test('同じ日付とcountのContributionは等しい', () {
        // Arrange
        final date1 = DateTime(2024, 1, 1, 12, 30, 45);
        final date2 = DateTime(2024, 1, 1, 10, 20, 30);
        final contribution1 = Contribution(date: date1, count: 5);
        final contribution2 = Contribution(date: date2, count: 5);

        // Assert: 時間部分は無視され、年月日のみで比較される
        expect(contribution1, contribution2);
        // Note: hashCodeは実装に依存するため、等価性のみを検証
      });

      test('異なる日付のContributionは等しくない', () {
        // Arrange
        final date1 = DateTime(2024, 1, 1);
        final date2 = DateTime(2024, 1, 2);
        final contribution1 = Contribution(date: date1, count: 5);
        final contribution2 = Contribution(date: date2, count: 5);

        // Assert
        expect(contribution1, isNot(contribution2));
      });

      test('異なるcountのContributionは等しくない', () {
        // Arrange
        final date = DateTime(2024, 1, 1);
        final contribution1 = Contribution(date: date, count: 5);
        final contribution2 = Contribution(date: date, count: 10);

        // Assert
        expect(contribution1, isNot(contribution2));
      });

      test('異なる年のContributionは等しくない', () {
        // Arrange
        final date1 = DateTime(2024, 1, 1);
        final date2 = DateTime(2023, 1, 1);
        final contribution1 = Contribution(date: date1, count: 5);
        final contribution2 = Contribution(date: date2, count: 5);

        // Assert
        expect(contribution1, isNot(contribution2));
      });

      test('異なる月のContributionは等しくない', () {
        // Arrange
        final date1 = DateTime(2024, 1, 1);
        final date2 = DateTime(2024, 2, 1);
        final contribution1 = Contribution(date: date1, count: 5);
        final contribution2 = Contribution(date: date2, count: 5);

        // Assert
        expect(contribution1, isNot(contribution2));
      });
    });

    group('境界値テスト', () {
      test('countが0のContributionを作成できる', () {
        // Arrange
        final date = DateTime(2024, 1, 1);
        const count = 0;
        final contribution = Contribution(date: date, count: count);

        // Assert
        expect(contribution.count, 0);
      });

      test('countが負の値のContributionを作成できる（実装によっては制約がある可能性）', () {
        // Arrange
        final date = DateTime(2024, 1, 1);
        const count = -1;
        final contribution = Contribution(date: date, count: count);

        // Assert
        expect(contribution.count, -1);
      });

      test('非常に大きいcount値のContributionを作成できる', () {
        // Arrange
        final date = DateTime(2024, 1, 1);
        const count = 999999;
        final contribution = Contribution(date: date, count: count);

        // Assert
        expect(contribution.count, 999999);
      });

      test('過去の日付でContributionを作成できる', () {
        // Arrange
        final date = DateTime(2000, 1, 1);
        const count = 5;
        final contribution = Contribution(date: date, count: count);

        // Assert
        expect(contribution.date.year, 2000);
      });

      test('未来の日付でContributionを作成できる', () {
        // Arrange
        final date = DateTime(2100, 1, 1);
        const count = 5;
        final contribution = Contribution(date: date, count: count);

        // Assert
        expect(contribution.date.year, 2100);
      });
    });

    group('TestDataヘルパー', () {
      test('validContributionが正しく作成される', () {
        // Arrange
        final contribution = TestData.validContribution();

        // Assert
        expect(contribution.date, DateTime(2024, 1, 1));
        expect(contribution.count, 5);
      });

      test('contributionListが正しく作成される', () {
        // Arrange
        final contributions = TestData.contributionList();

        // Assert
        expect(contributions.length, 5);
        expect(contributions[0].date, DateTime(2024, 1, 1));
        expect(contributions[0].count, 5);
      });
    });
  });
}
