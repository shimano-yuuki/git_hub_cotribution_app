import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:git_hub_contribution_app/core/error/failures.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/repositories/github_repository.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/usecases/get_authenticated_user_usecase.dart';
import '../../../../fixtures/test_data.dart';

import 'get_authenticated_user_usecase_test.mocks.dart';

import '../../../../helpers/mockito_helpers.dart';

@GenerateMocks([GithubRepository])
void main() {
  setupMockitoDummies();

  group('GetAuthenticatedUserUseCase', () {
    late GetAuthenticatedUserUseCase useCase;
    late MockGithubRepository mockRepository;

    setUp(() {
      mockRepository = MockGithubRepository();
      useCase = GetAuthenticatedUserUseCase(mockRepository);
    });

    group('正常系', () {
      test('有効なtokenでUserを取得できる', () async {
        // Arrange
        const token = 'valid_token';
        final user = TestData.validUser();
        when(
          mockRepository.getAuthenticatedUser(token),
        ).thenAnswer((_) async => Right(user));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('エラーが発生すべきではありません'), (userResult) {
          expect(userResult.login, 'testuser');
          expect(userResult.name, 'Test User');
        });
        verify(mockRepository.getAuthenticatedUser(token)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('異常系', () {
      test('空文字列のtokenの場合、AuthenticationFailureを返す', () async {
        // Arrange
        const token = '';

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<AuthenticationFailure>());
          expect(failure.message, 'トークンが入力されていません');
        }, (user) => fail('エラーが発生すべきです'));
        verifyNever(mockRepository.getAuthenticatedUser(any));
      });

      test('ServerFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const failure = ServerFailure('サーバーエラーが発生しました');
        when(
          mockRepository.getAuthenticatedUser(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<ServerFailure>());
          expect(failureResult.message, 'サーバーエラーが発生しました');
        }, (user) => fail('エラーが発生すべきです'));
        verify(mockRepository.getAuthenticatedUser(token)).called(1);
      });

      test('NetworkFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const failure = NetworkFailure('ネットワークエラーが発生しました');
        when(
          mockRepository.getAuthenticatedUser(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<NetworkFailure>());
          expect(failureResult.message, 'ネットワークエラーが発生しました');
        }, (user) => fail('エラーが発生すべきです'));
        verify(mockRepository.getAuthenticatedUser(token)).called(1);
      });

      test('AuthenticationFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'invalid_token';
        const failure = AuthenticationFailure('認証に失敗しました');
        when(
          mockRepository.getAuthenticatedUser(token),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<AuthenticationFailure>());
          expect(failureResult.message, '認証に失敗しました');
        }, (user) => fail('エラーが発生すべきです'));
        verify(mockRepository.getAuthenticatedUser(token)).called(1);
      });
    });

    group('境界値テスト', () {
      test('非常に長いtokenで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        final longToken = 'a' * 1000;
        final user = TestData.validUser();
        when(
          mockRepository.getAuthenticatedUser(longToken),
        ).thenAnswer((_) async => Right(user));

        // Act
        final result = await useCase.call(longToken);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.getAuthenticatedUser(longToken)).called(1);
      });
    });
  });
}
