/// GitHubのContributionデータを表すエンティティ
class Contribution {
  /// 日付
  final DateTime date;

  /// Contribution数
  final int count;

  const Contribution({required this.date, required this.count});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contribution &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          count == other.count;

  @override
  int get hashCode => date.hashCode ^ count.hashCode;
}
