import 'package:flutter/material.dart';
import 'package:flutter_data_base/screens/read_cars.dart';
import 'package:flutter_data_base/screens/send_to_bd.dart';
import 'package:flutter_data_base/screens/update_cars.dart';

import '../model/cars.dart';
import '../servises/database.dart';
import 'create_new_car.dart';

class CrudCars extends StatefulWidget {
  const CrudCars({super.key});

  @override
  State<CrudCars> createState() => _CrudCarsState();
}

class _CrudCarsState extends State<CrudCars> {
  final DataBase db = DataBase();
  late String carIdDeleted;
  late String carIdUpdate;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() async {
    await db.initDatabase();
  }

  Future<void> _retrieveSavedCars() async {
    List<Map<String, dynamic>> data = await db.retrievedCard(status: 'saved');
    List<Cars> savedCars = data.map((carMap) => Cars.fromMap(carMap)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadCars(cars: savedCars),
      ),
    );
  }

  Future<void> _retrieveConfirmedCars() async {
    List<Map<String, dynamic>> data =
        await db.retrievedCard(status: 'confirmed');
    List<Cars> confirmedCars =
        data.map((carMap) => Cars.fromMap(carMap)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendToDB(cars: confirmedCars),
      ),
    );
  }

  Future<void> _deleteCar() async {
    var car = await db.getCarByID(carIdDeleted);
    if (car != null && car['status'] != 'confirmed') {
      await db.deleteCar(carIdDeleted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car with ID $carIdDeleted deleted')),
      );
      Navigator.pop(context); // Close the dialog
      _retrieveSavedCars(); // Refresh the list after deletion
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete a confirmed car')),
      );
      Navigator.pop(context); // Close the dialog
    }
  }

  Future<void> _updateCar(String id) async {
    var car = await db.getCarByID(id);
    if (car != null && car['status'] != 'confirmed') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdateCars(
            car: Cars(
              id: car['id'],
              price: car['price'],
              name: car['name'],
              color: car['color'],
              status: car['status'],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot update a confirmed car')),
      );
      Navigator.pop(context); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateNewCar(),
                    ),
                  );
                },
                child: const Text(
                  "Create Car",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _retrieveSavedCars();
                },
                child: const Text(
                  "Read Car",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Enter your car ID to Update"),
                        content: TextField(
                          decoration: InputDecoration(hintText: "Enter car ID"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            carIdUpdate = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              _updateCar(carIdUpdate); // Update the car
                            },
                            child: const Text("Update Now"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Update Car",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Enter your car ID to delete"),
                        content: TextField(
                          decoration: InputDecoration(hintText: "Enter car ID"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            carIdDeleted = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteCar(); // Perform delete
                            },
                            child: Text("Delete Car"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  "Delete Car",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _retrieveConfirmedCars();
                },
                child: const Text(
                  "Read Confirmed Cars",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
