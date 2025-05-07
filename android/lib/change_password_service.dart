import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static Future<String?> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      return 'Пожалуйста, заполните все поля';
    }

    if (newPassword.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }

    if (newPassword != confirmPassword) {
      return 'Пароли не совпадают';
    }

    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        return null; // Успех
      } else {
        return 'Ошибка при обновлении пароля';
      }
    } catch (e) {
      return 'Произошла ошибка: $e';
    }
  }
}
