//Модель фото
class Photo {
  final String imageUrl;
  final DateTime dateTaken;
  final String section;
  final String? exercise;

  Photo({
    required this.imageUrl,
    required this.dateTaken,
    required this.section,
    this.exercise,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      imageUrl: json['image_url'],
      dateTaken: DateTime.parse(json['date_taken']),
      section: json['section'],
      exercise: json['exercise'],
    );
  }
}
