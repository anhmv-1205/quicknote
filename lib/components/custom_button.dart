import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? title;
  final Function()? onTap;
  const CustomButton({
    required this.onTap,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          title!,
        ),
      ),
    );
  }
}