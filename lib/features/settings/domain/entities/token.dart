/// Personal Access Token エンティティ
class Token {
  final String value;

  const Token(this.value);

  /// トークンが有効かどうかをチェック
  bool get isValid {
    // GitHub Personal Access Token は通常40文字の英数字
    // または ghp_ で始まる新しい形式
    if (value.isEmpty) return false;
    if (value.length < 20) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
