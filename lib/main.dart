import 'package:bloc_flutter/bloc/detect_bloc.dart';
import 'package:bloc_flutter/bloc/face_auth_bloc.dart';
import 'package:bloc_flutter/bloc/image_cubit.dart';
import 'package:bloc_flutter/components/components_layer.dart';
import 'package:bloc_flutter/database/databse_helper.dart';
import 'package:bloc_flutter/services/camera_service.dart';
import 'package:bloc_flutter/services/face_detector_service.dart';
import 'package:bloc_flutter/services/ml_service.dart';
import 'package:bloc_flutter/ui/face_auth/face_auth_screen.dart';
import 'package:bloc_flutter/ui/text_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locator/locator.dart';

void main() async {
  setupServices();
  WidgetsFlutterBinding.ensureInitialized();

  // final _faceDetectorService = locator<FaceDetectorService>();
  // final _cameraService = locator<CameraService>();
  // final _mlService = locator<MLService>();
  //
  // await _cameraService.initialize();
  // await _mlService.initialize();
  // _faceDetectorService.initialize();

  final user = await DatabaseHelper.instance.queryAllUsers();
  final isFaceAuth = user.isNotEmpty;

  runApp(MyApp(
    isFaceAuth: isFaceAuth,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFaceAuth;

  const MyApp({Key? key, required this.isFaceAuth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(create: (context) => ImageCubit()),
        // BlocProvider(
        //   create: (context) => TextRecognizedCubit()
        //     ..imageCubit = BlocProvider.of<ImageCubit>(context),
        // ),
        BlocProvider(create: (context) => FaceAuthBloc()),
        BlocProvider(create: (context) => DetectBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FaceAuthScreen(
          isFaceAlready: isFaceAuth,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocConsumer<ImageCubit, ImageState>(
              listener: (context, state) {
                print(state.toString());
              },
              builder: (context, state) {
                final bloc = BlocProvider.of<ImageCubit>(context);
                if (state is ImageLoading) {
                  return const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator());
                } else if (state is ImageLoaded &&
                    state.image?.imagePath != null &&
                    state.image?.imagePath?.isNotEmpty == true) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DisplayImage(bloc.image?.imagePath),
                      CustomButton(
                        title: "Get another image",
                        onTap: () {
                          bloc.getImage();
                        },
                      ),
                    ],
                  );
                }
                return CustomButton(
                  title: "Upload image",
                  onTap: () {
                    bloc.getImage();
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoResultScreen,
        tooltip: 'Increment',
        child: const Icon(Icons.arrow_right_sharp),
      ),
    );
  }

  void _gotoResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TextResultScreen(),
      ),
    );
  }
}
