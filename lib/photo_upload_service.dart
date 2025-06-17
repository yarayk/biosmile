import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PhotoUploadService {
  static final SupabaseClient supabase = Supabase.instance.client;
  static const String bucketName = 'ufacephoto';

  // Очистка имени для пути
  static String sanitize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\d_-]'), '_');
  }

  static Future<String> uploadPhoto(Uint8List imageBytes, String section, String exercise) async {
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

    return filePath;
  }
}
