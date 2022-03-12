import 'package:flutter/material.dart';

import '../database/databse_helper.dart';
import '../locator/locator.dart';
import '../model/user_model.dart';
import '../services/camera_service.dart';
import '../services/ml_service.dart';

class AuthActionButton extends StatefulWidget {
  const AuthActionButton({
    Key? key,
    required this.onPressed,
    required this.isLogin,
    required this.reload,
  }) : super(key: key);

  final Function onPressed;
  final bool isLogin;
  final Function reload;

  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User? predictedUser;

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    final predictedData = _mlService.predictedData;
    User userToSave = User(
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    _mlService.setPredictedData(null);

    print("Sign up success");
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  Future _signIn(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('Wrong password!'),
        );
      },
    );
  }

  Future<User?> _predictUser() async {
    final userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
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

  signSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? const Text(
                  'Welcome back, ',
                  style: const TextStyle(fontSize: 20),
                )
              : widget.isLogin
                  ? const Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    )
                  : const SizedBox(),
          // Column(
          //   children: [
          //     !widget.isLogin
          //         ? AppTextField(
          //             controller: _userTextEditingController,
          //             labelText: "Your Name",
          //           )
          //         : Container(),
          //     const SizedBox(height: 10),
          //     widget.isLogin && predictedUser == null
          //         ? Container()
          //         : AppTextField(
          //             controller: _passwordTextEditingController,
          //             labelText: "Password",
          //             isPassword: true,
          //           ),
          //     const SizedBox(height: 10),
          //     const Divider(),
          //     const SizedBox(height: 10),
          //     widget.isLogin && predictedUser != null
          //         ? AppButton(
          //             text: 'Check in/out',
          //             onPressed: () async {
          //               _signIn(context);
          //             },
          //             icon: Icon(
          //               Icons.login,
          //               color: Colors.white,
          //             ),
          //           )
          //         : !widget.isLogin
          //             ? AppButton(
          //                 text: 'SIGN UP',
          //                 onPressed: () async {
          //                   await _signUp(context);
          //                 },
          //                 icon: Icon(
          //                   Icons.person_add,
          //                   color: Colors.white,
          //                 ),
          //               )
          //             : Container(),
          //   ],
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
