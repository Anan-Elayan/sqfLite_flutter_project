import 'package:flutter/material.dart';
import 'package:flutter_data_base/screens/login_screen.dart';
import 'package:flutter_data_base/screens/login_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LoginState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // my Phone : 192.168.88.9:4000
  // Emulator : 10.0.2.2:4000

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
//192.168.68.137:4000 my devise
