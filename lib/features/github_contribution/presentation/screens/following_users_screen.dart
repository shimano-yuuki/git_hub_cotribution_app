import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/retry_handler.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_following_users_usecase.dart';
import '../../../settings/domain/usecases/get_token_usecase.dart';
import '../../../settings/data/repositories/token_repository_impl.dart';
import '../../../settings/data/datasources/token_local_datasource.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/animated_fade_in.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../../../../shared/widgets/error_display_widget.dart';
import '../../../../shared/widgets/geometric_background.dart';

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

    // 状態管理
    final followingUsers = useState<List<User>>([]);
    final isLoading = useState<bool>(true);
    final isRefreshing = useState<bool>(false);
    final error = useState<Failure?>(null);
    final isRetrying = useState<bool>(false);

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
        child: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => fetchFollowingUsers(isRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ヘッダー
                      AnimatedFadeIn(
                        delay: 100.0,
                        child: Row(
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // エラーメッセージ表示
                      if (error.value != null && !isLoading.value)
                        AnimatedFadeIn(
                          delay: 100.0,
                          child: Padding(
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
                      // ユーザー一覧
                      if (!isLoading.value && error.value == null)
                        followingUsers.value.isEmpty
                            ? AnimatedFadeIn(
                                delay: 100.0,
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: textColor.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'フォロー中のユーザーがいません',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : AnimatedFadeIn(
                                delay: 100.0,
                                child: Column(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < followingUsers.value.length;
                                      i++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: AnimatedFadeIn(
                                          delay: 50.0 * (i + 1),
                                          child: _UserListItem(
                                            user: followingUsers.value[i],
                                            textColor: textColor,
                                            onTap: () {
                                              context.push(
                                                '/user/${followingUsers.value[i].login}',
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ),
              // ローディングインジケーター（初回読み込み時のみ）
              if (isLoading.value && !isRefreshing.value)
                Center(child: ThemedLoadingAnimation(size: 80.0)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ユーザーリストアイテム
class _UserListItem extends StatelessWidget {
  final User user;
  final Color textColor;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
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
            // アバター
            if (user.avatarUrl != null)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.avatarUrl!),
              )
            else
              CircleAvatar(
                radius: 30,
                backgroundColor: textColor.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: textColor, size: 30),
              ),
            const SizedBox(width: 16),
            // ユーザー情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.login}',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
