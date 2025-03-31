import 'package:flutter/material.dart';
import 'package:qr_scanner/constants.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextStyle _infoStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  bool _giftStatus = false;
  bool _attendance = false;
  String _phone_no = '';
  String _name = '';
  String _epf_no = '';

  Future<void> _updateAttendance(phone, context) async {
    var urlGiftStatus = _giftStatus ? "1" : "0";

    print('$uri/registered_user_qr/$phone-$urlGiftStatus');
    final url = Uri.parse('$uri/registered_user_qr/$phone-$urlGiftStatus');

    try {
      final response = await http.put(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print(data["detail"]);
        if (data["detail"] == "Successfully Admitted") {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Success!',
            text: 'Attendance marked successfully.',
          );
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'ERROR!',
            text: 'Something went wrong. Please try again!',
          );
        }
      } else if (response.statusCode == 404) {
        if (data["detail"] == 'Already admitted') {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: 'Already Marked!',
            text: 'Scanned phone number is already marked as attended.',
          );
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'ERROR!',
            text: 'Something went wrongsss. Please try again!',
          );
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ERROR!',
          text: 'Something went wrong. Please try again!',
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchSecureData(phone, context) async {
    final url = Uri.parse('$uri/registered_user/$phone');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _name = data["Name"];
          _epf_no = data["EPF No"];
          _giftStatus = data["Gift_status"];
          _attendance = data["Attendance"];
        });

        if (_attendance) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: 'Already Marked!',
            text: 'Scanned phone number is already marked as attended.',
          );
        }
      } else {
        if (response.statusCode == 404) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Not Found!',
            text: 'Scanned phone number was not found in the database.',
          );
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'ERROR!',
            text: 'Something went wrong. Please try again!',
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _clearFields() {
    _giftStatus = false;
    _phone_no = '';
    _name = '';
    _epf_no = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                String? res = await SimpleBarcodeScanner.scanBarcode(
                  context,
                  barcodeAppBar: const BarcodeAppBar(
                    appBarTitle: 'Scan QR',
                    centerTitle: false,
                    enableBackButton: true,
                    backButtonIcon: Icon(Icons.arrow_back_ios),
                  ),
                  isShowFlashIcon: true,
                  delayMillis: 500,
                  cameraFace: CameraFace.back,
                  scanFormat: ScanFormat.ALL_FORMATS,
                );
                setState(() {
                  _phone_no = res as String;
                });

                fetchSecureData(_phone_no, context);
              },
              icon: Icon(Icons.qr_code_scanner, size: 40.0),
              label: Text(
                'Scan QR',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Text('Name: $_name', style: _infoStyle),
            const SizedBox(height: 10),
            Text('Phone No: $_phone_no', style: _infoStyle),
            const SizedBox(height: 10),
            Text('EPF No: $_epf_no', style: _infoStyle),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Gift Status:', style: _infoStyle),
                SizedBox(width: 10),
                Checkbox(
                  value: _giftStatus,
                  onChanged:
                      (value) => {
                        setState(() {
                          _giftStatus = value!;
                        }),
                      },
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () => {_updateAttendance(_phone_no, context)},
              label: Text(
                'Mark Attendance',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              icon: Icon(Icons.save, size: 30.0),
            ),
          ],
        ),
      ),
    );
  }
}

class BarcodeWidgetPage {
  const BarcodeWidgetPage();
}
