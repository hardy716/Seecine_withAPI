import 'package:flutter/material.dart';
import 'package:seecine/Pages/Map/map_constant.dart';


// import 'package:latlong2/latlong.dart';

class selectMovie extends StatefulWidget {
  @override
  _selectMovieState createState() => _selectMovieState();
}

class _selectMovieState extends State<selectMovie> {
  //distance 측정해서 비교, nearbysearch된 영화관 거리 순으로 정렬
  // _getdistance (
  //   var loc1,
  //   var loc2
  // ) {

  //   final Distance distance = Distance();
  //   final double dis = distance.as(LengthUnit.Kilometer,
  //   LatLng(loc1[0], loc1[1]), LatLng(loc2[0], loc2[1]));

  //   print(dis);

  //   return dis;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              SizedBox(height: 15),
              //   ListView.builder(
              //   physics: NeverScrollableScrollPhysics(),
              //   shrinkWrap: true,
              //   itemCount: null,
              //   itemBuilder: (context, index) {
              //     return
              //     ListTile(
              //       title: Text(''),
              //       onTap: () {
              //       },
              //     );
              //   },
              // ),
              Text('    example page'),
              Text('    $Cinemalist'),
              SizedBox(height: 20),
              FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (builder) => ShowPage(
                    //           MvLstT: Cinemalist.toList(),
                    // )));
                  })
            ]),
          )),
    );
  }
}
