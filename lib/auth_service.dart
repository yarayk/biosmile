import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Сервис для управления авторизацией пользователя
/// Здесь содержится логика регистрации, входа через Google и авто-перехода при активной сессии
class AuthService {
  /// Регистрация пользователя по email и паролю
  static Future<bool> signUp({
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Первый этап регистрации прошёл успешно!\nПожалуйста, подтвердите почту.')),
        );
        return true; // ✅ Успех
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось зарегистрироваться. Попробуйте позже.')),
        );
        return false; // ❌ Неудача
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered') || e.message.contains('User already registered')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аккаунт с таким email уже зарегистрирован')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка регистрации: ${e.message}')),
        );
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неизвестная ошибка: ${e.toString()}')),
      );
      return false;
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
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('Invalid email or password')) {
        _showMessage(context, 'Неверный email или пароль');
      } else {
        _showMessage(context, 'Ошибка входа: ${e.message}');
      }
    } catch (e) {
      _showMessage(context, 'Неизвестная ошибка: ${e.toString()}');
    }
  }

  /// Вход через Google с помощью Supabase OAuth
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final redirectUrl = getRedirectUrl();

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