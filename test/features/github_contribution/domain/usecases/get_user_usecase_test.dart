import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:git_hub_contribution_app/core/error/failures.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/repositories/github_repository.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/usecases/get_user_usecase.dart';
import '../../../../fixtures/test_data.dart';

import 'get_user_usecase_test.mocks.dart';

import '../../../../helpers/mockito_helpers.dart';

@GenerateMocks([GithubRepository])
void main() {
  setupMockitoDummies();

  group('GetUserUseCase', () {
    late GetUserUseCase useCase;
    late MockGithubRepository mockRepository;

    setUp(() {
      mockRepository = MockGithubRepository();
      useCase = GetUserUseCase(mockRepository);
    });

    group('正常系', () {
      test('有効なtokenとusernameでUserを取得できる', () async {
        // Arrange
        const token = 'valid_token';
        const username = 'testuser';
        final user = TestData.validUser();
        when(
          mockRepository.getUser(token, username),
        ).thenAnswer((_) async => Right(user));

        // Act
        final result = await useCase.call(token, username);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('エラーが発生すべきではありません'), (userResult) {
          expect(userResult.login, 'testuser');
          expect(userResult.name, 'Test User');
        });
        verify(mockRepository.getUser(token, username)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('異常系', () {
      test('ServerFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const username = 'testuser';
        const failure = ServerFailure('サーバーエラーが発生しました');
        when(
          mockRepository.getUser(token, username),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, username);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<ServerFailure>());
          expect(failureResult.message, 'サーバーエラーが発生しました');
        }, (user) => fail('エラーが発生すべきです'));
        verify(mockRepository.getUser(token, username)).called(1);
      });

      test('NetworkFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const username = 'testuser';
        const failure = NetworkFailure('ネットワークエラーが発生しました');
        when(
          mockRepository.getUser(token, username),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, username);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<NetworkFailure>());
          expect(failureResult.message, 'ネットワークエラーが発生しました');
        }, (user) => fail('エラーが発生すべきです'));
        verify(mockRepository.getUser(token, username)).called(1);
      });

      test('AuthenticationFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'invalid_token';
        const username = 'testuser';
        const failure = AuthenticationFailure('認証に失敗しました');
        when(
          mockRepository.getUser(token, username),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, username);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<AuthenticationFailure>());
          expect(failureResult.message, '認証に失敗しました');
        }, (user) => fail('エラーが発生すべきです'));
        verify(mockRepository.getUser(token, username)).called(1);
      });
    });

    group('境界値テスト', () {
      test('空文字列のusernameで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        const token = 'valid_token';
        const username = '';
        const failure = ServerFailure('ユーザーが見つかりません');
        when(
          mockRepository.getUser(token, username),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, username);

        // Assert
        expect(result.isLeft(), true);
        verify(mockRepository.getUser(token, username)).called(1);
      });

      test('非常に長いusernameで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        const token = 'valid_token';
        final longUsername = 'a' * 1000;
        final user = TestData.validUser();
        when(
          mockRepository.getUser(token, longUsername),
        ).thenAnswer((_) async => Right(user));

        // Act
        final result = await useCase.call(token, longUsername);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.getUser(token, longUsername)).called(1);
      });
    });
  });
}
