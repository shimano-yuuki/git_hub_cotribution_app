import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/retry_handler.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_ranking.dart';
import '../../domain/usecases/get_following_users_usecase.dart';
import '../../domain/usecases/get_user_contributions_usecase.dart';
import '../../domain/usecases/get_authenticated_user_usecase.dart';
import '../../domain/usecases/get_contributions_usecase.dart';
import '../../../settings/domain/usecases/get_token_usecase.dart';
import '../../../settings/data/repositories/token_repository_impl.dart';
import '../../../settings/data/datasources/token_local_datasource.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/error_display_widget.dart';
import '../../../../shared/widgets/geometric_background.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

/// フォロー中のユーザー一覧画面
class FollowingUsersScreen extends HookWidget {
  const FollowingUsersScreen({super.key});

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
    final getFollowingUsersUseCase = useMemoized(
      () => GetFollowingUsersUseCase(githubRepository),
    );
    final getUserContributionsUseCase = useMemoized(
      () => GetUserContributionsUseCase(githubRepository),
    );
    final getAuthenticatedUserUseCase = useMemoized(
      () => GetAuthenticatedUserUseCase(githubRepository),
    );
    final getContributionsUseCase = useMemoized(
      () => GetContributionsUseCase(githubRepository),
    );

    // 状態管理
    final followingUsers = useState<List<User>>([]);
    final weeklyRankings = useState<List<UserRanking>>([]);
    final allTimeRankings = useState<List<UserRanking>>([]);
    final selectedTab = useState<int>(0); // 0: 週間, 1: 全期間
    final isLoading = useState<bool>(true);
    final isRefreshing = useState<bool>(false);
    final error = useState<Failure?>(null);
    final isRetrying = useState<bool>(false);

    // ランキングを計算する関数
    Future<void> _calculateRankings(String token, List<User> users) async {
      try {
        final weeklyRankingsList = <UserRanking>[];
        final allTimeRankingsList = <UserRanking>[];

        // 今週の開始日（月曜日）
        final today = DateTime.now();
        final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
        final thisWeekStartNormalized = DateTime(
          thisWeekStart.year,
          thisWeekStart.month,
          thisWeekStart.day,
        );

        // 認証されたユーザーを取得してリストに追加
        final authenticatedUserResult = await getAuthenticatedUserUseCase(
          token,
        );
        final allUsers = <User>[];
        authenticatedUserResult.fold(
          (failure) {
            // エラーでも続行
          },
          (user) {
            allUsers.add(user);
          },
        );
        allUsers.addAll(users);

        // 各ユーザーのContributionデータを取得
        for (final user in allUsers) {
          try {
            List<int> counts = [0, 0];

            // 認証されたユーザーの場合は自分のContributionデータを使用
            final isAuthenticatedUser =
                authenticatedUserResult.isRight() &&
                authenticatedUserResult
                        .getOrElse((_) => User(login: '', name: ''))
                        .login ==
                    user.login;

            if (isAuthenticatedUser) {
              // 自分のデータ：今年のデータを取得
              final contributionsResult = await getContributionsUseCase(
                token,
                today.year,
              );
              if (contributionsResult.isRight()) {
                final contributions = contributionsResult.getOrElse((_) => []);
                // 週間Contribution数を計算
                final weeklyCount = contributions
                    .where((c) {
                      final cDate = DateTime(
                        c.date.year,
                        c.date.month,
                        c.date.day,
                      );
                      return !cDate.isBefore(thisWeekStartNormalized);
                    })
                    .fold<int>(0, (sum, c) => sum + c.count);

                // 全期間Contribution数（今年と昨年の合計、最低限のデータ）
                int allTimeCount = contributions.fold<int>(
                  0,
                  (sum, c) => sum + c.count,
                );

                // 昨年のデータも取得（最低限のデータとして）
                final lastYearResult = await getContributionsUseCase(
                  token,
                  today.year - 1,
                );
                lastYearResult.fold(
                  (failure) {
                    // エラーでも今年のデータのみで続行
                  },
                  (lastYearContributions) {
                    allTimeCount += lastYearContributions.fold<int>(
                      0,
                      (sum, c) => sum + c.count,
                    );
                  },
                );

                counts = [weeklyCount, allTimeCount];
              } else {
                counts = [0, 0];
              }
            } else {
              // 他のユーザーのデータ：今年のデータを取得
              final contributionsResult = await getUserContributionsUseCase(
                token,
                user.login,
                today.year,
              );
              if (contributionsResult.isRight()) {
                final contributions = contributionsResult.getOrElse((_) => []);
                // 週間Contribution数を計算
                final weeklyCount = contributions
                    .where((c) {
                      final cDate = DateTime(
                        c.date.year,
                        c.date.month,
                        c.date.day,
                      );
                      return !cDate.isBefore(thisWeekStartNormalized);
                    })
                    .fold<int>(0, (sum, c) => sum + c.count);

                // 全期間Contribution数（今年と昨年の合計、最低限のデータ）
                int allTimeCount = contributions.fold<int>(
                  0,
                  (sum, c) => sum + c.count,
                );

                // 昨年のデータも取得（最低限のデータとして）
                final lastYearResult = await getUserContributionsUseCase(
                  token,
                  user.login,
                  today.year - 1,
                );
                lastYearResult.fold(
                  (failure) {
                    // エラーでも今年のデータのみで続行
                  },
                  (lastYearContributions) {
                    allTimeCount += lastYearContributions.fold<int>(
                      0,
                      (sum, c) => sum + c.count,
                    );
                  },
                );

                counts = [weeklyCount, allTimeCount];
              } else {
                counts = [0, 0];
              }
            }

            weeklyRankingsList.add(
              UserRanking(user: user, contributionCount: counts[0], rank: 0),
            );
            allTimeRankingsList.add(
              UserRanking(user: user, contributionCount: counts[1], rank: 0),
            );
          } catch (e) {
            // エラーの場合は0として扱う
            weeklyRankingsList.add(
              UserRanking(user: user, contributionCount: 0, rank: 0),
            );
            allTimeRankingsList.add(
              UserRanking(user: user, contributionCount: 0, rank: 0),
            );
          }
        }

        // ランキング順にソート（降順）
        weeklyRankingsList.sort(
          (a, b) => b.contributionCount.compareTo(a.contributionCount),
        );
        allTimeRankingsList.sort(
          (a, b) => b.contributionCount.compareTo(a.contributionCount),
        );

        // 順位を設定
        weeklyRankings.value = weeklyRankingsList.asMap().entries.map((entry) {
          return UserRanking(
            user: entry.value.user,
            contributionCount: entry.value.contributionCount,
            rank: entry.key + 1,
          );
        }).toList();

        allTimeRankings.value = allTimeRankingsList.asMap().entries.map((
          entry,
        ) {
          return UserRanking(
            user: entry.value.user,
            contributionCount: entry.value.contributionCount,
            rank: entry.key + 1,
          );
        }).toList();
      } catch (e) {
        // エラーを無視（既にエラーハンドリング済み）
      }
    }

    // データ取得関数（リトライ機能付き）
    Future<void> fetchFollowingUsers({bool isRefresh = false}) async {
      if (!isRefresh) {
        isLoading.value = true;
      } else {
        isRefreshing.value = true;
      }
      error.value = null;

      try {
        // 保存されているトークンを取得
        final token = await getTokenUseCase();
        if (token == null || token.value.isEmpty) {
          error.value = const AuthenticationFailure(
            'GitHubのアクセストークンが設定されていません。設定画面でトークンを設定してください。',
          );
          if (!isRefresh) {
            isLoading.value = false;
          } else {
            isRefreshing.value = false;
          }
          return;
        }

        // フォロー中のユーザー一覧を取得
        final result = await RetryHandler.executeWithRetry(
          action: () => getFollowingUsersUseCase(token.value),
          config: const RetryConfig(
            maxRetries: 2,
            initialDelay: Duration(seconds: 1),
          ),
        );

        result.fold(
          (failure) {
            error.value = failure;
          },
          (users) {
            followingUsers.value = users;
            error.value = null;
            // ランキングを計算（非同期で実行）
            if (users.isNotEmpty) {
              _calculateRankings(token.value, users);
            }
          },
        );
      } catch (e) {
        error.value = ServerFailure('予期しないエラーが発生しました: $e');
      } finally {
        if (!isRefresh) {
          isLoading.value = false;
        } else {
          isRefreshing.value = false;
        }
        isRetrying.value = false;
      }
    }

    // リトライ関数
    Future<void> retryFetch() async {
      isRetrying.value = true;
      await fetchFollowingUsers(isRefresh: true);
    }

    // 初期化時にデータを取得
    useEffect(() {
      fetchFollowingUsers();
      return null;
    }, []);

    return Scaffold(
      extendBody: true,
      body: GeometricBackground(
        child: Stack(
          children: [
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () => fetchFollowingUsers(isRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ヘッダー
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: textColor),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'フォロー中のユーザー',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          // ローディングインジケーター（初回読み込み時のみ）
                          if (isLoading.value && !isRefreshing.value)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SpinKitFadingCube(
                                color: AppColors.terminalGreen,
                                size: 24.0,
                              ),
                            ),
                          // ランキングデータ取得中のローディング
                          if (!isLoading.value &&
                              error.value == null &&
                              followingUsers.value.isNotEmpty &&
                              (selectedTab.value == 0
                                      ? weeklyRankings.value
                                      : allTimeRankings.value)
                                  .isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SpinKitFadingCube(
                                color: AppColors.terminalGreen,
                                size: 24.0,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // タブ切り替え
                      if (error.value == null &&
                          followingUsers.value.isNotEmpty)
                        _RankingTabs(
                          selectedIndex: selectedTab.value,
                          onTabChanged: (index) {
                            selectedTab.value = index;
                          },
                          textColor: textColor,
                        ),
                      if (error.value == null &&
                          followingUsers.value.isNotEmpty)
                        const SizedBox(height: 16),
                      // エラーメッセージ表示
                      if (error.value != null && !isLoading.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Stack(
                            children: [
                              ErrorDisplayWidget(
                                failure: error.value!,
                                onRetry: isRetrying.value ? null : retryFetch,
                              ),
                              if (isRetrying.value)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: SpinKitFadingCube(
                                        color: AppColors.terminalGreen,
                                        size: 40.0,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      // ランキング表示
                      if (error.value == null)
                        // 初回ローディング中は何も表示しない（スケルトンUIは別で表示）
                        if (isLoading.value && !isRefreshing.value)
                          _SkeletonRankingList()
                        else if (!isLoading.value &&
                            followingUsers.value.isEmpty)
                          GlassContainer(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'フォロー中のユーザーがいません',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if ((selectedTab.value == 0
                                ? weeklyRankings.value
                                : allTimeRankings.value)
                            .isEmpty)
                          _SkeletonRankingList()
                        else
                          Column(
                            children: [
                              for (
                                int i = 0;
                                i <
                                    (selectedTab.value == 0
                                        ? weeklyRankings.value.length
                                        : allTimeRankings.value.length);
                                i++
                              )
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _RankingItem(
                                    ranking: selectedTab.value == 0
                                        ? weeklyRankings.value[i]
                                        : allTimeRankings.value[i],
                                    textColor: textColor,
                                    onTap: () {
                                      context.push(
                                        '/user/${(selectedTab.value == 0 ? weeklyRankings.value[i] : allTimeRankings.value[i]).user.login}',
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// スケルトンランキングリスト
class _SkeletonRankingList extends StatelessWidget {
  const _SkeletonRankingList();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Column(
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Shimmer.fromColors(
                baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                highlightColor: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade100,
                period: const Duration(seconds: 2),
                child: Row(
                  children: [
                    // 順位のスケルトン
                    Container(
                      width: 40,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // アバターのスケルトン
                    CircleAvatar(radius: 28, backgroundColor: Colors.white),
                    const SizedBox(width: 12),
                    // ユーザー情報のスケルトン
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contribution数のスケルトン
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 11,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ランキングタブ
class _RankingTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color textColor;

  const _RankingTabs({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: '週間',
              isSelected: selectedIndex == 0,
              onTap: () => onTabChanged(0),
              textColor: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: '全期間',
              isSelected: selectedIndex == 1,
              onTap: () => onTabChanged(1),
              textColor: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// タブボタン
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.terminalGreen.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.terminalGreen : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// ランキングアイテム
class _RankingItem extends StatelessWidget {
  final UserRanking ranking;
  final Color textColor;
  final VoidCallback onTap;

  const _RankingItem({
    required this.ranking,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // 順位
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '${ranking.rank}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ranking.rank <= 3
                      ? AppColors.terminalGreen
                      : textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // アバター
            if (ranking.user.avatarUrl != null)
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(ranking.user.avatarUrl!),
              )
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: textColor.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: textColor, size: 28),
              ),
            const SizedBox(width: 12),
            // ユーザー情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ranking.user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${ranking.user.login}',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Contribution数
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ranking.contributionCount}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.terminalGreen,
                  ),
                ),
                Text(
                  'contributions',
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
