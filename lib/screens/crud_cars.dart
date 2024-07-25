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
    try {
      await db.initDatabase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize database')),
      );
    }
  }

  Future<void> _retrieveSavedCars() async {
    try {
      List<Map<String, dynamic>> data = await db.retrievedCard(status: 'saved');
      List<Cars> savedCars =
          data.map((carMap) => Cars.fromMap(carMap)).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadCars(cars: savedCars),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve saved cars')),
      );
    }
  }

  Future<void> _retrieveConfirmedCars() async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve confirmed cars')),
      );
    }
  }

  Future<void> _deleteCar() async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete car')),
      );
    }
  }

  Future<void> _updateCar(String id) async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update car')),
      );
    }
  }

  void _showCarIdDialog(String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter your car ID to $action"),
          content: TextField(
            decoration: InputDecoration(hintText: "Enter car ID"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (action == 'Update') {
                carIdUpdate = value;
              } else {
                carIdDeleted = value;
              }
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
                if (action == 'Update') {
                  _updateCar(carIdUpdate); // Update the car
                } else {
                  _deleteCar(); // Perform delete
                }
              },
              child: Text("$action Now"),
            ),
          ],
        );
      },
    );
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
                  _showCarIdDialog('Update');
                },
                child: Text(
                  "Update Car",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showCarIdDialog('Delete');
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
