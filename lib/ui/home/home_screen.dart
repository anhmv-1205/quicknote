import 'package:bloc_flutter/ui/face_auth/face_auth_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FaceAuthScreen(
                  isFaceAlready: true,
                ),
              ),
            );
          },
          child: const Text("Check in/out"),
        ),
      ),
    );
  }
}
