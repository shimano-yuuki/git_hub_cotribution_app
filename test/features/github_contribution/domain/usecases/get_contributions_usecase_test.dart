import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:git_hub_contribution_app/core/error/failures.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/repositories/github_repository.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/usecases/get_contributions_usecase.dart';
import '../../../../fixtures/test_data.dart';

import 'get_contributions_usecase_test.mocks.dart';

import '../../../../helpers/mockito_helpers.dart';

@GenerateMocks([GithubRepository])
void main() {
  setupMockitoDummies();

  group('GetContributionsUseCase', () {
    late GetContributionsUseCase useCase;
    late MockGithubRepository mockRepository;

    setUp(() {
      mockRepository = MockGithubRepository();
      useCase = GetContributionsUseCase(mockRepository);
    });

    group('正常系', () {
      test('有効なtokenとyearでContributionリストを取得できる', () async {
        // Arrange
        const token = 'valid_token';
        const year = 2024;
        final contributions = TestData.contributionList();
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => Right(contributions));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('エラーが発生すべきではありません'), (contributionsList) {
          expect(contributionsList.length, 5);
          expect(contributionsList[0].count, 5);
        });
        verify(mockRepository.getContributions(token, year)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('空のContributionリストを取得できる', () async {
        // Arrange
        const token = 'valid_token';
        const year = 2024;
        final emptyContributions = TestData.emptyContributionList();
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => Right(emptyContributions));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('エラーが発生すべきではありません'),
          (contributionsList) => expect(contributionsList.isEmpty, true),
        );
        verify(mockRepository.getContributions(token, year)).called(1);
      });
    });

    group('異常系', () {
      test('ServerFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const year = 2024;
        const failure = ServerFailure('サーバーエラーが発生しました');
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<ServerFailure>());
          expect(failureResult.message, 'サーバーエラーが発生しました');
        }, (contributions) => fail('エラーが発生すべきです'));
        verify(mockRepository.getContributions(token, year)).called(1);
      });

      test('NetworkFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'valid_token';
        const year = 2024;
        const failure = NetworkFailure('ネットワークエラーが発生しました');
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<NetworkFailure>());
          expect(failureResult.message, 'ネットワークエラーが発生しました');
        }, (contributions) => fail('エラーが発生すべきです'));
        verify(mockRepository.getContributions(token, year)).called(1);
      });

      test('AuthenticationFailureが発生した場合、Leftを返す', () async {
        // Arrange
        const token = 'invalid_token';
        const year = 2024;
        const failure = AuthenticationFailure('認証に失敗しました');
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failureResult) {
          expect(failureResult, isA<AuthenticationFailure>());
          expect(failureResult.message, '認証に失敗しました');
        }, (contributions) => fail('エラーが発生すべきです'));
        verify(mockRepository.getContributions(token, year)).called(1);
      });
    });

    group('境界値テスト', () {
      test('最小のyear値（例: 1970）で取得できる', () async {
        // Arrange
        const token = 'valid_token';
        const year = 1970;
        final contributions = TestData.contributionList();
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => Right(contributions));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.getContributions(token, year)).called(1);
      });

      test('現在の年で取得できる', () async {
        // Arrange
        const token = 'valid_token';
        final year = DateTime.now().year;
        final contributions = TestData.contributionList();
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => Right(contributions));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.getContributions(token, year)).called(1);
      });

      test('空文字列のtokenで呼び出せる（リポジトリで検証される）', () async {
        // Arrange
        const token = '';
        const year = 2024;
        const failure = AuthenticationFailure('認証に失敗しました');
        when(
          mockRepository.getContributions(token, year),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(token, year);

        // Assert
        expect(result.isLeft(), true);
        verify(mockRepository.getContributions(token, year)).called(1);
      });
    });
  });
}
