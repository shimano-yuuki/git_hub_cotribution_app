import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/animated_fade_in.dart';
import '../providers/token_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/error_message_widget.dart';
import '../widgets/success_message_widget.dart';
import '../widgets/section_title.dart';
import '../widgets/save_button.dart';
import '../../domain/usecases/save_token_usecase.dart';
import '../../domain/usecases/get_token_usecase.dart';
import '../../domain/usecases/save_theme_mode_usecase.dart';
import '../../domain/usecases/get_theme_mode_usecase.dart';
import '../../data/datasources/token_local_datasource.dart';
import '../../data/datasources/theme_local_datasource.dart';
import '../../data/repositories/token_repository_impl.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/token_repository.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/entities/theme_mode.dart';
import '../../../github_contribution/data/repositories/github_repository_impl.dart';
import '../../../github_contribution/domain/repositories/github_repository.dart';
import '../../../github_contribution/domain/usecases/validate_token_usecase.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DI: 依存関係を構築
    final tokenRepository = useMemoized(
      () => TokenRepositoryImpl(TokenLocalDataSource()) as TokenRepository,
    );
    final saveTokenUseCase = useMemoized(
      () => SaveTokenUseCase(tokenRepository),
    );
    final getTokenUseCase = useMemoized(() => GetTokenUseCase(tokenRepository));

    // GitHub API検証用の依存関係を構築
    final githubRepository = useMemoized(
      () => GithubRepositoryImpl() as GithubRepository,
    );
    final validateTokenUseCase = useMemoized(
      () => ValidateTokenUseCase(githubRepository),
    );

    final tokenState = useToken(
      saveTokenUseCase: saveTokenUseCase,
      getTokenUseCase: getTokenUseCase,
      validateTokenUseCase: validateTokenUseCase,
    );

    // テーマ設定用の依存関係を構築
    final themeRepository = useMemoized(
      () => ThemeRepositoryImpl(ThemeLocalDataSource()) as ThemeRepository,
    );
    final saveThemeModeUseCase = useMemoized(
      () => SaveThemeModeUseCase(themeRepository),
    );
    final getThemeModeUseCase = useMemoized(
      () => GetThemeModeUseCase(themeRepository),
    );

    final themeState = useTheme(
      saveThemeModeUseCase: saveThemeModeUseCase,
      getThemeModeUseCase: getThemeModeUseCase,
      context: context,
    );

    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textColor(brightness);
    final iconColor = AppColors.iconColor(brightness);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: AnimatedFadeSlideIn(
          delay: 100.0,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedFadeSlideIn(
                  delay: 200.0,
                  child: _TokenInputForm(
                    tokenState: tokenState,
                    textColor: textColor,
                    iconColor: iconColor,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedFadeSlideIn(
                  delay: 300.0,
                  child: _ThemeModeSelector(
                    themeState: themeState,
                    textColor: textColor,
                    iconColor: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// トークン入力フォーム
class _TokenInputForm extends HookWidget {
  final TokenState tokenState;
  final Color textColor;
  final Color iconColor;

  const _TokenInputForm({
    required this.tokenState,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final controller = useTextEditingController(text: tokenState.token);

    // tokenState.tokenが変更されたときにcontrollerを更新
    useEffect(() {
      if (controller.text != tokenState.token) {
        controller.text = tokenState.token;
      }
      return null;
    }, [tokenState.token]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SectionTitle(
          title: 'Personal Access Token',
          description: 'GitHub APIにアクセスするためのトークンを入力してください',
          textColor: textColor,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          onChanged: tokenState.setToken,
          obscureText: true,
          enabled: !tokenState.isLoading,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
            hintStyle: TextStyle(color: textColor),
            prefixIcon: Icon(Icons.lock, color: iconColor),
            filled: true,
            fillColor: isDark
                ? AppColors.githubDarkBg.withValues(alpha: 0.3)
                : AppColors.githubLightBg.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.borderColor(brightness).withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.borderColor(brightness).withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.terminalGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.githubErrorLight,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.githubErrorLight,
                width: 2,
              ),
            ),
          ),
        ),
        if (tokenState.error != null) ...[
          const SizedBox(height: 16),
          AnimatedFadeIn(child: ErrorMessageWidget(message: tokenState.error!)),
        ],
        if (tokenState.isSaved && tokenState.error == null) ...[
          const SizedBox(height: 16),
          AnimatedFadeIn(
            child: const SuccessMessageWidget(message: 'トークンが正常に保存されました'),
          ),
        ],
        const SizedBox(height: 24),
        SaveButton(
          onPressed: tokenState.saveToken,
          isLoading: tokenState.isLoading,
        ),
      ],
    );
  }
}

/// テーマモード選択セクション
class _ThemeModeSelector extends StatelessWidget {
  final ThemeState themeState;
  final Color textColor;
  final Color iconColor;

  const _ThemeModeSelector({
    required this.themeState,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'テーマ',
          icon: Icons.palette,
          textColor: textColor,
          iconColor: iconColor,
        ),
        const SizedBox(height: 16),
        _ThemeModeOption(
          title: 'ライト',
          icon: Icons.light_mode,
          themeMode: AppThemeMode.light,
          isSelected: themeState.currentThemeMode == AppThemeMode.light,
          onTap: () => themeState.changeThemeMode(AppThemeMode.light),
          textColor: textColor,
          iconColor: iconColor,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _ThemeModeOption(
          title: 'ダーク',
          icon: Icons.dark_mode,
          themeMode: AppThemeMode.dark,
          isSelected: themeState.currentThemeMode == AppThemeMode.dark,
          onTap: () => themeState.changeThemeMode(AppThemeMode.dark),
          textColor: textColor,
          iconColor: iconColor,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _ThemeModeOption(
          title: 'システム設定に従う',
          icon: Icons.brightness_auto,
          themeMode: AppThemeMode.system,
          isSelected: themeState.currentThemeMode == AppThemeMode.system,
          onTap: () => themeState.changeThemeMode(AppThemeMode.system),
          textColor: textColor,
          iconColor: iconColor,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// テーマモード選択オプション
class _ThemeModeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppThemeMode themeMode;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;
  final bool isDark;

  const _ThemeModeOption({
    required this.title,
    required this.icon,
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppColors.githubDarkBorder.withValues(alpha: 0.3)
                    : AppColors.grey(800).withValues(alpha: 0.1))
              : isDark
              ? AppColors.githubDarkBg.withValues(alpha: 0.3)
              : AppColors.githubLightBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.githubLightText : AppColors.grey(800))
                : AppColors.borderColor(
                    Theme.of(context).brightness,
                  ).withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.githubLightText : AppColors.grey(800))
                  : iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? (isDark
                            ? AppColors.githubLightText
                            : AppColors.grey(800))
                      : textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark ? AppColors.githubLightText : AppColors.grey(800),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
