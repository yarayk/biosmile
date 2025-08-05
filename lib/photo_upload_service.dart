import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../achievement_service.dart';
import '../game_scripts.dart';

class PhotoUploadService {
  static final SupabaseClient supabase = Supabase.instance.client;
  static const String bucketName = 'ufacephoto';

  static String sanitize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\d_-]'), '_');
  }

  static Future<String> uploadPhoto(BuildContext context, Uint8List imageBytes, String section, String exercise) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Пользователь не авторизован');

    final String fileName = '${const Uuid().v4()}.jpg';
    final String safeSection = sanitize(section);
    final String safeExercise = sanitize(exercise);
    final String filePath = '$safeSection/$safeExercise/$fileName';

    final response = await supabase.storage.from(bucketName).uploadBinary(
      filePath,
      imageBytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );

    if (response.isEmpty) {
      throw Exception('Ошибка загрузки фото в Supabase Storage');
    }

    // Получаем дату начала недели
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekUtc = DateTime.utc(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    // Считаем фото пользователя за эту неделю
    final photoCountThisWeek = await supabase
        .from('users_photos')
        .select()
        .eq('user_id', userId)
        .gte('uploaded_at', startOfWeekUtc.toIso8601String());

    if (photoCountThisWeek.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Упс! Пока что нельзя получить награду за загрузку фото'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      await supabase.rpc('increment_photo_count', params: {'user_id_input': userId});

      await supabase.from('users_photos').insert({
        'user_id': userId,
        'file_path': filePath,
        'uploaded_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Вознаграждение за фото
      await GamificationService().applyPhotoReward(context);
    }

    // Проверка достижений
    await AchievementService().checkAndAwardAchievements(context, userId);

    return filePath;
  }
}
