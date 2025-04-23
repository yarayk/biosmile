import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkHandler {
  static Future<void> handleInitialUri() async {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        Supabase.instance.client.auth.recoverSession(initialUri.toString());

    }
  }

  static void startUriListener() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        Supabase.instance.client.auth.recoverSession(uri.toString());
      }
    });
  }
}
