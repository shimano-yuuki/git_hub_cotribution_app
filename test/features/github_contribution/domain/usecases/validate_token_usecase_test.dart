import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:git_hub_contribution_app/core/error/failures.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/repositories/github_repository.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/usecases/validate_token_usecase.dart';

import 'validate_token_usecase_test.mocks.dart';

@GenerateMocks([GithubRepository])
import '../../../../helpers/mockito_helpers.dart';

void main() {
  setupMockitoDummies();


  group('ValidateTokenUseCase', () {
    late ValidateTokenUseCase useCase;
    late MockGithubRepository mockRepository;

    setUp(() {
      mockRepository = MockGithubRepository();
      useCase = ValidateTokenUseCase(mockRepository);
    });

    group('正常系', () {
      test('有効なtokenの場合、trueを返す', () async {
        // Arrange
        const token = 'valid_token';
        when(mockRepository.validateToken(token))
            .thenAnswer((_) async => const Right(true));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('エラーが発生すべきではありません'),
          (isValid) => expect(isValid, true),
        );
        verify(mockRepository.validateToken(token)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('無効なtokenの場合、falseを返す', () async {
        // Arrange
        const token = 'invalid_token';
        when(mockRepository.validateToken(token))
            .thenAnswer((_) async => const Right(false));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('エラーが発生すべきではありません'),
          (isValid) => expect(isValid, false),
        );
        verify(mockRepository.validateToken(token)).called(1);
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
        result.fold(
          (failure) {
            expect(failure, isA<AuthenticationFailure>());
            expect(failure.message, 'トークンが入力されていません');
          },
          (isValid) => fail('エラーが発生すべきです'),
        );
        verifyNever(mockRepository.validateToken(any));
      });

      test('ServerFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const failure = ServerFailure('サーバーエラーが発生しました');
        when(mockRepository.validateToken(token))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failureResult) {
            expect(failureResult, isA<ServerFailure>());
            expect(failureResult.message, 'サーバーエラーが発生しました');
          },
          (isValid) => fail('エラーが発生すべきです'),
        );
        verify(mockRepository.validateToken(token)).called(1);
      });

      test('NetworkFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const failure = NetworkFailure('ネットワークエラーが発生しました');
        when(mockRepository.validateToken(token))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failureResult) {
            expect(failureResult, isA<NetworkFailure>());
            expect(failureResult.message, 'ネットワークエラーが発生しました');
          },
          (isValid) => fail('エラーが発生すべきです'),
        );
        verify(mockRepository.validateToken(token)).called(1);
      });

      test('AuthenticationFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'invalid_token';
        const failure = AuthenticationFailure('認証に失敗しました');
        when(mockRepository.validateToken(token))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failureResult) {
            expect(failureResult, isA<AuthenticationFailure>());
            expect(failureResult.message, '認証に失敗しました');
          },
          (isValid) => fail('エラーが発生すべきです'),
        );
        verify(mockRepository.validateToken(token)).called(1);
      });
    });

    group('境界値テスト', () {
      test('非常に長いtokenで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        final longToken = 'a' * 1000;
        when(mockRepository.validateToken(longToken))
            .thenAnswer((_) async => const Right(true));

        // Act
        final result = await useCase.call(longToken);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.validateToken(longToken)).called(1);
      });
    });
  });
}

