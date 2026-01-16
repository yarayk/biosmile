// photo_controller.dart
import 'photo_service.dart';
import 'photo_view.dart';

/// Контроллер теперь работает с диапазоном дат (месяц/неделя/день),
/// потому что старая "Годы/Месяцы/Дни/Все" удаляется.
class PhotoController {
  Future<List<Photo>> loadPhotosRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
    String? section,
    String? exercise,
  }) {
    return fetchPhotosRange(
      startInclusive: startInclusive,
      endExclusive: endExclusive,
      section: section,
      exercise: exercise,
    );
  }

  Future<Map<DateTime, int>> loadMonthDayCounts({
    required DateTime monthAnchor,
    String? section,
    String? exercise,
  }) {
    return fetchMonthDayCounts(
      monthAnchor: monthAnchor,
      section: section,
      exercise: exercise,
    );
  }
}
