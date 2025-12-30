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
            contributions.value = _generateMockContributions();
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
              contributions.value = _generateMockContributions();
            },
            (data) {
              contributions.value = data;
              error.value = null;
            },
          );
        } catch (e) {
          error.value = 'Contributionデータの取得に失敗しました: $e';
          // エラー時はモックデータを使用
          contributions.value = _generateMockContributions();
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
          const SizedBox(height: 64),
          // Contributionカレンダーセクション
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 200,
                      maxHeight: 400,
                    ),
                    child: ContributionCalendarWidget(
                      contributions: contributions.value,
                      initialYear: selectedYear.value,
                      onYearChanged: (newYear) {
                        selectedYear.value = newYear;
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // 凡例
                _buildLegend(brightness, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 凡例を構築
  Widget _buildLegend(Brightness brightness, Color textColor) {
    return Row(
      children: [
        Text(
          'Less',
          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final count = index * 5;
          final color = _getLegendColor(count, brightness);
          return Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
        ),
      ],
    );
  }

  /// 凡例用の色を取得
  Color _getLegendColor(int count, Brightness brightness) {
    if (brightness == Brightness.dark) {
      if (count == 0) {
        return Colors.grey; // グレー
      } else if (count <= 3) {
        return const Color(0xFF0E4429);
      } else if (count <= 9) {
        return const Color(0xFF006D32);
      } else if (count <= 19) {
        return const Color(0xFF26A641);
      } else {
        return const Color(0xFF39D353);
      }
    } else {
      if (count == 0) {
        return Colors.grey; // グレー
      } else if (count <= 3) {
        return const Color(0xFF9BE9A8);
      } else if (count <= 9) {
        return const Color(0xFF40C463);
      } else if (count <= 19) {
        return const Color(0xFF30A14E);
      } else {
        return const Color(0xFF216E39);
      }
    }
  }

  /// モックContributionデータを生成（テスト用）
  List<Contribution> _generateMockContributions() {
    final contributions = <Contribution>[];
    final today = DateTime.now();
    final random = math.Random();

    // 過去1年間のデータを生成
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      // ランダムにContribution数を生成（0-25の範囲、ただし0の確率を高くする）
      final count = random.nextInt(100) < 60 ? 0 : random.nextInt(25);

      contributions.add(Contribution(date: date, count: count));
    }

    return contributions;
  }
}
