import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../locator/locator.dart';
import 'camera_service.dart';

class FaceDetectorService {
  final CameraService _cameraService = locator<CameraService>();

  late FaceDetector _faceDetector;

  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];

  List<Face> get faces => _faces;

  bool get faceDetected => _faces.isNotEmpty;

  void initialize() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<List<Face>> detectFacesFromImage(CameraImage image) async {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: _cameraService.cameraRotation,
      inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw)!,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    InputImage _firebaseVisionImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: _firebaseImageMetadata,
    );

    _faces = await _faceDetector.processImage(_firebaseVisionImage);

    return _faces;
  }

  dispose() {
    _faceDetector.close();
  }
}
