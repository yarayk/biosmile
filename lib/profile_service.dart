import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Простая модель данных профиля, которая используется в UI
class UserProfileData {
  final String lastName;
  final String firstName;
  final String middleName;
  final String email;
  final String id;
  final String avatarUrl;

  UserProfileData({
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.email,
    required this.id,
    required this.avatarUrl,
  });
}

class ProfileService {
  // Получаем доступ к Supabase клиенту
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

  /// Сохраняет профиль пользователя в Supabase и SharedPreferences
  Future<void> saveProfileData(UserProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAvatar', data.avatarUrl);

    final fullName = '${data.lastName} ${data.firstName} ${data.middleName}'.trim();

    await saveUserProfile(
      fullName: fullName,
      avatarUrl: data.avatarUrl,
    );
  }

  /// Получение профиля текущего пользователя
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // Ищем профиль по id (id = auth.uid())
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  /// Создание или обновление профиля пользователя
  ///
  /// Использует upsert — если профиль есть, обновит его,
  /// если нет — создаст новый
  Future<void> saveUserProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    await supabase.from('users').upsert({
      'id': user.id,
      'email': user.email,
      'full_name': fullName,
      'avatar_url': avatarUrl ?? '',
    });
  }
}
