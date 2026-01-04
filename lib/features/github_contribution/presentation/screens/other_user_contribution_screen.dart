import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/retry_handler.dart';
import '../widgets/contribution_calendar_widget.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_contributions_usecase.dart';
import '../../domain/usecases/get_user_usecase.dart';
import '../../../settings/domain/usecases/get_token_usecase.dart';
import '../../../settings/data/repositories/token_repository_impl.dart';
import '../../../settings/data/datasources/token_local_datasource.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/animated_fade_in.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../../../../shared/widgets/error_display_widget.dart';
import '../../../../shared/widgets/statistics_button.dart';
import '../../../../shared/widgets/geometric_background.dart';
import '../../domain/usecases/calculate_contribution_statistics_usecase.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 他ユーザーのContribution画面
class OtherUserContributionScreen extends HookWidget {
  final String username;

  const OtherUserContributionScreen({super.key, required this.username});

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
    final getUserUseCase = useMemoized(() => GetUserUseCase(githubRepository));
    final getUserContributionsUseCase = useMemoized(
      () => GetUserContributionsUseCase(githubRepository),
    );
    final calculateStatisticsUseCase = useMemoized(
      () => CalculateContributionStatisticsUseCase(),
    );

    // 状態管理
    final user = useState<User?>(null);
    final contributions = useState<List<Contribution>>([]);
    final isLoading = useState<bool>(true);
    final isRefreshing = useState<bool>(false);
    final error = useState<Failure?>(null);
    final selectedYear = useState<int>(DateTime.now().year);
    final isRetrying = useState<bool>(false);

    // データ取得関数（リトライ機能付き）
    Future<void> fetchUserData({bool isRefresh = false}) async {
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

        // ユーザー情報を取得
        final userResult = await getUserUseCase(token.value, username);
        userResult.fold(
          (failure) {
            error.value = failure;
          },
          (userData) {
            user.value = userData;
          },
        );

        // Contributionデータを取得
        if (error.value == null) {
          final result = await RetryHandler.executeWithRetry(
            action: () => getUserContributionsUseCase(
              token.value,
              username,
              selectedYear.value,
            ),
            config: const RetryConfig(
              maxRetries: 2,
              initialDelay: Duration(seconds: 1),
            ),
          );

          result.fold(
            (failure) {
              error.value = failure;
            },
            (data) {
              contributions.value = data;
              error.value = null;
            },
          );
        }
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
      await fetchUserData(isRefresh: true);
    }

    // 初期化時にデータを取得
    useEffect(() {
      fetchUserData();
      return null;
    }, [selectedYear.value]);

    return Scaffold(
      extendBody: true,
      body: GeometricBackground(
        child: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => fetchUserData(isRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // ヘッダー
                      AnimatedFadeIn(
                        delay: 100.0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: textColor),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.value?.name ?? username,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ユーザー情報セクション
                      if (user.value != null && !isLoading.value)
                        AnimatedFadeIn(
                          delay: 100.0,
                          child: GlassContainer(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // アバター
                                if (user.value!.avatarUrl != null)
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(
                                      user.value!.avatarUrl!,
                                    ),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: textColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: textColor,
                                      size: 40,
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                // ユーザー情報
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.value!.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '@${user.value!.login}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      if (user.value!.bio != null &&
                                          user.value!.bio!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          user.value!.bio!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textColor.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (user.value != null && !isLoading.value)
                        const SizedBox(height: 24),
                      // Contributionカレンダーセクション
                      if (!isLoading.value)
                        AnimatedFadeIn(
                          delay: 150.0,
                          child: GlassContainer(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AnimatedFadeIn(
                                      delay: 200.0,
                                      child: Text(
                                        'Contribution Calendar',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // エラーメッセージ表示
                                if (error.value != null && !isLoading.value)
                                  AnimatedFadeIn(
                                    delay: 300.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Stack(
                                        children: [
                                          ErrorDisplayWidget(
                                            failure: error.value!,
                                            onRetry: isRetrying.value
                                                ? null
                                                : retryFetch,
                                          ),
                                          if (isRetrying.value)
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: const Center(
                                                  child: ThemedLoadingAnimation(
                                                    size: 40.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // カレンダーウィジェットまたはエラー表示
                                if (!isLoading.value &&
                                    error.value == null &&
                                    contributions.value.isNotEmpty)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: ContributionCalendarWidget(
                                      key: const ValueKey('calendar'),
                                      contributions: contributions.value,
                                      initialYear: selectedYear.value,
                                      onYearChanged: (newYear) {
                                        selectedYear.value = newYear;
                                      },
                                    ),
                                  )
                                else if (!isLoading.value &&
                                    error.value == null &&
                                    contributions.value.isEmpty)
                                  AnimatedFadeIn(
                                    delay: 300.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: ErrorDisplayWidget(
                                        failure: const CacheFailure(
                                          'データが見つかりませんでした。',
                                        ),
                                        onRetry: isRetrying.value
                                            ? null
                                            : retryFetch,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // 統計データ確認ボタン
                                if (!isLoading.value &&
                                    contributions.value.isNotEmpty)
                                  StatisticsButton(
                                    statistics: calculateStatisticsUseCase(
                                      contributions.value,
                                    ),
                                    year: selectedYear.value,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ),
              // ローディングインジケーター（初回読み込み時のみ）
              if (isLoading.value && !isRefreshing.value)
                Center(
                  child: SpinKitFadingCube(
                    color: AppColors.accentColor(brightness),
                    size: 80.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
