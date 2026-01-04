import '../entities/theme_mode.dart';
import '../repositories/theme_repository.dart';

/// テーマモードを保存するUseCase
class SaveThemeModeUseCase {
  final ThemeRepository repository;

  SaveThemeModeUseCase(this.repository);

  Future<void> call(AppThemeMode themeMode) async {
    await repository.saveThemeMode(themeMode);
  }
}








