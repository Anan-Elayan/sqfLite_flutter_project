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
  const SendToDB({super.key, required this.cars});

  final List<Cars> cars;

  @override
  _SendToDB createState() => _SendToDB();
}

class _SendToDB extends State<SendToDB> {
  final DataBase db = DataBase();
  bool _isSyncing = false;
  bool allDataSynced = false;

  @override
  void initState() {
    super.initState();
  }

  // Method to send car data to the database
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

      for (var car in widget.cars) {
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
          allCarsAlreadyExist = false;
        } else if (response.statusCode == 409) {
          print('Car already exists: ${car.name}');
        } else {
          allCarsSynced = false;
        }
      }

      if (allCarsAlreadyExist) {
        _showCarAlreadyExistsDialog();
      } else if (allCarsSynced) {
        setState(() {
          allDataSynced = true;
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
                  child: Text("Ok"),
                ),
              ],
            );
          },
        );
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

  // Show a dialog when there's no internet connection
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

  // Show a dialog when cars already exist in the database
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

  // Generate a PDF file with the car data
  Future<File> _generatePdf(List<Cars> cars) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Cars Data',
                  style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Generated on: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                  style: const pw.TextStyle(
                      fontSize: 18, color: PdfColors.grey800)),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('Summary of Car Records',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        );
      }),
    );

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
                    pw.Text('Invoice',
                        style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900)),
                    pw.Text(
                        'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                        style: pw.TextStyle(
                            fontSize: 18, color: PdfColors.grey800)),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('Car Details',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
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
                      pw.Text('Name: ${car.name}',
                          style: pw.TextStyle(
                              fontSize: 18, color: PdfColors.black)),
                      pw.SizedBox(height: 10),
                      pw.Text('Price: ${car.price}',
                          style: pw.TextStyle(
                              fontSize: 18, color: PdfColors.black)),
                      pw.SizedBox(height: 10),
                      pw.Text('Color: ${car.color}',
                          style: pw.TextStyle(
                              fontSize: 18, color: PdfColors.black)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),
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

  // Share the generated PDF file
  Future<void> _sharePdf() async {
    try {
      final cars = widget.cars;
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
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.network_check_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cars.isEmpty
                ? const Center(child: Text("No confirmed cars to display"))
                : ListView.builder(
                    itemCount: widget.cars.length,
                    itemBuilder: (context, index) {
                      final car = widget.cars[index];
                      return ListTile(
                        title: Text('Name: ${car.name}'),
                        subtitle:
                            Text('Price: ${car.price} - Color: ${car.color}'),
                      );
                    },
                  ),
          ),
          if (allDataSynced)
            ElevatedButton(
              onPressed: _sharePdf,
              child: const Text('Share PDF'),
            ),
        ],
      ),
    );
  }
}
