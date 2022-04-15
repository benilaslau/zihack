import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'package:projectapp/helper/helper.dart';
import 'package:projectapp/widgets/app_bar_actions.dart';
import 'package:projectapp/widgets/get_device_items.dart';
import 'package:projectapp/widgets/charge_package.dart';
import 'package:projectapp/widgets/discharge_package.dart';
import 'package:projectapp/widgets/settings_section.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  final textFieldController = TextEditingController();

  final loadPackage = TextEditingController();
  final testLEDOFFFieldController = TextEditingController();

  final upFieldController = TextEditingController();
  final downFieldController = TextEditingController();
  final rightFieldController = TextEditingController();
  final leftFieldController = TextEditingController();

  bool checkIfPressing = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    BluetoothHelper.enableBluetooth(_bluetoothState, getPairedDevices);

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Green Delivery"),
          backgroundColor: Colors.green,
          actions: <Widget>[
            AppBarActions.appBarActions(getPairedDevices, _scaffoldKey),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      activeTrackColor: Colors.lightGreen[200],
                      activeColor: Colors.green,
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "SELECTATI LOCKER:",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.lightGreen,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 148,
                      child: DropdownButton(
                        isExpanded: true,
                        items: GetDeviceItems.getDeviceItems(_devicesList),
                        onChanged: (value) => setState(() => _device = value),
                        value: _devicesList.isNotEmpty ? _device : null,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: _isLoading
                          ? SizedBox(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              height: 24,
                              width: 24,
                            )
                          : Icon(Icons.sync),
                      onPressed: _isButtonUnavailable
                          ? null
                          : _connected
                              ? _disconnect
                              : _connect,
                      label: _isLoading
                          ? Text("Loading..")
                          : Text(_connected ? 'Deconectare' : 'Connectare'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Background color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(),
              _connected
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                "Pune Colet",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.lightGreen,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              iconSize: 100,
                              icon: Image.asset(
                                'assets/images/courier.png',
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChargePackageScreen(
                                            writeToBluetooth:
                                                _sendTextMessageToBluetooth)));
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                "Ridica Colet",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.lightGreen,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              iconSize: 100,
                              icon: Image.asset(
                                'assets/images/package.png',
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DischargePackareScreen(
                                                writeToBluetooth:
                                                    _sendTextMessageToBluetooth)));
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      BluetoothHelper.show(_scaffoldKey, 'No device selected');
      setState(() {
        _isButtonUnavailable = false;
      });
    } else {
      if (!isConnected) {
        setState(() {
          _isLoading = true;
        });
        try {
          await BluetoothConnection.toAddress(_device.address)
              .then((_connection) {
            print('Connected to the device');
            connection = _connection;
            setState(() {
              _connected = true;
            });

            connection.input.listen(null).onDone(() {
              if (isDisconnecting) {
                print('Disconnecting locally!');
              } else {
                print('Disconnected remotely!');
              }
              if (this.mounted) {
                setState(() {});
              }
            });
            BluetoothHelper.show(_scaffoldKey, 'Device connected');
          }).catchError((error) {
            print('Cannot connect, exception occurred');
            print(error);
            BluetoothHelper.show(
                _scaffoldKey, 'Could not establish connection');
          });

          setState(() => _isButtonUnavailable = false);
        } catch (error) {
          BluetoothHelper.show(_scaffoldKey, 'Could not establish connection');
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _deviceState = 0;
    });
    if (connection == null) {
      setState(() {
        _connected = false;
      });
    } else {
      await connection.dispose();
    }
    BluetoothHelper.show(_scaffoldKey, 'Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _sendTextMessageToBluetooth(String message) async {
    print(message);
    if (connection.isConnected) {
      connection.output.add(utf8.encode(message + "\r\n"));
      await connection.output.allSent;
    } else {
      BluetoothHelper.show(_scaffoldKey, 'Connection lost. Please retry');
    }

    // setState(() {
    //   _deviceState = -1; // device off
    // });
  }
}
