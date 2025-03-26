import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:async';

class ExerciseCameraPage extends StatefulWidget {
  @override
  _ExerciseCameraPageState createState() => _ExerciseCameraPageState();
}

class _ExerciseCameraPageState extends State<ExerciseCameraPage> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isDetecting = false;
  int _smileCount = 0;
  bool _exerciseCompleted = false;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[_cameraIndex], ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {});
    _startImageStream();
  }

  void _startImageStream() {
    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final inputImage = _convertCameraImage(image);
        final poses = await _poseDetector.processImage(inputImage);
        _analyzePose(poses);
      } catch (e) {
        print("Error processing image: $e");
      }
      _isDetecting = false;
    });
  }

  InputImage _convertCameraImage(CameraImage image) {
    final bytes = image.planes[0].bytes;
    return InputImage.fromBytes(bytes: bytes, metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    ));
  }

  void _analyzePose(List<Pose> poses) {
    if (poses.isNotEmpty) {
      final pose = poses.first;
      final leftMouth = pose.landmarks[PoseLandmarkType.leftMouth];
      final rightMouth = pose.landmarks[PoseLandmarkType.rightMouth];

      if (leftMouth != null && rightMouth != null) {
        double smileFactor = (leftMouth.y + rightMouth.y) / 2;
        if (smileFactor < 0.4) {
          setState(() {
            _smileCount++;
            if (_smileCount >= 10) {
              _exerciseCompleted = true;
            }
          });
        }
      }
    }
  }

  void _switchCamera() async {
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _cameraController.dispose();
    await _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text('Упражнение: Улыбка')),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              children: [
                Text('Счётчик: $_smileCount', style: TextStyle(color: Colors.white, fontSize: 20)),
                if (_exerciseCompleted)
                  Text('Упражнение выполнено!', style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _switchCamera,
        child: Icon(Icons.switch_camera),
      ),
    );
  }
}
