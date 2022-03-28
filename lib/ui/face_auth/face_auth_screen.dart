import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../bloc/detect_bloc.dart';
import '../../bloc/face_auth_bloc.dart';
import '../../bloc/face_auth_state.dart';
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
  late Size imageSize;

  bool _detectingFaces = false;

  bool pictureTaken = false;

  bool _isFaceAlready = false;

  // service injection
  final _faceDetectorService = locator<FaceDetectorService>();
  final _cameraService = locator<CameraService>();
  final _mlService = locator<MLService>();

  // bloc
  late FaceAuthBloc _faceAuthBloc;
  late DetectBloc _detectBloc;

  @override
  void initState() {
    super.initState();
    _initBloc();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  void _initBloc() async {
    _faceAuthBloc = BlocProvider.of<FaceAuthBloc>(context);
    _detectBloc = BlocProvider.of<DetectBloc>(context);
  }

  _start() async {
    _faceAuthBloc.loading();

    final _dbHelper = DatabaseHelper.instance;
    final users = await _dbHelper.queryAllUsers();
    _isFaceAlready = widget.isFaceAlready && users.isNotEmpty;

    await _cameraService.initialize();
    await _mlService.initialize();
    _faceDetectorService.initialize();

    _faceAuthBloc.detecting();
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
      print(imagePath);
      _faceAuthBloc.detected(imagePath ?? "");
      return true;
    }
  }

  void _frameFaces() async {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_detectingFaces) return;
      _detectingFaces = true;

      print("Image detected: $image");

      try {
        await _faceDetectorService.detectFacesFromImage(image);
        if (_faceDetectorService.faces.isNotEmpty) {
          faceDetected = _faceDetectorService.faces.first;
          if (faceDetected != null) {
            _mlService.setCurrentPrediction(image, faceDetected!);

            if (_isFaceAlready) {
              final isFaceCorrectly = await _mlService.predict();
              if (isFaceCorrectly) {
                await onShot();
                _detectBloc.authenticate(faceDetected!);
                return;
              }
            }
          }
        } else {
          faceDetected == null;
        }
        _detectBloc.detected(faceDetected);
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

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<FaceAuthBloc, FaceAuthState>(
            bloc: _faceAuthBloc,
            builder: (context, state) {
              if (state is FaceDetecting) {
                return Transform.scale(
                  scale: 1.0,
                  child: AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.aspectRatio,
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: SizedBox(
                          width: width,
                          height: width *
                              _cameraService.cameraController.value.aspectRatio,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              CameraPreview(_cameraService.cameraController),
                              BlocBuilder<DetectBloc, DetectState>(
                                builder: (context, state) {
                                  if (state is Detected) {
                                    return CustomPaint(
                                      painter: FacePainter(
                                        face: state.face,
                                        imageSize: imageSize,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is FaceDetected) {
                return SizedBox(
                  width: width,
                  height: height,
                  child: Transform(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.file(File(state.file)),
                      ),
                      transform: Matrix4.rotationY(mirror)),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<DetectBloc, DetectState>(
              builder: (context, state) {
                if (state is Detected) {
                  return const Text("Face Found");
                }
                return const Text("Face Not Found");
              },
            ),
          ),
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
    showDialog(
      context: context,
      builder: (context) {
        final continueButton = TextButton(
          child: const Text("Tiếp tục"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );

        // set up the AlertDialog
        final alert = AlertDialog(
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
