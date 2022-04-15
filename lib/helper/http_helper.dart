import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/model/parcel.dart';

//https://api.openweathermap.org
///data/2.5/weather?q=London&appid=339614bac8e52a08c6fa9372c3071301

class HttpHelper {
  final String authority = 'greendeliverywebapi.azurewebsites.net';
  final String parcelPath = 'api/Parcels';
  final String courierParcels = 'GetCourierParcels';
  final String clientParcels = 'GetClientParcels';

  // Map<String, dynamic> parameters = {'q': city, 'appid': apiKey};

  Future<List<Parcel>> getCourierParcels() async {
    Uri uri = Uri.http(authority, "${parcelPath}/${courierParcels}");
    print(uri);
    http.Response response = await http.get(uri);
    // Map<String, dynamic> data =
    Iterable l = json.decode(response.body);
    List<Parcel> parcels =
        List<Parcel>.from(l.map((model) => Parcel.fromJson(model)));
    print(parcels);
    return parcels;
  }

  Future<List<Parcel>> getClientParcels() async {
    Uri uri = Uri.https(authority, "${parcelPath}/${clientParcels}");
    print(uri);
    http.Response response = await http.get(uri);
    // Map<String, dynamic> data =
    Iterable l = json.decode(response.body);
    List<Parcel> parcels =
        List<Parcel>.from(l.map((model) => Parcel.fromJson(model)));
    print(parcels);
    return parcels;
  }
}
