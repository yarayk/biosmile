import 'package:supabase_flutter/supabase_flutter.dart';
import '../photo_view.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
DateTime _startOfNextMonth(DateTime d) => DateTime(d.year, d.month + 1, 1);

/// ВАЖНО: делаем generic, чтобы не ломать тип PostgrestFilterBuilder<PostgrestList>
PostgrestFilterBuilder<T> _applyExerciseFilters<T>(
    PostgrestFilterBuilder<T> query, {
      required String? userId,
      required String? section,
      required String? exercise,
    }) {
  if (userId != null) query = query.eq('user_id', userId);
  if (section != null && section.isNotEmpty) query = query.eq('section', section);
  if (exercise != null && exercise.isNotEmpty) query = query.eq('exercise', exercise);
  return query;
}

/// Полуинтервал [start, end)
PostgrestFilterBuilder<T> _applyDateRange<T>(
    PostgrestFilterBuilder<T> query,
    DateTime startInclusive,
    DateTime endExclusive,
    ) {
  return query
      .gte('date_taken', startInclusive.toIso8601String())
      .lt('date_taken', endExclusive.toIso8601String());
}

Future<List<Photo>> fetchPhotosRange({
  required DateTime startInclusive,
  required DateTime endExclusive,
  String? section,
  String? exercise,
}) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  // В твоей версии фильтры применяются к builder после select()
  PostgrestFilterBuilder<PostgrestList> query =
  supabase.from('users_photos').select();

  query = _applyExerciseFilters<PostgrestList>(
    query,
    userId: userId,
    section: section,
    exercise: exercise,
  );

  query = _applyDateRange<PostgrestList>(query, startInclusive, endExclusive);

  try {
    final dynamic response =
    await query.order('date_taken', ascending: false).select();

    final rows = List<Map<String, dynamic>>.from(response as List);

    final storage = supabase.storage.from('ufacephoto');
    final List<Photo> photos = [];

    for (final e in rows) {
      final path = (e['image_url'] ?? '').toString();
      if (path.isEmpty) continue;

      try {
        final signedUrl = await storage.createSignedUrl(path, 3600);
        final updated = Map<String, dynamic>.from(e);
        updated['image_url'] = signedUrl;
        photos.add(Photo.fromJson(updated));
      } catch (_) {
        continue;
      }
    }

    return photos;
  } catch (error) {
    throw Exception('Ошибка загрузки данных: $error');
  }
}

Future<Map<DateTime, int>> fetchMonthDayCounts({
  required DateTime monthAnchor,
  String? section,
  String? exercise,
}) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  final start = _startOfMonth(monthAnchor);
  final end = _startOfNextMonth(monthAnchor);

  PostgrestFilterBuilder<PostgrestList> query =
  supabase.from('users_photos').select('date_taken');

  query = _applyExerciseFilters<PostgrestList>(
    query,
    userId: userId,
    section: section,
    exercise: exercise,
  );

  query = _applyDateRange<PostgrestList>(query, start, end);

  try {
    final dynamic response = await query.select();
    final rows = List<Map<String, dynamic>>.from(response as List);

    final Map<DateTime, int> counts = {};

    for (final r in rows) {
      final raw = r['date_taken'];
      if (raw == null) continue;

      final dt = DateTime.tryParse(raw.toString());
      if (dt == null) continue;

      final day = _startOfDay(dt.toLocal());
      counts[day] = (counts[day] ?? 0) + 1;
    }

    return counts;
  } catch (error) {
    throw Exception('Ошибка загрузки счетчиков: $error');
  }
}
