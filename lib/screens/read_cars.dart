import 'package:flutter/material.dart';

import '../model/cars.dart';
import '../servises/database.dart';

class ReadCars extends StatefulWidget {
  final List<Cars> cars;
  const ReadCars({super.key, required this.cars});

  @override
  State<ReadCars> createState() => _ReadCarsState();
}

class _ReadCarsState extends State<ReadCars> {
  final DataBase db = DataBase();

  @override
  void initState() {
    super.initState();
    _initializeDataBase();
  }

  Future<void> _initializeDataBase() async {
    await db.initDatabase();
  }

  Future<void> _updateCarStatus(int carId) async {
    await db.updateCarStatus(carId.toString(), 'confirmed');
    setState(() {
      widget.cars.removeWhere((car) => car.id == carId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Retrieve Cars"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cars.length,
              itemBuilder: (context, index) {
                final car = widget.cars[index];
                return ListTile(
                  title: Text('Name: ${car.name}'),
                  subtitle: Text('Price: ${car.price}, Color: ${car.color}'),
                  trailing: Text('ID: ${car.id}'),
                  leading: IconButton(
                    icon: Icon(
                      Icons.task_alt_rounded,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      if (car.id != null) {
                        await _updateCarStatus(car.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Car ID ${car.id} confirmed')),
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Car ID ${car.id} confirmed')),
                      );
                      print("clicked on button to change status to confirm ");
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
