import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../github_contribution/presentation/widgets/contribution_calendar_widget.dart';
import '../../../github_contribution/domain/entities/contribution.dart';
import '../../../github_contribution/domain/usecases/get_contributions_usecase.dart';
import '../../../github_contribution/data/repositories/github_repository_impl.dart';
import '../../../github_contribution/domain/repositories/github_repository.dart';
import '../../../settings/domain/usecases/get_token_usecase.dart';
import '../../../settings/data/repositories/token_repository_impl.dart';
import '../../../settings/data/datasources/token_local_datasource.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'dart:math' as math;

class ProfileScreen extends HookWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);

    // DI: 依存関係を構築
    final tokenRepository = useMemoized(
      () => TokenRepositoryImpl(TokenLocalDataSource()),
    );
    final getTokenUseCase = useMemoized(() => GetTokenUseCase(tokenRepository));

    final githubRepository = useMemoized(
      () => GithubRepositoryImpl() as GithubRepository,
    );
    final getContributionsUseCase = useMemoized(
      () => GetContributionsUseCase(githubRepository),
    );

    // 状態管理
    final contributions = useState<List<Contribution>>([]);
    final isLoading = useState<bool>(true);
    final error = useState<String?>(null);
    final selectedYear = useState<int>(DateTime.now().year);

    // 初期化時にContributionデータを取得
    useEffect(() {
      Future.microtask(() async {
        isLoading.value = true;
        error.value = null;

        try {
          // 保存されているトークンを取得
          final token = await getTokenUseCase();
          if (token == null || token.value.isEmpty) {
            // トークンが保存されていない場合はモックデータを使用
            final mockData = _generateMockContributions();

            // 今日のデータが含まれているか確認
            final today = DateTime.now();
            final todayNormalized = DateTime(
              today.year,
              today.month,
              today.day,
            );
            final hasTodayData = mockData.any((c) {
              final cDate = DateTime(c.date.year, c.date.month, c.date.day);
              return cDate == todayNormalized;
            });

            if (!hasTodayData) {
              final random = math.Random();
              final todayCount = 5 + random.nextInt(11);
              mockData.insert(
                0,
                Contribution(date: todayNormalized, count: todayCount),
              );
            }

            contributions.value = mockData;
            isLoading.value = false;
            return;
          }

          // Contributionデータを取得
          final result = await getContributionsUseCase(
            token.value,
            selectedYear.value,
          );
          result.fold(
            (failure) {
              error.value = failure.message;
              // エラー時はモックデータを使用
              final mockData = _generateMockContributions();

              // 今日のデータが含まれているか確認
              final today = DateTime.now();
              final todayNormalized = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final hasTodayData = mockData.any((c) {
                final cDate = DateTime(c.date.year, c.date.month, c.date.day);
                return cDate == todayNormalized;
              });

              if (!hasTodayData) {
                final random = math.Random();
                final todayCount = 5 + random.nextInt(11);
                mockData.insert(
                  0,
                  Contribution(date: todayNormalized, count: todayCount),
                );
              }

              contributions.value = mockData;
            },
            (data) {
              // 今日のデータが含まれているか確認
              final today = DateTime.now();
              final todayNormalized = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final hasTodayData = data.any((c) {
                final cDate = DateTime(c.date.year, c.date.month, c.date.day);
                return cDate == todayNormalized;
              });

              if (!hasTodayData) {
                final modifiedData = [
                  ...data,
                  Contribution(date: todayNormalized, count: 0),
                ];
                contributions.value = modifiedData;
              } else {
                contributions.value = data;
              }
              error.value = null;
            },
          );
        } catch (e) {
          error.value = 'Contributionデータの取得に失敗しました: $e';
          // エラー時はモックデータを使用
          final mockData = _generateMockContributions();

          // 今日のデータが含まれているか確認
          final today = DateTime.now();
          final todayNormalized = DateTime(today.year, today.month, today.day);
          final hasTodayData = mockData.any((c) {
            final cDate = DateTime(c.date.year, c.date.month, c.date.day);
            return cDate == todayNormalized;
          });

          if (!hasTodayData) {
            final random = math.Random();
            final todayCount = 5 + random.nextInt(11);
            mockData.insert(
              0,
              Contribution(date: todayNormalized, count: todayCount),
            );
          }

          contributions.value = mockData;
        } finally {
          isLoading.value = false;
        }
      });

      return null;
    }, [selectedYear.value]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Contributionカレンダーセクション
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Contribution Calendar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                // エラーメッセージ表示
                if (error.value != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      error.value!,
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                // ローディング表示
                if (isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  // カレンダーウィジェット
                  Builder(
                    builder: (context) {
                      return ContributionCalendarWidget(
                        contributions: contributions.value,
                        initialYear: selectedYear.value,
                        onYearChanged: (newYear) {
                          selectedYear.value = newYear;
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  /// モックContributionデータを生成（テスト用）
  List<Contribution> _generateMockContributions() {
    final contributions = <Contribution>[];
    final today = DateTime.now();
    final random = math.Random();

    // 過去1年間のデータを生成
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      // 日付を正規化（時刻情報を削除して00:00:00.000にする）
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // 今日は確実にContributionがあるようにする
      int count;
      if (i == 0) {
        // 今日は5〜15のランダムな値
        count = 5 + random.nextInt(11);
      } else {
        // その他の日はランダム（0-25の範囲、ただし0の確率を高くする）
        count = random.nextInt(100) < 60 ? 0 : random.nextInt(25);
      }

      contributions.add(Contribution(date: normalizedDate, count: count));
    }

    return contributions;
  }
}
