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
  }
}
