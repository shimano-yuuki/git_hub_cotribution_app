import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:git_hub_contribution_app/core/error/failures.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/user.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/repositories/github_repository.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/usecases/get_following_users_usecase.dart';
import '../../../../fixtures/test_data.dart';

import 'get_following_users_usecase_test.mocks.dart';
import '../../../../helpers/mockito_helpers.dart';

@GenerateMocks([GithubRepository])
void main() {
  setupMockitoDummies();

  group('GetFollowingUsersUseCase', () {
    late GetFollowingUsersUseCase useCase;
    late MockGithubRepository mockRepository;

    setUp(() {
      mockRepository = MockGithubRepository();
      useCase = GetFollowingUsersUseCase(mockRepository);
    });

    group('正常系', () {
      test('有効なtokenでUserリストを取得できる', () async {
        // Arrange
        const token = 'valid_token';
        final users = TestData.userList();
        when(
          mockRepository.getFollowingUsers(token),
        ).thenAnswer((_) async => Right(users));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('エラーが発生すべきではありません'), (usersList) {
          expect(usersList.length, 3);
          expect(usersList[0].login, 'testuser');
          expect(usersList[1].login, 'user2');
          expect(usersList[2].login, 'user3');
        });
        verify(mockRepository.getFollowingUsers(token)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('空のUserリストを取得できる', () async {
        // Arrange
        const token = 'valid_token';
        final emptyUsers = <User>[];
        when(
          mockRepository.getFollowingUsers(token),
        ).thenAnswer((_) async => Right(emptyUsers));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('エラーが発生すべきではありません'),
          (usersList) => expect(usersList.isEmpty, true),
        );
        verify(mockRepository.getFollowingUsers(token)).called(1);
      });
    });

    group('異常系', () {
      test('ServerFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const failure = ServerFailure('サーバーエラーが発生しました');
        when(
          mockRepository.getFollowingUsers(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<ServerFailure>());
          expect(failureResult.message, 'サーバーエラーが発生しました');
        }, (users) => fail('エラーが発生すべきです'));
        verify(mockRepository.getFollowingUsers(token)).called(1);
      });

      test('NetworkFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const failure = NetworkFailure('ネットワークエラーが発生しました');
        when(
          mockRepository.getFollowingUsers(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<NetworkFailure>());
          expect(failureResult.message, 'ネットワークエラーが発生しました');
        }, (users) => fail('エラーが発生すべきです'));
        verify(mockRepository.getFollowingUsers(token)).called(1);
      });

      test('AuthenticationFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'invalid_token';
        const failure = AuthenticationFailure('認証に失敗しました');
        when(
          mockRepository.getFollowingUsers(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<AuthenticationFailure>());
          expect(failureResult.message, '認証に失敗しました');
        }, (users) => fail('エラーが発生すべきです'));
        verify(mockRepository.getFollowingUsers(token)).called(1);
      });
    });

    group('境界値テスト', () {
      test('空文字列のtokenで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        const token = '';
        const failure = AuthenticationFailure('認証に失敗しました');
        when(
          mockRepository.getFollowingUsers(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        verify(mockRepository.getFollowingUsers(token)).called(1);
      });

      test('非常に長いtokenで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        final longToken = 'a' * 1000;
        final users = TestData.userList();
        when(
          mockRepository.getFollowingUsers(longToken),
        ).thenAnswer((_) async => Right(users));

        // Act
        final result = await useCase.call(longToken);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.getFollowingUsers(longToken)).called(1);
      });
    });
  });
}
