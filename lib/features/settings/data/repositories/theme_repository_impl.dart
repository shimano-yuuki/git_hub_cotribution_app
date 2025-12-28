import '../../domain/entities/theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

/// ThemeRepositoryの実装
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource dataSource;

  ThemeRepositoryImpl(this.dataSource);

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    await dataSource.saveThemeMode(themeMode.toValue());
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    final themeModeValue = await dataSource.getThemeMode();
    if (themeModeValue == null) {
      return AppThemeMode.system;
    }
    return AppThemeMode.fromString(themeModeValue);
  }
}
