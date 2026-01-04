import 'package:fpdart/fpdart.dart';
import 'package:mockito/src/dummies.dart';
import 'package:git_hub_contribution_app/core/error/failures.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/user.dart';
import 'package:git_hub_contribution_app/features/github_contribution/domain/entities/contribution.dart';
import '../fixtures/test_data.dart';

/// Mockitoのダミー値を設定するヘルパー関数
void setupMockitoDummies() {
  // Either<Failure, bool>のダミー値
  provideDummy<Either<Failure, bool>>(const Right<Failure, bool>(false));

  // Either<Failure, User>のダミー値
  provideDummy<Either<Failure, User>>(Right<Failure, User>(TestData.validUser()));

  // Either<Failure, List<User>>のダミー値
  provideDummy<Either<Failure, List<User>>>(Right<Failure, List<User>>(<User>[]));

  // Either<Failure, List<Contribution>>のダミー値
  provideDummy<Either<Failure, List<Contribution>>>(Right<Failure, List<Contribution>>(<Contribution>[]));
}

