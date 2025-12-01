
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../achievement_service.dart';
import '../game_scripts.dart';
import 'photo_compress.dart';

class PhotoUploadService {
  static final SupabaseClient supabase = Supabase.instance.client;
  static const String bucketName = 'ufacephoto';

  static String sanitize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\d_-]'), '_');
  }

  static Future<String> uploadPhoto(
      BuildContext context, Uint8List imageBytes, String section, String exercise) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Пользователь не авторизован');

    /// ------ ДОБАВИЛ компрессию ------
    Uint8List compressedBytes = await compressPhoto(
      imageBytes,
      minWidth: 1200,
      minHeight: 1200,
      quality: 80,
    );
    /// -------------------------------

    final String fileName = '${const Uuid().v4()}.jpg';
    final String safeSection = sanitize(section);
    final String safeExercise = sanitize(exercise);
    final String filePath = '$safeSection/$safeExercise/$fileName';

    final response = await supabase.storage.from(bucketName).uploadBinary(
      filePath,
      compressedBytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );

    if (response.isEmpty) {
      throw Exception('Ошибка загрузки фото в Supabase Storage');
    }

    await supabase.from('users_photos').insert({
      'user_id': userId,
      'image_url': filePath,
      'section': section,
      'exercise': exercise,
      'date_taken': DateTime.now().toIso8601String(),
    });

    // Вознаграждение за фото
    await GamificationService().applyPhotoReward(context);

    // Проверка достижений
    await AchievementService().checkAndAwardAchievements(context, userId);

    return filePath;
  }
}
