# テストコード実行ガイド

このディレクトリには、プロジェクトのテストコードが含まれています。

## テストの構成

- **Unit Test（単体テスト）**: Domain Layer の Entities、UseCases
- **Widget Test（ウィジェットテスト）**: Presentation Layer の Widgets

## セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. Mock ファイルの生成

UseCase のテストで使用する Mock ファイルを生成します：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## テストの実行

### すべてのテストを実行

```bash
flutter test
```

### 特定のテストファイルを実行

```bash
flutter test test/features/github_contribution/domain/entities/user_test.dart
```

### カバレッジレポートを生成

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## テストファイル一覧

### Domain Layer - Entities

- `test/features/github_contribution/domain/entities/user_test.dart`
- `test/features/github_contribution/domain/entities/contribution_test.dart`
- `test/features/github_contribution/domain/entities/contribution_statistics_test.dart`
- `test/features/github_contribution/domain/entities/user_ranking_test.dart`

### Domain Layer - UseCases

- `test/features/github_contribution/domain/usecases/get_contributions_usecase_test.dart`
- `test/features/github_contribution/domain/usecases/get_authenticated_user_usecase_test.dart`
- `test/features/github_contribution/domain/usecases/validate_token_usecase_test.dart`
- `test/features/github_contribution/domain/usecases/calculate_contribution_statistics_usecase_test.dart`
- `test/features/github_contribution/domain/usecases/get_user_usecase_test.dart`
- `test/features/github_contribution/domain/usecases/get_user_contributions_usecase_test.dart`
- `test/features/github_contribution/domain/usecases/get_following_users_usecase_test.dart`

### Shared Widgets

- `test/shared/widgets/statistics_button_test.dart`

### テストデータヘルパー

- `test/fixtures/test_data.dart`

## テストカバレッジ目標

- 全体カバレッジ: 80%以上
- ビジネスロジック: 90%以上
- UI ウィジェット: 70%以上
- 重要な機能: 100%

## 注意事項

- Mock ファイル（`.mocks.dart`）は`build_runner`で生成されます
- テストを追加・変更した場合は、必要に応じて Mock ファイルを再生成してください
- テストは独立して実行できるように設計されています
