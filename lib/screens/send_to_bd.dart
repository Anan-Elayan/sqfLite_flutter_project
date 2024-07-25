import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/cars.dart';
import '../servises/database.dart';

class SendToDB extends StatefulWidget {
  const SendToDB({super.key, required List<Cars> cars});

  @override
  _SendToDB createState() => _SendToDB();
}

class _SendToDB extends State<SendToDB> {
  final DataBase db = DataBase();
  bool _isSyncing = false;
  List<Cars> confirmedCars = [];
  bool _allDataSynced = false;

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

    try {
      bool allCarsSynced = true;
      bool allCarsAlreadyExist = true;

      for (var car in confirmedCars) {
        final response = await http.post(
          Uri.parse('http://192.168.88.9:4000/insertIntoCars'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': car.name,
            'price': car.price,
            'color': car.color,
          }),
        );

        if (response.statusCode == 200) {
          print('Car added successfully: ${car.name}');
          allCarsAlreadyExist = false; // At least one car was added
        } else if (response.statusCode == 409) {
          // Car already exists
          print('Car already exists: ${car.name}');
        } else {
          allCarsSynced = false;
          print('Failed to add car: ${car.name}');
        }
      }

      if (allCarsAlreadyExist) {
        _showCarAlreadyExistsDialog();
      } else if (allCarsSynced) {
        setState(() {
          _allDataSynced = true;
        });

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text('Cars Synced Successfully!'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok"))
                ],
              );
            });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Cars synced successfully!')),
        // );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while syncing cars!')),
      );
    }

    setState(() {
      _isSyncing = false;
    });
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

  void _showAllDataSyncedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Already Synced'),
          content:
              const Text('All data is already synced. No new data to sync.'),
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

  void _showCarAlreadyExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Car Already Exists'),
          content: const Text(
              'All the cars you are trying to sync already exist in the database.'),
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
      _allDataSynced =
          confirmedCars.isEmpty; // Set _allDataSynced if no confirmed cars
    });
  }

  Future<List<Cars>> _fetchAllCars() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.88.9:4000/cars'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((carMap) => Cars.fromMap(carMap)).toList();
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      print(e);
      throw Exception('An error occurred while fetching cars');
    }
  }

  Future<File> _generatePdf(List<Cars> cars) async {
    final pdf = pw.Document();

    // Title Page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: pw.EdgeInsets.all(30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cars Data',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.grey800,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Summary of Car Records',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Adding each Car Data on a new page
    for (var car in cars) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Padding(
            padding: pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Invoice',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Car Details',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Name: ${car.name}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Price: ${car.price}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Color: ${car.color}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final pdfFile = File("${output.path}/cars.pdf");
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }

  Future<void> _sharePdf() async {
    try {
      final cars = await _fetchAllCars();
      final pdfFile = await _generatePdf(cars);
      final pdfFilePath = pdfFile.path;

      if (await canLaunchUrl(Uri.parse(
          "whatsapp://send?text=Please find the attached PDF file."))) {
        await Share.shareFiles([pdfFilePath], text: 'Cars Data');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp not installed on your device')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while sharing the PDF')),
      );
    }
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
          TextButton(
            child: const Text(
              "Share as PDF via WhatsApp",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onPressed: () async {
              await _sharePdf();
            },
          ),
        ],
      ),
    );
  }
}
