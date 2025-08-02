import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../achievement_popup.dart';

class AchievementService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> getUnlockedAchievements() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('user_achievements')
        .select('achievement_id')
        .eq('user_id', user.id);

    if (response == null || response.isEmpty) return [];

    return response.map<String>((e) => e['achievement_id'] as String).toList();
  }

  Future<void> checkAndAwardAchievements(BuildContext context, String userId) async {
    final unlocked = await getUnlockedAchievements();

    final photoCount = await _getPhotoCount(userId);
    final loginCount = await _getLoginCount(userId);
    final level = await _getUserLevel(userId);

    if (loginCount >= 3 && !unlocked.contains('novice')) {
      await _unlockAchievement(userId, 'novice');
      _showPopup(context, 'Новичок', 'Вы заходили в приложение 3 раза!', 'assets/image/novice.png', 100);
    }

    if (photoCount >= 5 && !unlocked.contains('photographer')) {
      await _unlockAchievement(userId, 'photographer');
      _showPopup(context, 'Фотограф', 'Вы загрузили 5 фотографий!', 'assets/image/photographer.png', 150);
    }

    if (level >= 5 && !unlocked.contains('master')) {
      await _unlockAchievement(userId, 'master');
      _showPopup(context, 'Мастер упражнений', 'Вы достигли 5 уровня!', 'assets/image/master.png', 200);
    }
  }

  Future<int> _getPhotoCount(String userId) async {
    final response = await _client
        .from('users_photos')
        .select()
        .eq('user_id', userId);

    return response.length;
  }

  Future<int> _getLoginCount(String userId) async {
    final response = await _client
        .from('user_metrics')
        .select('login_count')
        .eq('user_id', userId)
        .maybeSingle();

    return (response?['login_count'] ?? 0) as int;
  }

  Future<int> _getUserLevel(String userId) async {
    final response = await _client
        .from('users')
        .select('level')
        .eq('id', userId)
        .maybeSingle();

    return (response?['level'] ?? 0) as int;
  }

  Future<void> _unlockAchievement(String userId, String achievementId) async {
    await _client.from('user_achievements').insert({
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  void _showPopup(BuildContext context, String title, String description, String imagePath, int coins) {
    showDialog(
      context: context,
      builder: (_) => AchievementPopup(
        title: title,
        description: description,
        imagePath: imagePath,
        coins: coins,
      ),
    );
  }
}
