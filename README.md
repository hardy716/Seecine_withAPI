# Seecine
영화정보통합검색 플러터 앱

### <SeeCine API 적용 코드 Preview>

#### 1. Places API > [Nearby Search](https://developers.google.com/maps/documentation/places/web-service/search-nearby?authuser=1) (점진적으로 탐색 범위 증가)

```dart
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
```

#### 2. [Geocoding API](https://developers.google.com/maps/documentation/geocoding?authuser=1) & Places API > [Place Autocomplete](https://developers.google.com/maps/documentation/places/web-service/autocomplete?authuser=1) (장소 검색어 자동완성)
```dart
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
```

#### 3. [Geocoding API](https://developers.google.com/maps/documentation/geocoding?authuser=1) (특정 장소의 위치 정보 : 위도/경도/장소ID 등) 
```dart
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
```

