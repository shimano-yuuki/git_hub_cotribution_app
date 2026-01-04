import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:git_hub_contribution_app/shared/widgets/statistics_button.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution_statistics.dart';
import '../../fixtures/test_data.dart';

void main() {
  group('StatisticsButton Widget', () {
    group('レンダリングテスト', () {
      testWidgets('統計データ確認ボタンが正しく表示される', (WidgetTester tester) async {
        // Arrange
        final statistics = TestData.validContributionStatistics();
        const year = 2024;

        // Act
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Statistics Screen')),
                ),
              ],
            ),
          ),
        );

        // Assert
        expect(find.text('統計データを確認する'), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });

      testWidgets('ダークテーマで正しく表示される', (WidgetTester tester) async {
        // Arrange
        final statistics = TestData.validContributionStatistics();
        const year = 2024;

        // Act
        await tester.pumpWidget(
          MaterialApp.router(
            theme: ThemeData.dark(),
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Statistics Screen')),
                ),
              ],
            ),
          ),
        );

        // Assert
        expect(find.text('統計データを確認する'), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });
    });

    group('ユーザーインタラクションテスト', () {
      testWidgets('タップすると統計画面に遷移する', (WidgetTester tester) async {
        // Arrange
        final statistics = TestData.validContributionStatistics();
        const year = 2024;

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  pageBuilder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    final stats = extra['statistics'] as ContributionStatistics;
                    final y = extra['year'] as int;
                    return MaterialPage(
                      key: state.pageKey,
                      child: Scaffold(
                        body: Text(
                          'Statistics Screen: ${stats.totalContributions}, $y',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );

        // Assert: 初期状態
        expect(find.text('統計データを確認する'), findsOneWidget);
        expect(find.text('Statistics Screen:'), findsNothing);

        // Act: ボタンをタップ
        await tester.tap(find.text('統計データを確認する'));
        await tester.pumpAndSettle();

        // Assert: 遷移後の確認
        expect(find.text('Statistics Screen: 100, 2024'), findsOneWidget);
      });

      testWidgets('異なるyear値で正しく遷移する', (WidgetTester tester) async {
        // Arrange
        final statistics = TestData.validContributionStatistics();
        const year = 2023;

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  pageBuilder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    final y = extra['year'] as int;
                    return MaterialPage(
                      key: state.pageKey,
                      child: Scaffold(body: Text('Year: $y')),
                    );
                  },
                ),
              ],
            ),
          ),
        );

        // Act
        await tester.tap(find.text('統計データを確認する'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Year: 2023'), findsOneWidget);
      });
    });

    group('境界値テスト', () {
      testWidgets('ゼロ値の統計データで正しく表示される', (WidgetTester tester) async {
        // Arrange
        final statistics = TestData.zeroContributionStatistics();
        const year = 2024;

        // Act
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Statistics Screen')),
                ),
              ],
            ),
          ),
        );

        // Assert
        expect(find.text('統計データを確認する'), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });

      testWidgets('最小のyear値で正しく表示される', (WidgetTester tester) async {
        // Arrange
        final statistics = TestData.validContributionStatistics();
        const year = 1970;

        // Act
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Statistics Screen')),
                ),
              ],
            ),
          ),
        );

        // Assert
        expect(find.text('統計データを確認する'), findsOneWidget);
      });
    });

    group('状態変化テスト', () {
      testWidgets('異なる統計データで正しく表示が更新される', (WidgetTester tester) async {
        // Arrange
        final statistics1 = TestData.validContributionStatistics();
        final statistics2 = TestData.zeroContributionStatistics();
        const year = 2024;

        // Act & Assert: 最初の統計データ
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics1, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Statistics Screen')),
                ),
              ],
            ),
          ),
        );

        expect(find.text('統計データを確認する'), findsOneWidget);

        // Act & Assert: 統計データを変更
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: StatisticsButton(statistics: statistics2, year: year),
                  ),
                ),
                GoRoute(
                  path: '/statistics',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Statistics Screen')),
                ),
              ],
            ),
          ),
        );

        expect(find.text('統計データを確認する'), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });
    });
  });
}
