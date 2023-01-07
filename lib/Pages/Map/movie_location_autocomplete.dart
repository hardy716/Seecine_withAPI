import 'package:flutter/material.dart';
import 'package:seecine/Pages/Map/map.dart';
import 'package:seecine/Pages/Map/map_constant.dart';

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MoveLocation extends StatefulWidget {
  MoveLocation({Key? key}) : super(key: key);

  @override
  _MoveLocationState createState() => _MoveLocationState();
}

class _MoveLocationState extends State<MoveLocation> {
  Completer<GoogleMapController> _googlecontroller = Completer();
  Set<Marker> _markers = Set();
  List<dynamic> _placeList = [];
  var _controller = TextEditingController();
  var uuid = new Uuid();
  var address;
  var lat;
  var lng;
  late String _sessionToken;

  @override
  void initState() {
    _sessionToken = '';
    super.initState();
    _controller.addListener(() {
      _onChanged();
    });
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    // String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String url =
        '$baseURL?input=$input&key=$API_KEY&sessiontoken=$_sessionToken&language=ko&components=country:kr';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  // _getMyLat() async{
  //   Position position = await Geolocator.
  //   getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   return position.latitude;
  // }

  // _getMyLng() async{
  //   Position position = await Geolocator.
  //   getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   return position.longitude;
  // }

  void _getLatLng(
    var placeID,
  ) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/geocode/json';
    String url = '$baseURL?place_id=$placeID&key=$API_KEY';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        lat = data['results'][0]['geometry']['location']['lat'];
        lng = data['results'][0]['geometry']['location']['lng'];
        address = data['results'][0]['formatted_address'];
        _moveCamera(placeID, lat, lng);
        print(lat);
        print(lng);
        print(address);
      }
    }
  }

  void _moveCamera(
    var placeID,
    var cinemalat,
    var cinemalng,
  ) async {
    if (_markers.length > 0) {
      setState(() {
        _markers.clear();
      });
    }
    GoogleMapController controller = await _googlecontroller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(cinemalat, cinemalng),
      ),
    );
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(placeID),
          position: LatLng(cinemalat, cinemalng),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.376308, 126.971114),
                      zoom: 16,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _googlecontroller.complete(controller);
                    },
                    myLocationButtonEnabled: true,
                    markers: _markers,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                      hintText: "원하는 장소를 입력하세요.",
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: Icon(Icons.map),
                      suffixIcon: Container(
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // VerticalDivider(
                              //   color: Colors.grey,
                              //   thickness: 1,
                              // ),
                              IconButton(
                                onPressed: () {
                                  _controller.text = '';
                                },
                                icon: Icon(
                                  Icons.cancel,
                                ),
                              ),
                              SizedBox(),
                              IconButton(
                                onPressed: () {
                                  lati = lat;
                                  long = lng;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CinemaMap()),
                                  );
                                },
                                icon: Icon(
                                  Icons.send,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _placeList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_placeList[index]["description"]),
                      onTap: () {
                        _controller.text = _placeList[index]
                            ['structured_formatting']['main_text'];
                        print(_placeList[index]['description']);
                        print(_placeList[index]['place_id']);
                        print(_placeList[index]['structured_formatting']
                            ['main_text']);
                        _getLatLng(_placeList[index]['place_id']);
                      },
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }
}
