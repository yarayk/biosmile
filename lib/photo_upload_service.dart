import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PhotoUploadService {
  static final SupabaseClient supabase = Supabase.instance.client;
  static const String bucketName = 'ufacephoto'; // ← ТВОЙ бакет

  static Future<String> uploadPhoto(Uint8List imageBytes, String section, String exercise) async {
    final String fileName = '${const Uuid().v4()}.jpg';
    final String filePath = '$section/$exercise/$fileName';

    final response = await supabase.storage.from(bucketName).uploadBinary(
      filePath,
      imageBytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );

    if (response.isEmpty) {
      throw Exception('Ошибка загрузки фото в Supabase Storage');
    }

    final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
    return publicUrl;
  }
}
