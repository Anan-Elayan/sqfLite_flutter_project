import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/cars.dart';
import '../servises/database.dart';

class SendToDB extends StatefulWidget {
  final List<Cars> cars;

  const SendToDB({super.key, required this.cars});

  @override
  _SendToDBState createState() => _SendToDBState();
}

class _SendToDBState extends State<SendToDB> {
  final DataBase db = DataBase();
  bool _isSyncing = false;
  List<Cars> confirmedCars = [];

  @override
  void initState() {
    super.initState();
    _loadConfirmedCars();
  }

  Future<void> _sendToDatabase() async {
    setState(() {
      _isSyncing = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isSyncing = false;
      });
      _showNoInternetDialog();
      return;
    }
    //my devise : 192.168.88.9:4000
    // Emulator : 10.0.2.2:5000
    try {
      for (var car in confirmedCars) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/insertIntoCars'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': car.name,
            'price': car.price,
            'color': car.color,
          }),
        );

        if (response.statusCode == 200) {
          print('Car added successfully: ${car.name}');
        } else {
          print('Failed to add car: ${car.name}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sync car: ${car.name}')),
          );
        }
      }

      // Log before clearing
      print('Clearing confirmedCars list.');
      setState(() {
        confirmedCars.clear();
      });

      // Log after clearing
      print('List after clearing: $confirmedCars');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cars synced successfully!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while syncing cars!')),
      );
    }

    setState(() {
      _isSyncing = false;
    });
    Navigator.pop(context);
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadConfirmedCars() async {
    await db.initDatabase();
    List<Map<String, dynamic>> carsFromDb =
        await db.retrievedCard(status: 'confirmed');
    setState(() {
      confirmedCars = carsFromDb.map((carMap) => Cars.fromMap(carMap)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync Page"),
        actions: [
          IconButton(
            onPressed: _sendToDatabase,
            icon: _isSyncing
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.network_check_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: confirmedCars.isEmpty
                ? const Center(child: Text("No confirmed cars to display"))
                : ListView.builder(
                    itemCount: confirmedCars.length,
                    itemBuilder: (context, index) {
                      final car = confirmedCars[index];
                      return ListTile(
                        title: Text('Name: ${car.name}'),
                        subtitle:
                            Text('Price: ${car.price}, Color: ${car.color}'),
                        trailing: Text('ID: ${car.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
