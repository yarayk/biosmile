import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../achievement_service.dart';


class PhotoUploadService {
  static final SupabaseClient supabase = Supabase.instance.client;
  static const String bucketName = 'ufacephoto';

  // Очистка имени для пути
  static String sanitize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\d_-]'), '_');
  }

  static Future<String> uploadPhoto(BuildContext context, Uint8List imageBytes, String section, String exercise) async  {
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

    // Проверка достижений после загрузки фото
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await AchievementService().checkAndAwardAchievements(context, userId);
    }

    return filePath;
  }
}
