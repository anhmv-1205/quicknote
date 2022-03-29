import 'package:bloc_flutter/bloc/detect_bloc.dart';
import 'package:bloc_flutter/bloc/face_auth_bloc.dart';
import 'package:bloc_flutter/ui/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locator/locator.dart';

void main() async {
  setupServices();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FaceAuthBloc()),
        BlocProvider(create: (context) => DetectBloc()),
      ],
      child: MaterialApp(
        title: 'Face Recognition Authentication Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
