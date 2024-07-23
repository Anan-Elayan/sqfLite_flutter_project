import 'package:flutter/material.dart';

import '../compoents/custom_button.dart';
import 'crud_cars.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigateToMainPage(BuildContext context, String languageCode) {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              color: Colors.teal,
            ),
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  buttonText: 'Go To data base',
                  actionButton: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CrudCars(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
