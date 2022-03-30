import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bloc_flutter/bloc/count_down_bloc.dart';
import 'package:bloc_flutter/common/app_colors.dart';
import 'package:bloc_flutter/ui/home/home_screen.dart';
import 'package:bloc_flutter/ui/welcome/welcome_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
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

  var _detectingFaces = false;

  // service injection
  final _faceDetectorService = locator<FaceDetectorService>();
  final _cameraService = locator<CameraService>();
  final _mlService = locator<MLService>();

  // bloc
  late FaceAuthBloc _faceAuthBloc;
  late DetectBloc _detectBloc;
  late CountDownBloc _countDownBloc;

  @override
  void initState() {
    super.initState();
    _initBloc();
    _start();
  }

  void _initBloc() async {
    _faceAuthBloc = BlocProvider.of<FaceAuthBloc>(context);
    _detectBloc = BlocProvider.of<DetectBloc>(context);
    _countDownBloc = BlocProvider.of<CountDownBloc>(context);
  }

  _start() async {
    _faceAuthBloc.loading();

    final _dbHelper = DatabaseHelper.instance;
    final users = await _dbHelper.queryAllUsers();

    await _cameraService.initialize();
    await _mlService.initialize();
    _faceDetectorService.initialize();

    _faceAuthBloc.detecting();

    if (widget.isFaceAlready) {
      _countDownBloc.startTimer();
    }
    _frameFaces();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  Future<bool> onShot() async {
    if (faceDetected == null) {
      _showMessage(
        'No face detected!',
      );
      return false;
    } else {
      await _cameraService.cameraController.stopImageStream();
      XFile file = await _cameraService.takePicture();
      imagePath = file.path;
      _faceAuthBloc.detected(imagePath ?? "");

      if (!widget.isFaceAlready) {
        _showSuccessfulDetectedDialog();
      } else {
        _showMessage(
          "Face authenticated!",
          content: "Go to home screen",
          action: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                ModalRoute.withName("/Home"));
          },
        );
      }

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
            _mlService.setCurrentPrediction(image, faceDetected!);

            if (widget.isFaceAlready) {
              final isFaceCorrectly = await _mlService.predict();
              if (isFaceCorrectly) {
                _detectBloc.authenticate(faceDetected!);
                await onShot();
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
            // bloc: _faceAuthBloc,
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
          if (widget.isFaceAlready)
            Align(
              alignment: Alignment.center,
              child: BlocConsumer<CountDownBloc, CountDownState>(
                  listenWhen: (previous, current) {
                return previous != current;
              }, listener: (context, state) {
                if (state is Finish) {
                  _showMessage("Face not found",
                      content: "Back to welcome screen", action: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                }
              }, builder: (context, state) {
                if (state is Counting) {
                  return Text(
                    state.count.toString(),
                    style: TextStyle(
                      color: AppColors.primary.withOpacity(0.5),
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }),
            )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !widget.isFaceAlready
          ? FaceAuthActionButton(
              onPressed: onShot,
            )
          : null,
    );
  }

  void _showSuccessfulDetectedDialog() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Face detected!"),
        content: const Text("Come back the welcome screen to login"),
        actions: <Widget>[
          CupertinoDialogAction(
              textStyle: const TextStyle(color: Colors.red),
              isDefaultAction: true,
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext ctx) => const WelcomeScreen(),
                  ),
                );
              },
              child: const Text("Yes")),
        ],
      ),
    );
  }

  void _showMessage(String title, {String? content, Function? action}) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: <Widget>[
          CupertinoDialogAction(
            textStyle: const TextStyle(color: AppColors.primary),
            isDefaultAction: true,
            onPressed: () async {
              action?.call();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}
