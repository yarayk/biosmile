import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class DeepLinkHandler {
  static Future<void> handleUri(Uri uri) async {
    // Обработка ссылки восстановления пароля
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
          print("Ошибка при обработке ссылки: $e");
        }
      }
    }

    if (uri.queryParameters['type'] == 'recovery' ||
        uri.queryParameters['type'] == 'signup' ||
        uri.queryParameters['type'] == 'magiclink' ||
        uri.queryParameters['type'] == 'invite' ||
        uri.queryParameters['type'] == 'oauth') {
      // авторизация прошла — можно обработать
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
