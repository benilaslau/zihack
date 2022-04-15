import 'package:flutter/material.dart';
import 'package:projectapp/helper/helper.dart';

import '../data/model/parcel.dart';
import '../helper/http_helper.dart';

// class ChargePackage {
//   static showLedTestDialog(context, _deviceState, loadPackage, unloadPackage,
//       _connected, _scaffoldKey, _sendTextMessageToBluetooth) {
//     return showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//           backgroundColor: Color.fromRGBO(227, 227, 227, 1),
//           insetPadding: EdgeInsets.all(0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                     side: new BorderSide(
//                       color: Colors.blueAccent,
//                       width: 3,
//                     ),
//                     borderRadius: BorderRadius.circular(4.0),
//                   ),
//                   elevation: _deviceState == 0 ? 4 : 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Container(
//                           width: 50,
//                           child: TextField(
//                             textAlign: TextAlign.center,
//                             controller: loadPackage,
//                             decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(5),
//                                 border: new OutlineInputBorder(
//                                     borderSide:
//                                         new BorderSide(color: Colors.teal)),
//                                 hintText: 'Test'),
//                           ),
//                         ),
//                         FlatButton(
//                           onPressed: () {
//                             if (_connected) {
//                               if (loadPackage.text.isEmpty) {
//                                 BluetoothHelper.show(
//                                   _scaffoldKey,
//                                   "please write something to send to bluetooth",
//                                 );
//                                 return;
//                               }

//                               print(loadPackage.text);
//                               _sendTextMessageToBluetooth(loadPackage.text);
//                             } else {
//                               BluetoothHelper.show(
//                                   _scaffoldKey, "please connect to a device");
//                             }
//                           },
//                           child: Text(
//                             "ON",
//                             style: TextStyle(color: Colors.greenAccent),
//                           ),
//                         ),
//                         Container(
//                           width: 50,
//                           child: TextField(
//                             textAlign: TextAlign.center,
//                             controller: unloadPackage,
//                             decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(5),
//                                 border: new OutlineInputBorder(
//                                     borderSide:
//                                         new BorderSide(color: Colors.teal)),
//                                 hintText: 'Test'),
//                           ),
//                         ),
//                         FlatButton(
//                           onPressed: () {
//                             print(_connected);
//                             if (_connected) {
//                               if (unloadPackage.text.isEmpty) {
//                                 BluetoothHelper.show(_scaffoldKey,
//                                     "please write something to send to bluetooth");
//                                 return;
//                               }

//                               print(unloadPackage.text);
//                               _sendTextMessageToBluetooth(unloadPackage.text);
//                             } else {
//                               BluetoothHelper.show(
//                                   _scaffoldKey, "please connect to a device");
//                             }
//                           },
//                           child: Text("OFF",
//                               style: TextStyle(color: Colors.redAccent)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )),
//     );
//   }
// }

class ChargePackageScreen extends StatefulWidget {
  final Function writeToBluetooth;
  const ChargePackageScreen({key, Function this.writeToBluetooth})
      : super(key: key);

  @override
  State<ChargePackageScreen> createState() => _ChargePackageScreenState();
}

class _ChargePackageScreenState extends State<ChargePackageScreen> {
  final textFieldController = TextEditingController();
  List<Parcel> result;
  bool _isEmpty = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Depunere colet")),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: getData,
              child: Text('Refresh colete', style: TextStyle(fontSize: 20))),
          Expanded(
            child: _isEmpty
                ? Center(
                    child: Text("Nu exista niciun colet pentru incarcat"),
                  )
                : ListView(
                    children: getContent(),
                  ),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     showAddSessionDialog(context);
      //   },
      // ),
    );
  }

  List<Widget> getContent() {
    List<Widget> tiles = [];
    if (result != null) {
      result.forEach((element) {
        tiles.add(ListTile(
          title: Text(element.chargeCode),
          subtitle: Text("Coletul ${element.boxId.toString()}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    widget.writeToBluetooth(element.chargeCode.toString());
                  },
                  icon: Icon(Icons.upload)),
            ],
          ),
        ));
      });
    }

    return tiles;
  }

  Future getData() async {
    HttpHelper helper = HttpHelper();
    result = await helper.getCourierParcels();
    if (result == null || result.isEmpty) {
      _isEmpty = true;
    } else {
      _isEmpty = false;
    }
    setState(() {});
  }
}
