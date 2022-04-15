import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SettingSection {
  static settingSection() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Setari",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.green,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        IconButton(
          iconSize: 100,
          icon: Image.asset(
            'assets/images/settings.png',
          ),
          onPressed: () {
            FlutterBluetoothSerial.instance.openSettings();
          },
        ),
      ],
    );
  }
}
