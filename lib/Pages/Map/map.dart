import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:seecine/Pages/Map/movie_location_autocomplete.dart';
import 'package:seecine/Pages/Map/select_movie.dart';
import 'map_constant.dart';

// import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CinemaMap extends StatefulWidget {
  @override
  State<CinemaMap> createState() => CinemaMapState();
}

class CinemaMapState extends State<CinemaMap> {
  Completer<GoogleMapController> _controller = Completer();
  MapType _googleMapType = MapType.normal;
  Set<Marker> _markers = Set();
  List _cinemaset = [];
  var address;
  var cinemaname;
  var cinemalat;
  var cinemalng;

  @override
  void initState() {
    super.initState();
    _searchCinema();
    
    // _markers.add(
    //   Marker(markerId: MarkerId('myInitialPosition'), position:
    //   LatLng(lati, long), infoWindow: InfoWindow(title:
    //   'My Position'))
    // );
  }

  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(lati, long),
    zoom: 14,
  );

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  // 현재위치 가져오기
  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lati = position.latitude;
    long = position.longitude;
    _searchCinema();
  }

  void _getinitLocation() async {
    final CameraPosition _Myposition =
        CameraPosition(target: LatLng(lati, long), zoom: 14);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_Myposition));
  }

  // Haversine Formula 이용
  Future<double> _getdistance(
    var loc1,
    var loc2,
  ) async {
    double distance;
    double radius = 6371; // 지구반지름(km)
    double toRadian = pi / 180;

    double deltaLat = (loc1[0] - loc2[0]) * toRadian;
    double deltaLng = (loc1[1] - loc2[1]) * toRadian;

    double sindeltaLat = sin(deltaLat.abs() / 2);
    double sindeltaLng = sin(deltaLng.abs() / 2);
    double squareRoot = sqrt(sindeltaLat * sindeltaLat +
        cos(loc1[0] * toRadian) *
            cos(loc2[0] * toRadian) *
            sindeltaLng *
            sindeltaLng);

    distance = 2 * radius * asin(squareRoot);
    dis = distance;

    return distance;
  }

  void _getLatLng(
    var cinemaname,
    var placeID,
  ) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/geocode/json';
    String url = '$baseURL?place_id=$placeID&key=$API_KEY';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        cinemalat = data['results'][0]['geometry']['location']['lat'];
        cinemalng = data['results'][0]['geometry']['location']['lng'];
        address = data['results'][0]['formatted_address'];
        // Cinemalist.add(cinemaname);
        _getdistance([lati, long], [cinemalat, cinemalng]);

        print(cinemaname);
        print(placeID);
        print(cinemalat.toString() + ', ' + cinemalng.toString());
      }
    }
  }

  void _searchCinema() async {
    if (lati == 0.0 && long == 0.0) {
      _getCurrentLocation();
    }
    final GoogleMapController controller = await _controller.future;
    List Cinema = ['CGV', '롯데시네마', '메가박스'];
    List RadiusRange = [750, 1500, 3000, 6000, 12000, 24000];   // zoom level : [17,16,15,14,13,12]
    List ZoomLevel = [15.0,14.0,13.0,12.0,11.0,10.0];
    // var circle;
    int cnt = 0;

    _getinitLocation();
    _markers.clear;

    print('현재위치는 ' + lati.toString() + ', ' + long.toString() + ' 입니다.');
    print('주변 영화관 탐색을 시작합니다...');

    for (int x = 0; x < 6; x++) {
      int radius = RadiusRange[x];
      print(radius.toString() + 'm 탐색결과');
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$API_KEY&location=$lati%2C$long&radius=$radius&language=ko&keyword=영화관';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(lati, long),
            ),
          );

          setState(() {
            final foundCinema = data['results'];
            // print(foundPlaces.length);

            for (int i = 0; i < foundCinema.length; i++) {
              // print(foundPlaces[i]['name']);
              for (int j = 0; j < 3; j++) {
                if (foundCinema[i]['name'].contains(Cinema[j])) {
                  _getLatLng(
                      foundCinema[i]['name'], foundCinema[i]['place_id']);
                  cnt++;
                  List location = [
                    foundCinema[i]['geometry']['location']['lat'],
                    foundCinema[i]['geometry']['location']['lng']
                  ];
                  _getdistance([lati, long], location);
                  Cinemalist.add(foundCinema[i]['name'] +
                      '!' +
                      dis.toStringAsFixed(2));
                  _markers.add(
                    Marker(
                      markerId: MarkerId(foundCinema[i]['place_id']),
                      position: LatLng(location[0], location[1]),
                      infoWindow: InfoWindow(
                        title: foundCinema[i]['name'] +
                            '(' +
                            dis.toStringAsFixed(2) +
                            'km)',
                        snippet: foundCinema[i]['vicinity'],
                      ),
                    ),
                  );
                }
              }
            }
          });
        } else {
          if (radius == 30000) {
            // 경고팝업메시지 출력해야함
            print('가까운 영화관을 찾을 수 없습니다. 다른 장소를 선택해주세요.');
          } 
        }
      }
      if (cnt > 1) {
        print('주변에 ' + cnt.toString() + '개의 영화관이 있습니다. 탐색을 마칩니다.');
        print(Cinemalist);
        count = cnt;
        // print('$minLat, $minLon, $maxLat, $maxLon');
        controller.animateCamera(CameraUpdate.zoomTo(ZoomLevel[x]));
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.9,
            child: GoogleMap(
              mapType: _googleMapType,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: _markers,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 40, right: 10),
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton.extended(
                    heroTag: null,
                    label: Text('다른 위치로'),
                    icon: Icon(Icons.search),
                    elevation: 8,
                    backgroundColor: Colors.orange[400],
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MoveLocation()),
                      );
                    }),
                FloatingActionButton.extended(
                  heroTag: null,
                  label: Text('현재 위치로'),
                  icon: Icon(Icons.room),
                  elevation: 8,
                  backgroundColor: Color.fromARGB(255, 201, 183, 28),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
          ),
          Container(
            child: Column(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
              ),
              Text('현재 설정한 위치에서 $count 개의 영화관이 탐색되었습니다'),
              MaterialButton(
                  child: Text('{ 영화관 선택하기 }'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => selectMovie()));
                  }),
            ]),
          )
        ],
      ),
    );
  }
}


