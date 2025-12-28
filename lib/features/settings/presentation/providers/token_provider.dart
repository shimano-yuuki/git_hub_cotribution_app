import 'package:flutter_hooks/flutter_hooks.dart';
import '../../domain/entities/token.dart';
import '../../domain/usecases/save_token_usecase.dart';
import '../../domain/usecases/get_token_usecase.dart';
import '../../../github_contribution/domain/usecases/validate_token_usecase.dart';

/// トークン管理用のHook
TokenState useToken({
  required SaveTokenUseCase saveTokenUseCase,
  required GetTokenUseCase getTokenUseCase,
  ValidateTokenUseCase? validateTokenUseCase,
}) {
  final token = useState<String>('');
  final isLoading = useState<bool>(false);
  final error = useState<String?>(null);
  final isSaved = useState<bool>(false);

  /// 初期化時に保存されているトークンを読み込む
  useEffect(() {
    Future.microtask(() async {
      isLoading.value = true;
      try {
        final savedToken = await getTokenUseCase();
        if (savedToken != null) {
          token.value = savedToken.value;
          isSaved.value = true;
        }
      } catch (e) {
        error.value = 'トークンの読み込みに失敗しました';
      } finally {
        isLoading.value = false;
      }
    });
    return null;
  }, []);

  /// トークンを保存する
  Future<void> saveToken() async {
    if (token.value.isEmpty) {
      error.value = 'トークンを入力してください';
      return;
    }

    isLoading.value = true;
    error.value = null;
    isSaved.value = false;

    try {
      final tokenEntity = Token(token.value);

      // GitHub APIでトークンを検証（validateTokenUseCaseが提供されている場合）
      if (validateTokenUseCase != null) {
        final validationResult = await validateTokenUseCase(token.value);
        final isValid = validationResult.fold((failure) {
          error.value = failure.message;
          isSaved.value = false;
          return false;
        }, (isValid) => isValid);

        // 検証に失敗した場合は早期リターン
        if (!isValid) {
          isLoading.value = false;
          return;
        }
      }

      // トークンを保存
      await saveTokenUseCase(tokenEntity);
      isSaved.value = true;
      error.value = null;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      isSaved.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  return TokenState(
    token: token.value,
    setToken: (value) {
      token.value = value;
      error.value = null;
      isSaved.value = false;
    },
    isLoading: isLoading.value,
    error: error.value,
    isSaved: isSaved.value,
    saveToken: saveToken,
  );
}

/// トークンの状態を保持するクラス
class TokenState {
  final String token;
  final void Function(String) setToken;
  final bool isLoading;
  final String? error;
  final bool isSaved;
  final Future<void> Function() saveToken;

  TokenState({
    required this.token,
    required this.setToken,
    required this.isLoading,
    required this.error,
    required this.isSaved,
    required this.saveToken,
  });
}
