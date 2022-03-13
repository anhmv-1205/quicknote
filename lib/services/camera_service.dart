import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  late CameraController _cameraController;

  CameraController get cameraController => _cameraController;

  late InputImageRotation _cameraRotation;

  InputImageRotation get cameraRotation => _cameraRotation;

  late String _imagePath;

  String get imagePath => _imagePath;

  Future<void> initialize() async {
    CameraDescription description = await _getCameraDescription();
    await _setupCameraController(description: description);
    _cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    _cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Future<XFile> takePicture() async {
    XFile file = await _cameraController.takePicture();
    _imagePath = file.path;
    return file;
  }

  Size getImageSize() {
    return Size(
      _cameraController.value.previewSize?.height ?? 0.0,
      _cameraController.value.previewSize?.width ?? 0.0,
    );
  }

  dispose() async {
    await _cameraController.dispose();
  }
}
