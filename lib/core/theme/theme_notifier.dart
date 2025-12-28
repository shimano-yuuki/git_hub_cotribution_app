import 'package:flutter/material.dart';

/// テーマ変更を通知するNotifier
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// テーマモードを更新する
  void updateThemeMode(ThemeMode mode) {
    value = mode;
  }
}

/// グローバルなテーマNotifier
final themeNotifier = ThemeNotifier();
