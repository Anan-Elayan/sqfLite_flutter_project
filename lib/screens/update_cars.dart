import 'package:flutter/material.dart';

import '../model/cars.dart';
import '../servises/database.dart';

class UpdateCars extends StatefulWidget {
  final Cars car;
  const UpdateCars({required this.car, super.key});

  @override
  State<UpdateCars> createState() => _UpdateCarsState();
}

class _UpdateCarsState extends State<UpdateCars> {
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  final DataBase db = DataBase();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    priceController.text = widget.car.price;
    nameController.text = widget.car.name;
    colorController.text = widget.car.color;
  }

  Future<void> _initializeDatabase() async {
    await db.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update Car'),
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
                      Cars updatedCar = Cars(
                        id: widget.car.id,
                        price: priceController.text,
                        name: nameController.text,
                        color: colorController.text,
                        status: 'saved',
                      );
                      await db.updateCar(updatedCar);
                      print("Clicked on button 'Update'");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Successfully Updated"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Update'),
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
