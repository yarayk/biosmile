//Логика фильтрации и загрузки
import 'photo_service.dart';
import 'photo_view.dart';

class PhotoController {
  Future<List<Photo>> loadPhotos({
    String? section,
    String? exercise,
    String timeFilter = 'Все фото',
  }) async {
    return await fetchPhotos(
      section: section,
      exercise: exercise,
      timeFilter: timeFilter,
    );
  }
}
