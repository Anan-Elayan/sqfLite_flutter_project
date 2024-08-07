import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/cars.dart';
import '../servises/database.dart';
import 'create_new_car.dart';
import 'login_state.dart';
import 'read_cars.dart';
import 'send_to_bd.dart';
import 'update_cars.dart';

class CrudCars extends StatefulWidget {
  const CrudCars({super.key});

  @override
  State<CrudCars> createState() => _CrudCarsState();
}

class _CrudCarsState extends State<CrudCars> {
  final DataBase db = DataBase();
  late String carIdDeleted;
  late String carIdUpdate;
  late String userColor;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    print('initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loginState = Provider.of<LoginState>(context);
    // this to access to login screen
    userColor = loginState.color;
    print('user Color from didChangeDependencies method ${userColor}');
  }

  void _initializeDatabase() async {
    try {
      await db.initDatabase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to initialize database',
          ),
        ),
      );
    }
  }

  Future<void> _retrieveSavedCars() async {
    try {
      List<Map<String, dynamic>> data = await db.retrievedCard(
        status: 'saved',
        // fetch based on the color passed from login screen
        color: userColor,
      );
      List<Cars> savedCars =
          data.map((carMap) => Cars.fromMap(carMap)).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadCars(
            cars: savedCars,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to retrieve saved cars',
          ),
        ),
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
        SnackBar(
          content: Text(
            'Failed to retrieve confirmed cars',
          ),
        ),
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
        Navigator.pop(context);
        _retrieveSavedCars(); // refresh cars list after deletion
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
          SnackBar(
            content: Text(
              'Cannot update a confirmed car',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update car',
          ),
        ),
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
            decoration: const InputDecoration(hintText: "Enter car ID"),
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
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (action == 'Update') {
                  _updateCar(carIdUpdate);
                } else {
                  _deleteCar();
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
                child: const Text(
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
