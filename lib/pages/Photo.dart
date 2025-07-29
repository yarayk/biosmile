// Импорты
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../photo_upload_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CameraExerciseScreen extends StatefulWidget {
  const CameraExerciseScreen({super.key});

  @override
  State<CameraExerciseScreen> createState() => _CameraExerciseScreenState();
}

class _CameraExerciseScreenState extends State<CameraExerciseScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;
  Uint8List? _correctedImageBytes;
  bool _isInitialized = false;

  String? selectedSection;
  String? selectedExercise;
  String activeTab = 'Раздел';

  final Map<String, List<String>> sectionExercises = {
    'Упражнения для мимических мышц': [
      'Поднять брови вверх, удержать',
      'Нахмурить брови, удержать',
      'Закрыть глаза (крепко-слабо)',
      'Поморгать',
      'Двигать глазным яблоком, закрыв глаза',
      'Прищуриваться, подтягивая нижнее веко',
      'Поочередно закрывать правый и левый глаз',
      'Сморщить нос',
      'Раздувать ноздри, шевелить носом. Втягивать ноздри',
      'Звук “М”',
      'Звук “О”',
      'Плевать',
      'Звуки “У”, “А”',
      'Рот открыт, звуки “О”, “А”',
      'Произносить “Т”, “П”, “Р”, “У”',
    ],
    'Упражнения для щек': [
      'Надуть обе щеки',
      'Втянуть обе щеки',
      'Надуть правую щеку, затем левую',
      'Чередовать 1 и 2 задание',
      'Имитировать полоскание',
    ],
    'Упражнения для нижней челюсти': [
      'Рот приоткрыть, широко открыть, плотно закрыть',
      'Движения нижней челюстью вперед, назад, вправо, влево, круговые движения',
      'Имитация жевания с открытым/ закрытым ртом',
    ],
    'Упражнения для губ': [
      'Вытянуть губы вперед - трубочкой',
      'Движения “трубочкой”',
      'Трубочка-улыбочка поочередно',
      'Улыбка',
      'Длинное задание',
      'Захватывать зубами верхние и нижние губы',
      'Оскалиться',
    ],
    'Упражнения для языка': [
      'Открыть рот, язык поднять, опустить',
      'Рот открыт, язык вверх-вниз',
      'Рот открыть, язык к правому уху, к левому',
      'Облизать нижнюю, затем верхнюю губу',
      'Облизать губы по кругу',
      'Языком погладить твердое небо',
      'Длинное задание',
    ],
    'Дополнительные упражнения': [
      'Поцокать, как лошадка',
      'Брать с ладони мелкие куски яблока',
      'Вибрация губ (фыркать)',
      'Длинное задание',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      final frontCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      final correctedBytes = await _flipImageHorizontally(File(image.path));
      setState(() {
        _capturedImage = image;
        _correctedImageBytes = correctedBytes;
      });
    }
  }

  Future<Uint8List> _flipImageHorizontally(File file) async {
    final bytes = await file.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    final flippedImage = img.flipHorizontal(originalImage!);
    return Uint8List.fromList(img.encodeJpg(flippedImage));
  }

  void _deletePhoto() {
    setState(() {
      _capturedImage = null;
      _correctedImageBytes = null;
    });
  }

  void _savePhoto() async {
    if (_correctedImageBytes == null || selectedSection == null || selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля и сделайте фото')),
      );
      return;
    }

    try {
      final url = await PhotoUploadService.uploadPhoto(
        _correctedImageBytes!,
        selectedSection!,
        selectedExercise!,
        context,
      );

      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      await Supabase.instance.client.from('users_photos').insert({
        'user_id': userId,
        'image_url': url,
        'section': selectedSection,
        'exercise': selectedExercise,
        'date_taken': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото успешно сохранено')),
      );
      _deletePhoto();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }


  void showSectionBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) {
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> itemsToShow = [];
            if (activeTab == 'Раздел') {
              itemsToShow = sectionExercises.keys.toList();
            } else if (selectedSection != null) {
              itemsToShow = sectionExercises[selectedSection] ?? [];
            }

            bool hasSelection = selectedSection != null || selectedExercise != null;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSelection)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedSection = null;
                              selectedExercise = null;
                              activeTab = 'Раздел';
                            });
                            setModalState(() => errorMessage = null);
                          },
                          child: const Text('Сбросить', style: TextStyle(color: Colors.orange)),
                        )
                      else
                        const SizedBox(width: 90),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          hasSelection ? 'Сохранить' : 'Закрыть',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey.shade200,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTabOption('Раздел', setModalState, () => errorMessage = null),
                        buildTabOption('Упражнение', setModalState, () {
                          if (selectedSection == null) {
                            errorMessage = 'Сначала выберите фильтр по разделам';
                          } else {
                            errorMessage = null;
                          }
                        }),
                      ],
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: ListView(
                      children: itemsToShow.map((item) {
                        final isSelected = (activeTab == 'Раздел' && item == selectedSection) ||
                            (activeTab == 'Упражнение' && item == selectedExercise);
                        return ListTile(
                          title: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.purple : Colors.blue,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            if (activeTab == 'Раздел') {
                              setState(() {
                                selectedSection = item;
                                selectedExercise = null;
                              });
                              setModalState(() => errorMessage = null);
                            } else if (selectedSection == null) {
                              setModalState(() => errorMessage = 'Сначала выберите фильтр по разделам');
                            } else {
                              setState(() => selectedExercise = item);
                              setModalState(() => errorMessage = null);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildTabOption(String title, void Function(void Function()) setModalState, void Function() updateError) {
    final isActive = title == activeTab;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          updateError();
          if (title == 'Упражнение' && selectedSection == null) return;
          activeTab = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildUnifiedSelectionButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            activeTab = 'Раздел';
            showSectionBottomSheet();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Упражнение для сохранения',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        if (selectedSection != null && selectedExercise != null)
          Column(
            children: [
              Text('Раздел: $selectedSection', style: const TextStyle(color: Colors.black87)),
              Text('Упражнение: $selectedExercise', style: const TextStyle(color: Colors.black87)),
            ],
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon8.png',
              fit: BoxFit.cover,
            ),
          ),
          _capturedImage != null
              ? Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3E5FC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _correctedImageBytes != null
                          ? Image.memory(
                        _correctedImageBytes!,
                        fit: BoxFit.cover,
                      )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _savePhoto,
                      icon: const Icon(Icons.check),
                      label: const Text('Сохранить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _deletePhoto,
                      icon: const Icon(Icons.delete),
                      label: const Text('Удалить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                buildUnifiedSelectionButton(),
                Expanded(
                  child: Center(
                    child: _isInitialized && _controller != null
                        ? AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3E5FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    )
                        : const CircularProgressIndicator(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text('Сделать фото'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}