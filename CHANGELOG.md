# Changelog

## [Unreleased]

### Added

- Contribution 詳細表示機能の実装 (#28, #29, #30, #31, #32, #33)
  - カレンダーのセルをタップすると、その日の Contribution 詳細がモーダルで表示されるように
  - 日付、Contribution 数、活動レベルを表示
  - スムーズなスライドアップアニメーションとフェードインアニメーション
  - セルタップ時のスケールエフェクト
  - 直感的で分かりやすい UI
  - **ガラスモーフィズムデザイン**: モーダルに BackdropFilter を使用したぼかし効果を適用
  - **ジオメトリック背景**: モーダル背景に網代模様と麻の葉模様のジオメトリックパターンを配置
  - **グラデーション背景**: 半透明のグラデーション背景で美しいビジュアル
  - **詳細なデバッグログ**: タップイベントとモーダル表示のデバッグログを追加

### Technical Details

- `ContributionDetailModal`: Contribution 詳細を表示するモーダルウィジェット
  - FadeTransition と SlideTransition を使用したアニメーション
  - BackdropFilter + ImageFilter.blur でガラスモーフィズム効果
  - CustomPaint で描画されるジオメトリックパターン背景（網代模様 + 麻の葉模様）
  - グラデーション背景と半透明レイヤー
  - 活動レベルの視覚的表示
  - GitHub のデザインに準拠したカラースキーム
  - `_GeometricPatternPainter`: モーダル用のジオメトリックパターンを描画する CustomPainter
- `ContributionCalendarWidget`: カレンダーセルにタップ機能を追加
  - TweenAnimationBuilder を使用したタップ時のスケールエフェクト
  - GestureDetector によるタップ処理
  - 詳細なデバッグログ（📅、🚀、🎯、🏗️、✅、❌）
- `AppColors`: GitHub 緑色 (`githubGreen`) を追加

Closes #28, #29, #30, #31, #32, #33
