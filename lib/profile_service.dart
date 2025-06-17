import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Модель данных профиля пользователя
class UserProfileData {
  final String lastName;
  final String firstName;
  final String middleName;
  final String email;
  final String id;
  final String avatarUrl;
  final int coins;
  final int xp;
  final int level;

  UserProfileData({
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.email,
    required this.id,
    required this.avatarUrl,
    required this.coins,
    required this.xp,
    required this.level,
  });
}

class ProfileService {
  final supabase = Supabase.instance.client;

  /// Загружает профиль пользователя из Supabase и SharedPreferences
  Future<UserProfileData?> loadProfileWithAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('selectedAvatar');

    final profile = await fetchUserProfile();
    if (profile == null) return null;

    final fullName = profile['full_name'] ?? '';
    final nameParts = fullName.trim().split(' ');

    final lastName = nameParts.isNotEmpty ? nameParts[0] : '';
    final firstName = nameParts.length > 1 ? nameParts[1] : '';
    final middleName = nameParts.length > 2 ? nameParts.sublist(2).join(' ') : '';

    return UserProfileData(
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      email: profile['email'] ?? '',
      id: profile['id'] ?? '',
      avatarUrl: savedAvatar ?? profile['avatar_url'] ?? 'assets/avatars/avatar_1.png',
      coins: profile['coins'] ?? 0,
      xp: profile['xp'] ?? 0,
      level: profile['level'] ?? 1,
    );
  }

  /// Получение только имени (first name)
  Future<String?> getFirstName() async {
    final profile = await fetchUserProfile();
    if (profile == null) return null;

    final fullName = profile['full_name'] ?? '';
    final nameParts = fullName.trim().split(' ');
    return nameParts.length > 1 ? nameParts[1] : nameParts[0];
  }

  Future<List?> getStates() async {
    final profile = await fetchUserProfile();
    if (profile == null) return null;
    final coins = profile['coins'] ?? '';
    final xp = profile['xp'] ?? '';
    final level = profile['level'] ?? '';
    return [coins, xp, level];
  }

  /// Сохраняет профиль пользователя в Supabase и SharedPreferences
  Future<void> saveProfileData(UserProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAvatar', data.avatarUrl);

    final fullName = '${data.lastName} ${data.firstName} ${data.middleName}'.trim();

    await saveUserProfile(
      fullName: fullName,
      avatarUrl: data.avatarUrl,
      coins: data.coins,
      xp: data.xp,
      level: data.level,
    );
  }

  /// Получение профиля текущего пользователя
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Ошибка при получении профиля: $e');
      return null;
    }
  }

  /// Создание или обновление профиля пользователя
  Future<void> saveUserProfile({
    required String fullName,
    String? avatarUrl,
    int? coins,
    int? xp,
    int? level,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final updateData = {
      'id': user.id,
      'email': user.email,
      'full_name': fullName,
      'avatar_url': avatarUrl ?? '',
    };


    await supabase.from('users').upsert(updateData);
  }
}
