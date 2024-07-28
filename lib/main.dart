import 'package:flutter/material.dart';
import 'package:flutter_data_base/screens/crud_cars.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // my Phone : 192.168.88.9:4000
  // Emulator : 10.0.2.2:4000

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CrudCars(),
    );
  }
}
//192.168.68.137:4000 my devise
