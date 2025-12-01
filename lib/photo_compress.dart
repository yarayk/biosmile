//Функция сжатия фото
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

Future<Uint8List> compressPhoto(
    Uint8List imageBytes, {
      int minWidth = 1200,
      int minHeight = 1200,
      int quality = 80,
    }) async {
  final compressedBytes = await FlutterImageCompress.compressWithList(
    imageBytes,
    minWidth: minWidth,
    minHeight: minHeight,
    quality: quality,
    format: CompressFormat.jpeg,
  );
  return compressedBytes;
}
