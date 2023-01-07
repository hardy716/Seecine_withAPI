// import 'package:geolocator/geolocator.dart';

// API-KEY 정보
var API_KEY = 'AIzaSyCnbYWVl6pSCB8uU65TlOia1qepKn0iIb4';

// 현재 위치 정보
var lati = 37.3763079;
var long = 126.9711144;

// 탐색된 영화관 정보
var Cinemalist = <String>{};
var count = 0;
var dis = 0.0;

// 지도 마커 위치에 따른 zoom level 설정
// double minLat = 90.0;
// double minLon = 180.0;
// double maxLat = -90.0;
// double maxLon = -180.0;