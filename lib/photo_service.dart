//Сетевые запросы (к Supabase)

import 'package:supabase_flutter/supabase_flutter.dart';
import '../photo_view.dart';

Future<List<Photo>> fetchPhotos({
  String? section,
  String? exercise,
  String timeFilter = 'Все фото',
}) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  var query = supabase.from('users_photos').select();

  if (userId != null) {
    query = query.eq('user_id', userId);
  }

  if (section != null && section.isNotEmpty) {
    query = query.eq('section', section);
  }
  if (exercise != null && exercise.isNotEmpty) {
    query = query.eq('exercise', exercise);
  }

  final now = DateTime.now();

  if (timeFilter == 'Годы') {
    final startOfYear = DateTime(now.year);
    query = query.gte('date_taken', startOfYear.toIso8601String());
  } else if (timeFilter == 'Месяцы') {
    final startOfMonth = DateTime(now.year, now.month);
    query = query.gte('date_taken', startOfMonth.toIso8601String());
  } else if (timeFilter == 'Дни') {
    final startOfDay = DateTime(now.year, now.month, now.day);
    query = query.gte('date_taken', startOfDay.toIso8601String());
  }

  try {
    final List<Map<String, dynamic>> response = await query
        .order('date_taken', ascending: false)
        .select();

    final bucket = 'ufacephoto';
    final storage = supabase.storage.from(bucket);

    final List<Photo> photos = [];

    for (final e in response) {
      final path = e['image_url'] as String;

      try {
        final signedUrl = await storage.createSignedUrl(path, 3600); // 1 час

        final updatedJson = Map<String, dynamic>.from(e);
        updatedJson['image_url'] = signedUrl;

        photos.add(Photo.fromJson(updatedJson));
      } catch (e) {
        print('Ошибка получения ссылки для "$path": $e');
        continue;
      }
    }

    return photos;
  } catch (error) {
    throw Exception('Ошибка загрузки данных: $error');
  }
}
