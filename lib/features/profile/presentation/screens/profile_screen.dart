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
import '../../../../shared/widgets/animated_fade_in.dart';
import '../../../../shared/widgets/loading_animation.dart';
import 'dart:math' as math;

class ProfileScreen extends HookWidget {
  final ValueChanged<bool>? onLoadingChanged;

  const ProfileScreen({super.key, this.onLoadingChanged});

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
    final isRefreshing = useState<bool>(false);
    final error = useState<String?>(null);
    final selectedYear = useState<int>(DateTime.now().year);
    final lastUpdated = useState<DateTime?>(null);
    final isOffline = useState<bool>(false);

    // ローディング状態の変更を通知（ビルド完了後に実行）
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onLoadingChanged?.call(isLoading.value);
      });
      return null;
    }, [isLoading.value]);

    // データ取得関数
    Future<void> fetchContributions({bool isRefresh = false}) async {
      if (!isRefresh) {
        isLoading.value = true;
      } else {
        isRefreshing.value = true;
      }
      error.value = null;
      isOffline.value = false;

      try {
        // 保存されているトークンを取得
        final token = await getTokenUseCase();
        if (token == null || token.value.isEmpty) {
          // トークンが保存されていない場合はモックデータを使用
          final mockData = _generateMockContributions();
          contributions.value = mockData;
          lastUpdated.value = null;
          if (!isRefresh) {
            isLoading.value = false;
          } else {
            isRefreshing.value = false;
          }
          return;
        }

        // まずキャッシュから取得（初回読み込み時のみ）
        if (!isRefresh && contributions.value.isEmpty) {
          final cachedResult = await githubRepository.getCachedContributions(
            selectedYear.value,
          );
          cachedResult.fold((_) {}, (cachedData) {
            if (cachedData.isNotEmpty) {
              contributions.value = cachedData;
              // 最終更新日時を取得
              githubRepository
                  .getLastUpdated(selectedYear.value)
                  .then((date) => lastUpdated.value = date);
            }
          });
        }

        // リモートからデータを取得
        final result = await getContributionsUseCase(
          token.value,
          selectedYear.value,
        );

        result.fold(
          (failure) {
            // ネットワークエラーの場合
            if (failure.message.contains('オフライン') ||
                failure.message.contains('ネットワーク') ||
                failure.message.contains('接続')) {
              isOffline.value = true;
              error.value = failure.message;

              // キャッシュから取得を試みる
              if (contributions.value.isEmpty) {
                githubRepository
                    .getCachedContributions(selectedYear.value)
                    .then((cachedResult) {
                      cachedResult.fold((_) {}, (cachedData) {
                        if (cachedData.isNotEmpty) {
                          contributions.value = cachedData;
                          githubRepository
                              .getLastUpdated(selectedYear.value)
                              .then((date) => lastUpdated.value = date);
                        }
                      });
                    });
              }
            } else {
              error.value = failure.message;
            }
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

            // 最終更新日時を取得
            githubRepository
                .getLastUpdated(selectedYear.value)
                .then((date) => lastUpdated.value = date);

            error.value = null;
            isOffline.value = false;
          },
        );
      } catch (e) {
        error.value = 'Contributionデータの取得に失敗しました: $e';
        isOffline.value = true;

        // キャッシュから取得を試みる
        if (contributions.value.isEmpty) {
          githubRepository.getCachedContributions(selectedYear.value).then((
            cachedResult,
          ) {
            cachedResult.fold((_) {}, (cachedData) {
              if (cachedData.isNotEmpty) {
                contributions.value = cachedData;
                githubRepository
                    .getLastUpdated(selectedYear.value)
                    .then((date) => lastUpdated.value = date);
              }
            });
          });
        }
      } finally {
        if (!isRefresh) {
          isLoading.value = false;
        } else {
          isRefreshing.value = false;
        }
      }
    }

    // 初期化時にContributionデータを取得
    useEffect(() {
      fetchContributions();
      return null;
    }, [selectedYear.value]);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => fetchContributions(isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Contributionカレンダーセクション
                AnimatedFadeSlideIn(
                  delay: 100.0,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            // 最終更新日時表示
                            if (lastUpdated.value != null)
                              AnimatedFadeIn(
                                delay: 200.0,
                                child: Text(
                                  _formatLastUpdated(lastUpdated.value!),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // オフライン/エラーメッセージ表示
                        if (isOffline.value)
                          AnimatedFadeIn(
                            delay: 300.0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.wifi_off,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error.value ??
                                          'オフラインです。キャッシュされたデータを表示しています。',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (error.value != null && !isOffline.value)
                          AnimatedFadeIn(
                            delay: 300.0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                error.value!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        // カレンダーウィジェット
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child:
                              !isLoading.value && contributions.value.isNotEmpty
                              ? ContributionCalendarWidget(
                                  key: const ValueKey('calendar'),
                                  contributions: contributions.value,
                                  initialYear: selectedYear.value,
                                  onYearChanged: (newYear) {
                                    selectedYear.value = newYear;
                                  },
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
        // ローディングオーバーレイ（初回読み込み時のみ）
        if (isLoading.value && !isRefreshing.value)
          AbsorbPointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(child: ThemedLoadingAnimation(size: 80.0)),
            ),
          ),
      ],
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

  /// 最終更新日時をフォーマット
  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'たった今更新';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前更新';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前更新';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前更新';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}更新';
    }
  }
}
