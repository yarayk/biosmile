import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'main.dart';

//Файл для обработки ссылки из email для восстановления пароля
class DeepLinkHandler {
  static Future<void> handleInitialUri() async {
    if (kIsWeb) return; // На Web пропускаем
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      await _handleRecoveryLink(initialUri);
    }
  }

  static void startUriListener() {
    if (kIsWeb) return; // На Web пропускаем
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleRecoveryLink(uri);
      }
    });
  }

  static Future<void> _handleRecoveryLink(Uri uri) async {
    if (uri.queryParameters['type'] == 'recovery') {
      final accessToken = uri.queryParameters['access_token'];
      if (accessToken != null) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);

        // Навигация на страницу смены пароля
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/password-page',
          (route) => false,
        );
      }
    }
  }
}
