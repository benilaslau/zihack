import 'package:flutter/material.dart';
import 'package:projectapp/helper/helper.dart';

import '../data/model/parcel.dart';
import '../helper/http_helper.dart';

// class DischargePackage {
//   showSerialDialog(context, textFieldController, _connected, _scaffoldKey,
//       Function _sendTextMessageToBluetooth) {
//     return showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//           backgroundColor: Color.fromRGBO(227, 227, 227, 1),
//           insetPadding: EdgeInsets.all(0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Card(
//                 shape: RoundedRectangleBorder(
//                   side: new BorderSide(color: Colors.blueAccent),
//                   borderRadius: BorderRadius.circular(4.0),
//                 ),
//                 elevation: 10,
//                 child: TextField(
//                   controller: textFieldController,
//                   decoration: InputDecoration(
//                       contentPadding: EdgeInsets.all(5),
//                       border: InputBorder.none,
//                       hintText: 'write something to send to the bluetooth'),
//                   onSubmitted: (value) {
//                     if (_connected) {
//                       if (value.isEmpty) {
//                         BluetoothHelper.show(_scaffoldKey,
//                             "please write something to send to bluetooth");
//                         return;
//                       }
//                       print(value);
//                       print(textFieldController.text);
//                       _sendTextMessageToBluetooth(value);
//                       textFieldController.clear();
//                     } else {
//                       BluetoothHelper.show(
//                           _scaffoldKey, "please connect to a device");
//                     }
//                   },
//                 ),
//               )
//             ],
//           )),
//     );

//     return Scaffold(
//       appBar: AppBar(title: Text("Training sessions")),
//       body: ListView(
//         children: getContent(),
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.add),
//       //   onPressed: () {
//       //     showAddSessionDialog(context);
//       //   },
//       // ),
//     );
//   }

//   List<Widget> getContent() {
//     List<Widget> tiles = [];
//     //sessions.forEach((element) {
//     tiles.add(ListTile(
//       title: Text('Colet 1'),
//       subtitle: Text('AWB00002'),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(onPressed: () {}, icon: Icon(Icons.add)),
//           IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
//         ],
//       ),
//     ));
//     //});

//     return tiles;
//   }
// }

class DischargePackareScreen extends StatefulWidget {
  final Function writeToBluetooth;
  const DischargePackareScreen({key, Function this.writeToBluetooth})
      : super(key: key);

  @override
  State<DischargePackareScreen> createState() => _DischargePackareScreenState();
}

class _DischargePackareScreenState extends State<DischargePackareScreen> {
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
      appBar: AppBar(title: Text("Ridicare colet")),
      body: Column(
        children: [
          Expanded(
            child: _isEmpty
                ? Center(
                    child: Text("Nu aveti niciun colet"),
                  )
                : ListView(
                    children: getContent(),
                  ),
          ),
          Text(
            "Multumim ca ati ales livrare ECO",
            style: TextStyle(fontSize: 20),
          ),
          Icon(
            Icons.eco,
            size: 48,
            color: Colors.lightGreen,
          )
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
          title: Text(element.dischargeCode),
          subtitle: Text("Coletul ${element.boxId.toString()}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    widget.writeToBluetooth(element.dischargeCode.toString());
                  },
                  icon: Icon(Icons.download)),
            ],
          ),
        ));
      });
    }

    return tiles;
  }

  Future getData() async {
    HttpHelper helper = HttpHelper();
    result = await helper.getClientParcels();
    if (result == null || result.isEmpty) {
      _isEmpty = true;
    } else {
      _isEmpty = false;
    }
    setState(() {});
  }
}
