import '../entities/contribution.dart';
import '../entities/contribution_statistics.dart';

/// Contribution統計情報を計算するUseCase
class CalculateContributionStatisticsUseCase {
  /// Contributionリストから統計情報を計算する
  ///
  /// [contributions] Contributionデータのリスト
  ///
  /// Returns [ContributionStatistics] 統計情報
  ContributionStatistics call(List<Contribution> contributions) {
    if (contributions.isEmpty) {
      return const ContributionStatistics(
        totalContributions: 0,
        currentStreak: 0,
        longestStreak: 0,
        thisYearContributions: 0,
        thisWeekContributions: 0,
      );
    }

    // 日付でソート（古い順）
    final sortedContributions = List<Contribution>.from(contributions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 総Contribution数を計算
    final totalContributions = sortedContributions.fold<int>(
      0,
      (sum, contribution) => sum + contribution.count,
    );

    // 今日の日付を取得
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // 今年の開始日
    final thisYearStart = DateTime(today.year, 1, 1);

    // 今週の開始日（月曜日）
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisWeekStartNormalized = DateTime(
      thisWeekStart.year,
      thisWeekStart.month,
      thisWeekStart.day,
    );

    // 今年のContribution数を計算
    final thisYearContributions = sortedContributions
        .where((c) {
          final cDate = DateTime(c.date.year, c.date.month, c.date.day);
          return !cDate.isBefore(thisYearStart);
        })
        .fold<int>(0, (sum, contribution) => sum + contribution.count);

    // 今週のContribution数を計算
    final thisWeekContributions = sortedContributions
        .where((c) {
          final cDate = DateTime(c.date.year, c.date.month, c.date.day);
          return !cDate.isBefore(thisWeekStartNormalized);
        })
        .fold<int>(0, (sum, contribution) => sum + contribution.count);

    // ストリークを計算
    final streakResult = _calculateStreaks(sortedContributions, todayNormalized);

    return ContributionStatistics(
      totalContributions: totalContributions,
      currentStreak: streakResult.currentStreak,
      longestStreak: streakResult.longestStreak,
      thisYearContributions: thisYearContributions,
      thisWeekContributions: thisWeekContributions,
    );
  }

  /// ストリークを計算する
  _StreakResult _calculateStreaks(
    List<Contribution> contributions,
    DateTime today,
  ) {
    if (contributions.isEmpty) {
      return const _StreakResult(currentStreak: 0, longestStreak: 0);
    }

    // Contributionがある日付のセットを作成
    final contributionDates = <DateTime>{};
    for (final contribution in contributions) {
      if (contribution.count > 0) {
        final normalizedDate = DateTime(
          contribution.date.year,
          contribution.date.month,
          contribution.date.day,
        );
        contributionDates.add(normalizedDate);
      }
    }

    if (contributionDates.isEmpty) {
      return const _StreakResult(currentStreak: 0, longestStreak: 0);
    }

    // 現在のストリークを計算（今日から過去に向かって）
    int currentStreak = 0;
    DateTime checkDate = today;
    while (contributionDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // 今日がContributionがない場合は、昨日から計算
    if (currentStreak == 0 && contributionDates.contains(today.subtract(const Duration(days: 1)))) {
      checkDate = today.subtract(const Duration(days: 1));
      while (contributionDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // 最長ストリークを計算
    int longestStreak = 0;
    int currentLongestStreak = 0;
    DateTime? lastDate;

    // 日付をソート
    final sortedDates = contributionDates.toList()..sort();

    for (final date in sortedDates) {
      if (lastDate == null) {
        currentLongestStreak = 1;
      } else {
        final daysDifference = date.difference(lastDate).inDays;
        if (daysDifference == 1) {
          // 連続している
          currentLongestStreak++;
        } else {
          // 連続が途切れた
          if (currentLongestStreak > longestStreak) {
            longestStreak = currentLongestStreak;
          }
          currentLongestStreak = 1;
        }
      }
      lastDate = date;
    }

    // 最後のストリークをチェック
    if (currentLongestStreak > longestStreak) {
      longestStreak = currentLongestStreak;
    }

    return _StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }
}

/// ストリーク計算結果
class _StreakResult {
  final int currentStreak;
  final int longestStreak;

  const _StreakResult({
    required this.currentStreak,
    required this.longestStreak,
  });
}



