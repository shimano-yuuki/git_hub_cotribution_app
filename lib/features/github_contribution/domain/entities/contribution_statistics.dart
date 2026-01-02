/// Contribution統計情報を表すエンティティ
class ContributionStatistics {
  /// 総Contribution数
  final int totalContributions;

  /// 現在のストリーク（連続日数）
  final int currentStreak;

  /// 最長ストリーク（連続日数）
  final int longestStreak;

  /// 今年のContribution数
  final int thisYearContributions;

  /// 今週のContribution数
  final int thisWeekContributions;

  const ContributionStatistics({
    required this.totalContributions,
    required this.currentStreak,
    required this.longestStreak,
    required this.thisYearContributions,
    required this.thisWeekContributions,
  });
}

