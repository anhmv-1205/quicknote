import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../components/face_auth_action_button.dart';
import '../../components/face_painter.dart';
import '../../database/databse_helper.dart';
import '../../locator/locator.dart';
import '../../model/user_model.dart';
import '../../services/camera_service.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';

class FaceAuthScreen extends StatefulWidget {
  final bool isFaceAlready;

  const FaceAuthScreen({
    Key? key,
    this.isFaceAlready = false,
  }) : super(key: key);

  @override
  FaceAuthScreenState createState() => FaceAuthScreenState();
}

class FaceAuthScreenState extends State<FaceAuthScreen> {
  String? imagePath;
  Face? faceDetected;
  Size? imageSize;

  bool _detectingFaces = false;

  bool pictureTaken = false;

  bool _initializing = true;

  bool _isFaceAlready = false;

  // service injection
  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  final MLService _mlService = locator<MLService>();

  @override
  void initState() {
    super.initState();

    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  _start() async {
    DatabaseHelper _dbHelper = DatabaseHelper.instance;

    List<User> users = await _dbHelper.queryAllUsers();
    _isFaceAlready = widget.isFaceAlready && users.isNotEmpty;

    // await _cameraService.initialize();
    // await _mlService.initialize();
    // _faceDetectorService.initialize();
    setState(() => _initializing = false);

    _frameFaces();
  }

  Future<bool> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );

      return false;
    } else {
      await _cameraService.cameraController.stopImageStream();
      XFile file = await _cameraService.takePicture();
      imagePath = file.path;

      setState(() {
        pictureTaken = true;
      });

      return true;
    }
  }

  void _frameFaces() async {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_detectingFaces) return;

      _detectingFaces = true;

      try {
        await _faceDetectorService.detectFacesFromImage(image);
        if (_faceDetectorService.faces.isNotEmpty) {
          faceDetected = _faceDetectorService.faces.first;
          if (faceDetected != null) {
            // setState(() async {
            //   _mlService.setCurrentPrediction(image, faceDetected!);
            //   if (_isFaceAlready) {
            //     final currentUser = await _mlService.predict();
            //     if (currentUser != null) {
            //       showCheckInOut(currentUser);
            //     }
            //   }
            // });

            _mlService.setCurrentPrediction(image, faceDetected!);
            if (_isFaceAlready) {
              try {
                final currentUser = await _mlService.predict();
                if (currentUser != null) {
                  showCheckInOut(currentUser);
                }
              } catch (e) {
                print(e);
              }
            }
          }
        } else {
          // setState(() {
          //   faceDetected = null;
          // });
          faceDetected == null;
        }

        _detectingFaces = false;
      } catch (e) {
        print(e);
        _detectingFaces = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    late Widget body;
    if (_initializing) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_initializing && pictureTaken && imagePath != null) {
      body = SizedBox(
        width: width,
        height: height,
        child: Transform(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.file(File(imagePath!)),
            ),
            transform: Matrix4.rotationY(mirror)),
      );
    }

    if (!_initializing && !pictureTaken) {
      body = Transform.scale(
        scale: 1.0,
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SizedBox(
                width: width,
                height:
                    width * _cameraService.cameraController.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(_cameraService.cameraController),
                    if (faceDetected != null && imageSize != null)
                      CustomPaint(
                        painter: FacePainter(
                          face: faceDetected!,
                          imageSize: imageSize!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          body,
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_isFaceAlready
          ? FaceAuthActionButton(
              onPressed: onShot,
            )
          : null,
    );
  }

  void showCheckInOut(User user) {
    // PersistentBottomSheetController bottomSheetController =
    // Scaffold.of(context).showBottomSheet((context) => signSheet(context));
    // bottomSheetController.closed.whenComplete(() => _reload());

    showDialog(
      context: context,
      builder: (context) {
        Widget continueButton = TextButton(
          child: const Text("Tiếp tục"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: const Text("Thành công"),
          content: const Text("Nhận diện khuôn mặt thành công"),
          actions: [
            continueButton,
          ],
        );
        return alert;
      },
    );
  }

  signSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text("16:50"),
              Column(
                children: const [
                  Text("Thứ năm, 25/10/2020"),
                  Text("16:50"),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text("CHẤM CÔNG RA VỀ"),
          )
        ],
      ),
    );
  }
}
