import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Сервис для управления авторизацией пользователя
/// Здесь содержится логика регистрации, входа через Google и авто-перехода при активной сессии
class AuthService {
  /// Регистрация пользователя по email и паролю
  static Future<void> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Успешная регистрация
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Регистрация прошла успешно!')),
        );
        Navigator.pop(context);
      } else {
        //Если ответ от сервера не был успешным
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось зарегистрироваться. Попробуйте позже.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: ${e.toString()}')),
      );
    }
  }

 /// Вход по email и паролю
 static Future<void> signInWithEmail({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showMessage(context, 'Не удалось войти. Попробуйте ещё раз.');
    }
  } catch (e) {
    if (e is AuthException) {
      _showMessage(context, 'Ошибка: ${e.message}');
    } else {
      _showMessage(context, 'Неизвестная ошибка: ${e.toString()}');
    }
  }
}

  /// Вход через Google с помощью Supabase OAuth
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final redirectUrl = kIsWeb
    ? 'http://localhost:3000'
    : 'com.mycompany.biosmile://callback';

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа через Google: ${e.toString()}')),
      );
    }
  }

//Возвращает правильный URL в зависимости от платформы
static String getRedirectUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000';  // веб-редирект
  }
  if (Platform.isAndroid || Platform.isIOS) {
    return 'com.mycompany.biosmile://callback';  // мобильный редирект
  }
  return 'http://localhost:3000';  // fallback для других случаев
}

  /// Проверка активной сессии пользователя и редирект на /home
  static void checkUserSession(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

/// Показывает Snackbar
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
