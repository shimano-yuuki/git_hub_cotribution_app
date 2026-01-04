import 'package:flutter/material.dart';

/// アプリ全体で使用するカラーをまとめた static クラス
class AppColors {
  AppColors._(); // インスタンス化を防ぐ

  // ==================== GitHub カラーパレット ====================
  /// GitHub ダーク背景
  static const Color githubDarkBg = Color(0xFF0D1117);

  /// GitHub ダークサーフェス
  static const Color githubDarkSurface = Color(0xFF161B22);

  /// GitHub ダークボーダー
  static const Color githubDarkBorder = Color(0xFF30363D);

  /// ダークモードのテキストカラー
  static const Color githubDarkText = Color(0xFF24292E);

  /// ライトモードのテキストカラー
  static const Color githubLightText = Color(0xFFC9D1D9);

  /// ライトモードの背景カラー
  static const Color githubLightBg = Color(0xFFF6F8FA);

  /// ライトモードのボーダーカラー
  static const Color githubLightBorder = Color(0xFFE1E4E8);

  /// 未選択アイテム（ライトモード）
  static const Color githubUnselectedLight = Color(0xFF6A737D);

  /// 未選択アイテム（ダークモード）
  static const Color githubUnselectedDark = Color(0xFF8B949E);

  /// エラーカラー（ライトモード）
  static const Color githubErrorLight = Color(0xFFD73A49);

  /// エラーカラー（ダークモード）
  static const Color githubErrorDark = Color(0xFFF85149);

  // ==================== アクセントカラー ====================
  /// ターミナルグリーン（アクセントカラー）
  static const Color terminalGreen = Color(0xFF00FF88);

  /// GitHub グリーン（Contributionカラー）
  static const Color githubGreen = Color(0xFF26A641);

  // ==================== 背景グラデーションカラー ====================
  /// ダークグレー（背景グラデーション用）
  static const Color darkGrey = Color(0xFF2A2A2A);

  /// 薄い緑がかった黒（背景グラデーション用）
  static const Color darkGreenBlack = Color(0xFF1A2A1A);

  /// 薄い緑（背景グラデーション用）
  static const Color darkGreen = Color(0xFF1A3A1A);

  // ==================== 基本カラー ====================
  /// 白
  static const Color white = Colors.white;

  /// グレー（Material Colors のグレー）
  static Color grey([int? shade]) {
    if (shade == null) return Colors.grey;
    switch (shade) {
      case 50:
        return Colors.grey.shade50;
      case 100:
        return Colors.grey.shade100;
      case 200:
        return Colors.grey.shade200;
      case 300:
        return Colors.grey.shade300;
      case 400:
        return Colors.grey.shade400;
      case 500:
        return Colors.grey.shade500;
      case 600:
        return Colors.grey.shade600;
      case 700:
        return Colors.grey.shade700;
      case 800:
        return Colors.grey.shade800;
      case 900:
        return Colors.grey.shade900;
      default:
        return Colors.grey;
    }
  }

  // ==================== テーマ別ヘルパーメソッド ====================
  /// テーマに応じたテキストカラーを取得
  static Color textColor(Brightness brightness) {
    return brightness == Brightness.dark ? githubLightText : githubDarkText;
  }

  /// テーマに応じたアイコンカラーを取得
  static Color iconColor(Brightness brightness) {
    return brightness == Brightness.dark ? terminalGreen : grey(700);
  }

  /// テーマに応じた背景カラーを取得
  static Color backgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? githubDarkSurface : white;
  }

  /// テーマに応じたボーダーカラーを取得
  static Color borderColor(Brightness brightness) {
    return brightness == Brightness.dark ? githubDarkBorder : githubLightBorder;
  }

  /// テーマに応じたアクセントカラーを取得
  /// ライトモードでは蛍光色を避けてgithubGreenを使用
  static Color accentColor(Brightness brightness) {
    return brightness == Brightness.dark ? terminalGreen : githubGreen;
  }
}
