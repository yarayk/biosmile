import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        Navigator.pop(context);
      } else {
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

  /// Вход через Google с помощью Supabase OAuth
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа через Google: ${e.toString()}')),
      );
    }
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
}
