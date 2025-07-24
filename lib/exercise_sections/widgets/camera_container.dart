// 📁 widgets/camera_container.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraContainer extends StatelessWidget {
  final bool showCamera;
  final CameraController? cameraController;
  final bool isChecked;
  final VoidCallback onCheckToggle;

  const CameraContainer({
    super.key,
    required this.showCamera,
    required this.cameraController,
    required this.isChecked,
    required this.onCheckToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFB3E5FC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: showCamera
            ? (cameraController != null && cameraController!.value.isInitialized
            ? ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: cameraController!.value.previewSize!.height,
              height: cameraController!.value.previewSize!.width,
              child: CameraPreview(cameraController!),
            ),
          ),
        )
            : const Center(child: CircularProgressIndicator()))
            : Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Твоя очередь, включишь камеру?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/image/video1.png',
                    width: 160,
                    height: 160,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: onCheckToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: isChecked
                        ? Border.all(color: Colors.green, width: 3)
                        : null,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 24,
                    color: isChecked ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
