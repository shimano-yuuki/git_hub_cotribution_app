import '../../domain/entities/user.dart';

/// GitHubユーザー情報のJSONモデル
class UserModel extends User {
  const UserModel({
    required super.login,
    required super.name,
    super.avatarUrl,
    super.bio,
    super.publicRepos,
    super.followers,
    super.following,
  });

  /// JSONからUserModelを作成
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      login: json['login'] as String,
      name: json['name'] as String? ?? json['login'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      publicRepos: json['public_repos'] as int?,
      followers: json['followers'] as int?,
      following: json['following'] as int?,
    );
  }

  /// UserModelをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
    };
  }

  /// Entityに変換
  User toEntity() {
    return User(
      login: login,
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
      publicRepos: publicRepos,
      followers: followers,
      following: following,
    );
  }
}








