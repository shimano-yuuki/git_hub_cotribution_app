import '../entities/theme_mode.dart';
import '../repositories/theme_repository.dart';

/// テーマモードを取得するUseCase
class GetThemeModeUseCase {
  final ThemeRepository repository;

  GetThemeModeUseCase(this.repository);

  Future<AppThemeMode> call() async {
    return await repository.getThemeMode();
  }
}

