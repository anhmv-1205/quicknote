import 'package:bloc_flutter/bloc/count_down_bloc.dart';
import 'package:bloc_flutter/bloc/detect_bloc.dart';
import 'package:bloc_flutter/bloc/face_auth_bloc.dart';
import 'package:bloc_flutter/common/app_colors.dart';
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
        BlocProvider(create: (context) => CountDownBloc()),
      ],
      child: MaterialApp(
        title: 'Face Recognition Authentication Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme:
              const ColorScheme.light().copyWith(primary: AppColors.primary),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
