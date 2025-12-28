/// GitHubユーザー情報エンティティ
class User {
  final String login;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final int? publicRepos;
  final int? followers;
  final int? following;

  const User({
    required this.login,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.publicRepos,
    this.followers,
    this.following,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          login == other.login &&
          name == other.name &&
          avatarUrl == other.avatarUrl &&
          bio == other.bio &&
          publicRepos == other.publicRepos &&
          followers == other.followers &&
          following == other.following;

  @override
  int get hashCode =>
      login.hashCode ^
      name.hashCode ^
      avatarUrl.hashCode ^
      bio.hashCode ^
      publicRepos.hashCode ^
      followers.hashCode ^
      following.hashCode;
}


