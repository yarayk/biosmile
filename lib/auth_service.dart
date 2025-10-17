// Сервис для управления авторизацией пользователя в приложении на Flutter + Supabase.
// Содержит регистрацию по email, вход по email и базовую проверку активной сессии.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../achievement_service.dart';

/// Сервис для управления авторизацией пользователя
/// - Регистрация по email/паролю
/// - Вход по email/паролю
/// - Проверка активной сессии и редирект
class AuthService {
  /// Регистрация пользователя по email и паролю.
  static Future<bool> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String middleName,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': (lastName + " " + firstName + " " + middleName)
        },
      );

      if (response.user != null) {
        // Обновляем метрики только если реально есть сессия
        if (response.session != null || Supabase.instance.client.auth.currentUser != null) {
          await updateLoginMetrics();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Первый этап регистрации прошёл успешно!\nПожалуйста, подтвердите почту.'),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось зарегистрироваться. Попробуйте позже.')),
        );
        return false;
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

  /// Вход по email и паролю.
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

      // Проверка. Вход только при реальной session и совпадении email.
      if (response.session != null && response.user?.email == email) {
        await updateLoginMetrics();

        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await AchievementService().checkAndAwardAchievements(context, userId);
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Если вход не удался, принудительно разлогиниваем, чтобы не задерживалась гостевая/сброшенная сессия!
        await Supabase.instance.client.auth.signOut();
        _showMessage(context, 'Не удалось войти. Неверный email или пароль.');
      }
    } on AuthException catch (e) {
      await Supabase.instance.client.auth.signOut(); // всегда разлогиниваем после ошибки
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('Invalid email or password')) {
        _showMessage(context, 'Неверный email или пароль');
      } else {
        _showMessage(context, 'Ошибка входа: ${e.message}');
      }
    } catch (e) {
      await Supabase.instance.client.auth.signOut();
      _showMessage(context, 'Неизвестная ошибка: ${e.toString()}');
    }
  }

  /// Проверка активной сессии пользователя и редирект на /home.
  /// Полезно при старте приложения, когда пользователь уже был авторизован ранее.
  static void checkUserSession(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  /// Показывает Snackbar.
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Обновление login streak в таблице user_metrics.
  /// Логика:
  /// - Если записи нет — создаём с начальными значениями.
  /// - Если есть — обновляем last_login_at, streak (сбрасываем, если перерыв > 1 дня) и счётчик входов одного дня.
  static Future<void> updateLoginMetrics() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('[updateLoginMetrics] Пользователь не найден');
        return;
      }

      final userId = user.id;
      final today = DateTime.now().toUtc();

      final response = await Supabase.instance.client
          .from('user_metrics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Первая запись
        await Supabase.instance.client.from('user_metrics').insert({
          'user_id': userId,
          'last_login_at': today.toIso8601String(),
          'login_streak': 1,
          'login_count': 1,
        });
        print('[updateLoginMetrics] Новая запись создана');
      } else {
        final lastLogin = DateTime.parse(response['last_login_at']).toUtc();
        final prevStreak = response['login_streak'] ?? 1;
        final prevCount = response['login_count'] ?? 0;
        final diff = today.difference(lastLogin).inDays;

        final bool isSameDay = diff == 0;

        final newStreak = (diff == 1)
            ? prevStreak + 1
            : (diff > 1 ? 1 : prevStreak); // streak обнуляется, если больше 1 дня

        // Увеличиваем счётчик только если пользователь ещё не заходил сегодня
        final newCount = isSameDay ? prevCount : prevCount + 1;

        await Supabase.instance.client.from('user_metrics').update({
          'last_login_at': today.toIso8601String(),
          'login_streak': newStreak,
          'login_count': newCount,
        }).eq('user_id', userId);

        print('[updateLoginMetrics] Обновлено: streak=$newStreak, count=$newCount');
      }
    } catch (e) {
      print('[updateLoginMetrics] Ошибка: $e');
    }
  }
}