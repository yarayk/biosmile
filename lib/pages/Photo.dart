import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../photo_upload_service.dart';

class CameraExerciseScreen extends StatefulWidget {
  const CameraExerciseScreen({super.key});

  @override
  State<CameraExerciseScreen> createState() => _CameraExerciseScreenState();
}

class _CameraExerciseScreenState extends State<CameraExerciseScreen> {
  // TODO: замени пути на свои PNG
  static const String _kBackPng = 'assets/newimage/arrow_left.png';
  static const String _kFilterPng = 'assets/newimage/filter.png';

  static const Color _kBg = Color(0xFFF9F9F9);
  static const Color _kWhite = Colors.white;
  static const Color _kGreen = Color(0xFF81C784);
  static const Color _kBlack = Color(0xFF000000);

  CameraController? _controller;
  List<CameraDescription>? _cameras;

  XFile? _capturedImage;
  Uint8List? _correctedImageBytes;
  bool _isInitialized = false;

  String? selectedSection;
  String? selectedExercise;

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
      'Звук "М"',
      'Звук "О"',
      'Плевать',
      'Звуки "У", "А"',
      'Рот открыт, звуки "О", "А"',
      'Произносить "Т", "П", "Р", "У"',
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
      'Движения "трубочкой"',
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

  bool get _hasExerciseSelected =>
      selectedSection != null && selectedExercise != null;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();

    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();
    final correctedBytes = await _flipImageHorizontally(File(image.path));

    if (!mounted) return;
    setState(() {
      _capturedImage = image;
      _correctedImageBytes = correctedBytes;
    });
  }

  Future<Uint8List> _flipImageHorizontally(File file) async {
    final bytes = await file.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    final flippedImage = img.flipHorizontal(originalImage!);
    return Uint8List.fromList(img.encodeJpg(flippedImage));
  }

  void _resetPhoto() {
    setState(() {
      _capturedImage = null;
      _correctedImageBytes = null;
    });
  }

  void _savePhoto() async {
    if (_correctedImageBytes == null ||
        selectedSection == null ||
        selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите упражнение в фильтре и сделайте фото')),
      );
      return;
    }

    try {
      await PhotoUploadService.uploadPhoto(
        context,
        _correctedImageBytes!,
        selectedSection!,
        selectedExercise!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото успешно сохранено')),
      );
      _resetPhoto();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  void showSectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ExerciseFilterSheet(
          sectionExercises: sectionExercises,
          initialSection: selectedSection,
          initialExercise: selectedExercise,
          onApply: (sec, ex) {
            setState(() {
              selectedSection = sec;
              selectedExercise = ex;
            });
          },
        );
      },
    );
  }

  Widget _headerButton({
    required String asset,
    required VoidCallback onTap,
    required Color backgroundColor,
    Color? iconTint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.36),
        ),
        child: Image.asset(
          asset,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
          color: iconTint,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 130,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
        child: Row(
          children: [
            _headerButton(
              asset: _kBackPng,
              onTap: () => Navigator.maybePop(context),
              backgroundColor: _kWhite,
              iconTint: null,
            ),
            const Spacer(),
            const Text(
              'Выбери упражнение',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 21 / 18,
                color: _kBlack,
              ),
            ),
            const Spacer(),
            _headerButton(
              asset: _kFilterPng,
              onTap: showSectionBottomSheet,
              backgroundColor: _hasExerciseSelected ? _kGreen : _kWhite,
              iconTint: _hasExerciseSelected ? Colors.white : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreviewCropped() {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _controller!;
    final previewSize = controller.value.previewSize;

    final child = (previewSize == null)
        ? CameraPreview(controller)
        : SizedBox(
      width: previewSize.height,
      height: previewSize.width,
      child: CameraPreview(controller),
    );

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: child,
      ),
    );
  }

  Widget _buildCameraArea() {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          color: Colors.black,
          child: _capturedImage != null
              ? (_correctedImageBytes != null
              ? Image.memory(_correctedImageBytes!, fit: BoxFit.cover)
              : const Center(child: CircularProgressIndicator()))
              : _buildCameraPreviewCropped(),
        ),
      ),
    );
  }

  Widget _pillButton({
    required String text,
    required double width,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: 37,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 21 / 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SizedBox(
      height: 62,
      width: double.infinity,
      child: Center(
        child: _capturedImage == null
            ? _pillButton(
          text: 'Сделать фото',
          width: 150,
          onTap: _takePicture,
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pillButton(
              text: 'Сбросить',
              width: 123,
              onTap: _resetPhoto,
            ),
            const SizedBox(width: 47),
            _pillButton(
              text: 'Сохранить',
              width: 123,
              onTap: _savePhoto,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),
          _buildCameraArea(),
          const SizedBox(height: 20),
          _buildBottomControls(),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _ExerciseFilterSheet extends StatefulWidget {
  const _ExerciseFilterSheet({
    required this.sectionExercises,
    required this.initialSection,
    required this.initialExercise,
    required this.onApply,
  });

  final Map<String, List<String>> sectionExercises;
  final String? initialSection;
  final String? initialExercise;
  final void Function(String? section, String? exercise) onApply;

  @override
  State<_ExerciseFilterSheet> createState() => _ExerciseFilterSheetState();
}

class _ExerciseFilterSheetState extends State<_ExerciseFilterSheet> {
  static const _kGreen = Color(0xFF81C784);
  static const _kText = Color(0xFF191919);

  // TODO: замени пути на свои PNG
  static const String _kArrowPng = 'assets/newimage/arrow_down.png';
  static const String _kCheckOnPng = 'assets/newimage/check_on.png';
  static const String _kCheckOffPng = 'assets/newimage/check_off.png';

  late String? _tempSection;
  late String? _tempExercise;

  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    _tempSection = widget.initialSection;
    _tempExercise = widget.initialExercise;
    if (_tempSection != null) _expanded.add(_tempSection!);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _tempSection = null;
      _tempExercise = null;
      _searchCtrl.clear();
      _expanded.clear();
    });
  }

  void _apply() {
    widget.onApply(_tempSection, _tempExercise);
    Navigator.pop(context);
  }

  void _toggleExpand(String section) {
    setState(() {
      if (_expanded.contains(section)) {
        _expanded.remove(section);
      } else {
        _expanded.add(section);
      }
    });
  }

  bool _sectionChecked(String section) => _tempSection == section;

  Widget _checkIcon(bool checked) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5.8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Image.asset(
        checked ? _kCheckOnPng : _kCheckOffPng,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _arrowIcon({required bool expanded}) {
    return Transform.rotate(
      angle: expanded ? 3.1415926535 : 0,
      child: Image.asset(
        _kArrowPng,
        width: 16,
        height: 16,
        fit: BoxFit.contain,
      ),
    );
  }

  Map<String, List<String>> _filteredMap(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return widget.sectionExercises;

    final Map<String, List<String>> out = {};
    widget.sectionExercises.forEach((section, exercises) {
      final secMatch = section.toLowerCase().contains(query);
      final matchedExercises =
      exercises.where((e) => e.toLowerCase().contains(query)).toList();

      if (secMatch) {
        out[section] = exercises;
      } else if (matchedExercises.isNotEmpty) {
        out[section] = matchedExercises;
      }
    });

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final q = _searchCtrl.text;
    final filtered = _filteredMap(q);
    final autoExpand = q.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: 542,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 50),
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 0, 10),
                          child: TextButton(
                            onPressed: _reset,
                            style: TextButton.styleFrom(
                              foregroundColor: _kGreen,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Сбросить',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 21 / 16,
                                letterSpacing: -0.401119,
                                color: _kGreen,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 16, 10),
                          child: TextButton(
                            onPressed: _apply,
                            style: TextButton.styleFrom(
                              foregroundColor: _kGreen,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Сохранить',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 21 / 16,
                                letterSpacing: -0.401119,
                                color: _kGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 37,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x1F787880),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0x993C3C43),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: 'Введите текст',
                                hintStyle: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15.8582,
                                  height: 21 / 15.8582,
                                  letterSpacing: -0.401119,
                                  color: Color(0x993C3C43),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                fontSize: 15.8582,
                                height: 21 / 15.8582,
                                letterSpacing: -0.401119,
                                color: _kText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 343,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: filtered.entries.map((entry) {
                              final section = entry.key;
                              final exercises = entry.value;

                              final expanded =
                              autoExpand ? true : _expanded.contains(section);
                              final sectionChecked = _sectionChecked(section);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (sectionChecked) {
                                                  _tempSection = null;
                                                  _tempExercise = null;
                                                } else {
                                                  _tempSection = section;
                                                  _tempExercise = null;
                                                  _expanded.add(section);
                                                }
                                              });
                                            },
                                            child: _checkIcon(sectionChecked),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: () => _toggleExpand(section),
                                              child: Text(
                                                section,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  height: 19 / 16,
                                                  color: _kText,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _toggleExpand(section),
                                            child: _arrowIcon(expanded: expanded),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (expanded) ...[
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          children: exercises.map((ex) {
                                            final exChecked =
                                                _tempSection == section &&
                                                    _tempExercise == ex;

                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: SizedBox(
                                                height: 24,
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (exChecked) {
                                                            _tempSection = null;
                                                            _tempExercise = null;
                                                          } else {
                                                            _tempSection = section;
                                                            _tempExercise = ex;
                                                          }
                                                        });
                                                      },
                                                      child: _checkIcon(exChecked),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        behavior: HitTestBehavior.translucent,
                                                        onTap: () {
                                                          setState(() {
                                                            if (exChecked) {
                                                              _tempSection = null;
                                                              _tempExercise = null;
                                                            } else {
                                                              _tempSection = section;
                                                              _tempExercise = ex;
                                                            }
                                                          });
                                                        },
                                                        child: Text(
                                                          ex,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontFamily: 'SF Pro Display',
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 16,
                                                            height: 1.2,
                                                            color: _kText,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
