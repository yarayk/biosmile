import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

/// - Восстановление пароля ([translate:type=recovery])
/// Выполняет получение сессии и безопасную навигацию на нужный экран.
/// ВАЖНО: После [translate:pushNamedAndRemoveUntil] обязательно делать return,
/// иначе навигация может повториться/сломаться, если deep link содержит несколько параметров.

class DeepLinkHandler {
  static Future<void> handleUri(Uri uri) async {
    // Восстановление пароля
    if (uri.queryParameters['type'] == 'recovery') {
      final accessToken = uri.queryParameters['access_token'];
      if (accessToken != null) {
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/password-page',
                (route) => false,
          );
        } catch (e) {
          print("Ошибка при обработке ссылки восстановления пароля: $e");
        }
      }
      return; // Важно, чтобы не проходить дальше по условиям!
    }

    // Остальные сценарии авторизации по deep link:
    // подтверждение регистрации, magic link вход, инвайт, oauth авторизация
    if (uri.queryParameters['type'] == 'signup' ||
        uri.queryParameters['type'] == 'magiclink' ||
        uri.queryParameters['type'] == 'invite' ||
        uri.queryParameters['type'] == 'oauth') {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
              (route) => false,
        );
      } catch (e) {
        print("Ошибка при обработке deep link: $e");
      }
    }
  }
}
