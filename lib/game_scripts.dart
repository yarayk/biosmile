import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamificationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Вознаграждение за авторизацию: +10 XP и +5 монет
  Future<void> rewardForLogin(BuildContext context) async {
    await _applyReward(
      context,
      xpReward: 10,
      coinReward: 5,
      message: '+10 XP и +5 монет за авторизацию',
    );
  }

  /// Вознаграждение за регистрацию: +40 XP
  Future<void> rewardForSignup(BuildContext context) async {
    await _applyReward(
      context,
      xpReward: 40,
      coinReward: 0,
      message: '+40 XP за регистрацию',
    );
  }

  /// Получение серии заходов пользователя (login_streak)
  Future<int> getLoginStreak() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 1;

    final response = await _client
        .from('user_metrics')
        .select('login_streak')
        .eq('user_id', userId)
        .maybeSingle();

    return response?['login_streak'] ?? 1;
  }

  /// Общая функция начисления наград
  Future<void> _applyReward(
      BuildContext context, {
        required int xpReward,
        required int coinReward,
        required String message,
      }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('users')
        .select('xp, coins, level')
        .eq('id', userId)
        .single();

    if (response == null) return;

    int xp = response['xp'] ?? 0;
    int coins = response['coins'] ?? 0;
    int level = response['level'] ?? 1;

    xp += xpReward;
    coins += coinReward;

    // Простая логика повышения уровня
    while (xp >= 100) {
      xp -= 100;
      coins += 50 * level;
      level += 1;
    }

    if (level == 5) {
      coins += 500;
    }

    await _client.from('users').update({
      'xp': xp,
      'coins': coins,
      'level': level,
    }).eq('id', userId);

    _showSnackBar(context, message);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}