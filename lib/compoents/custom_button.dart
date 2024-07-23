import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key, required this.buttonText, required this.actionButton});

  final String buttonText;
  final VoidCallback actionButton;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: TextButton(
          onPressed: actionButton,
          child: Text(buttonText),
        ),
      ),
    );
  }
}
