import 'package:flutter/material.dart';

import '../model/cars.dart';
import '../servises/database.dart';

class CreateNewCar extends StatefulWidget {
  CreateNewCar({super.key});

  @override
  _CreateNewCarState createState() => _CreateNewCarState();
}

class _CreateNewCarState extends State<CreateNewCar> {
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  final DataBase db = DataBase();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await db.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Car'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Car Price",
                          style: TextStyle(fontSize: 18),
                        ),
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter car price',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Car Name",
                          style: TextStyle(fontSize: 18),
                        ),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter car name',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Car Color",
                          style: TextStyle(fontSize: 18),
                        ),
                        TextFormField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter car color',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Cars obj = Cars(
                        price: priceController.text,
                        color: colorController.text,
                        name: nameController.text,
                        status: 'saved',
                      );
                      await db.insertToDataBase(obj);
                      print("Clicked on button 'Create Now'");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Successfully"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      priceController.clear();
                      colorController.clear();
                      nameController.clear();
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Cars obj = Cars(
                        price: priceController.text,
                        color: colorController.text,
                        name: nameController.text,
                        status: 'confirmed',
                      );
                      await db.insertToDataBase(obj);
                      print("Clicked on button 'Create Now'");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Successfully"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      priceController.clear();
                      colorController.clear();
                      nameController.clear();
                    },
                    child: const Text('Save and confirm'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
