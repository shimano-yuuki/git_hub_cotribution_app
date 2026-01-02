import 'user.dart';

/// ユーザーランキング情報を表すエンティティ
class UserRanking {
  final User user;
  final int contributionCount;
  final int rank;

  const UserRanking({
    required this.user,
    required this.contributionCount,
    required this.rank,
  });
}
