import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectapp/helper/helper.dart';

class AppBarActions {
  static appBarActions(getPairedDevices, _scaffoldKey) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          onPressed: () async {
            // So, that when new devices are paired
            // while the app is running, user can refresh
            // the paired devices list.
            await getPairedDevices().then((_) {
              BluetoothHelper.show(_scaffoldKey, 'Device list refreshed');
            });
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            FlutterBluetoothSerial.instance.openSettings();
          },
        ),
      ],
    );
  }
}
