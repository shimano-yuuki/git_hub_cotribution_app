import 'package:flutter_test/flutter_test.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/user.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('User Entity', () {
    group('コンストラクタ', () {
      test('全てのフィールドが設定されたUserを作成できる', () {
        // Arrange
        const user = User(
          login: 'testuser',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          bio: 'Test bio',
          publicRepos: 10,
          followers: 20,
          following: 15,
        );

        // Assert
        expect(user.login, 'testuser');
        expect(user.name, 'Test User');
        expect(user.avatarUrl, 'https://example.com/avatar.png');
        expect(user.bio, 'Test bio');
        expect(user.publicRepos, 10);
        expect(user.followers, 20);
        expect(user.following, 15);
      });

      test('最小限のフィールドのみでUserを作成できる', () {
        // Arrange
        const user = User(
          login: 'minimaluser',
          name: 'Minimal User',
        );

        // Assert
        expect(user.login, 'minimaluser');
        expect(user.name, 'Minimal User');
        expect(user.avatarUrl, isNull);
        expect(user.bio, isNull);
        expect(user.publicRepos, isNull);
        expect(user.followers, isNull);
        expect(user.following, isNull);
      });
    });

    group('equality', () {
      test('同じ値のUserは等しい', () {
        // Arrange
        const user1 = User(
          login: 'testuser',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          bio: 'Test bio',
          publicRepos: 10,
          followers: 20,
          following: 15,
        );
        const user2 = User(
          login: 'testuser',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          bio: 'Test bio',
          publicRepos: 10,
          followers: 20,
          following: 15,
        );

        // Assert
        expect(user1, user2);
        expect(user1.hashCode, user2.hashCode);
      });

      test('異なるloginのUserは等しくない', () {
        // Arrange
        const user1 = User(
          login: 'user1',
          name: 'User 1',
        );
        const user2 = User(
          login: 'user2',
          name: 'User 1',
        );

        // Assert
        expect(user1, isNot(user2));
      });

      test('異なるnameのUserは等しくない', () {
        // Arrange
        const user1 = User(
          login: 'testuser',
          name: 'User 1',
        );
        const user2 = User(
          login: 'testuser',
          name: 'User 2',
        );

        // Assert
        expect(user1, isNot(user2));
      });

      test('nullフィールドを含むUserも正しく比較される', () {
        // Arrange
        const user1 = User(
          login: 'testuser',
          name: 'Test User',
          avatarUrl: null,
          bio: null,
          publicRepos: null,
          followers: null,
          following: null,
        );
        const user2 = User(
          login: 'testuser',
          name: 'Test User',
        );

        // Assert
        expect(user1, user2);
      });
    });

    group('境界値テスト', () {
      test('空文字列のloginとnameでUserを作成できる', () {
        // Arrange
        const user = User(
          login: '',
          name: '',
        );

        // Assert
        expect(user.login, '');
        expect(user.name, '');
      });

      test('非常に長い文字列でもUserを作成できる', () {
        // Arrange
        final longString = 'a' * 1000;
        final user = User(
          login: longString,
          name: longString,
        );

        // Assert
        expect(user.login, longString);
        expect(user.name, longString);
      });

      test('ゼロ値の数値フィールドでUserを作成できる', () {
        // Arrange
        const user = User(
          login: 'testuser',
          name: 'Test User',
          publicRepos: 0,
          followers: 0,
          following: 0,
        );

        // Assert
        expect(user.publicRepos, 0);
        expect(user.followers, 0);
        expect(user.following, 0);
      });
    });

    group('TestDataヘルパー', () {
      test('validUserが正しく作成される', () {
        // Arrange
        final user = TestData.validUser();

        // Assert
        expect(user.login, 'testuser');
        expect(user.name, 'Test User');
        expect(user.avatarUrl, isNotNull);
        expect(user.bio, isNotNull);
      });

      test('minimalUserが正しく作成される', () {
        // Arrange
        final user = TestData.minimalUser();

        // Assert
        expect(user.login, 'minimaluser');
        expect(user.name, 'Minimal User');
        expect(user.avatarUrl, isNull);
      });
    });
  });
}

