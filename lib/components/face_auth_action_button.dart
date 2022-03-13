import 'package:bloc_flutter/ui/home/home_screen.dart';
import 'package:flutter/material.dart';

import '../database/databse_helper.dart';
import '../locator/locator.dart';
import '../model/user_model.dart';
import '../services/ml_service.dart';

class FaceAuthActionButton extends StatefulWidget {
  const FaceAuthActionButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final Function onPressed;

  @override
  _FaceAuthActionButtonState createState() => _FaceAuthActionButtonState();
}

class _FaceAuthActionButtonState extends State<FaceAuthActionButton> {
  final MLService _mlService = locator<MLService>();

  User? predictedUser;

  Future _saveFaceData() async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    final predictedData = _mlService.predictedData;
    User userToSave = User(
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    _mlService.setPredictedData(null);
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        await _saveFaceData();
        showDialog(
          context: context,
          builder: (context) {
            Widget continueButton = TextButton(
              child: const Text("Tiếp tục"),
              onPressed: () {
                _gotoHomeScreen();
              },
            );

            // set up the AlertDialog
            AlertDialog alert = AlertDialog(
              title: const Text("Thành công"),
              content: const Text("Đăng kí khuôn mặt thành công"),
              actions: [
                continueButton,
              ],
            );
            return alert;
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF0F0BDB),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _gotoHomeScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }
}
