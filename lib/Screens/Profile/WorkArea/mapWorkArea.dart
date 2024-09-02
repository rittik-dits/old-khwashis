import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/setLocation.dart';
import 'package:khwahish_provider/Services/location.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:geocoding/geocoding.dart';

class MapWorkArea extends StatefulWidget {
  String? workAreaID;
  MapWorkArea({super.key, this.workAreaID});

  @override
  State<MapWorkArea> createState() => MapWorkAreaState();
}

class MapWorkAreaState extends State<MapWorkArea> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController cityName = TextEditingController();
  TextEditingController searchController = TextEditingController();

  double windowWidth = 0;
  double windowHeight = 0;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  Set<Polygon> _polygons = {};
  bool isLoading = false;
  String cityID = '';

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(LocationService.userLatitude, LocationService.userLongitude),
    zoom: 14.4746,
  );

  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    LocationService().fetchLocation();
    getWorkArea();
  }

  void getWorkArea() async {
    var collection = _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea');
    var docs = await collection.doc(widget.workAreaID).get();
    if (docs.exists) {
      cityName.text = '${docs['cityName']}';
      cityID = '${docs['cityID']}';
      for (var item in docs['route']) {
        polylineCoordinates.add(LatLng(item['lat'], item['lng']));
      }
      setState(() {});
      addPolygon();
    }
  }

  void addPolygon() {
    if (polylineCoordinates.isNotEmpty) {
      _addPolygon(polylineCoordinates);
      _calculatePolygonCenter(polylineCoordinates);
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workAreaID != null ? 'Edit your work area' : 'Add your work area'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                polygons: _polygons,
                polylines: {
                  Polyline(
                    polylineId: PolylineId('polyline_id'),
                    color: Colors.blue,
                    points: polylineCoordinates,
                    width: 5,
                  ),
                },
                onTap: (latLng) {
                  _addPolyLine(latLng);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: containerDesign(context),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: searchController,
                      googleAPIKey: "AIzaSyDdfA2gdxkMVdQBsm34Qf-cj-0TFUFQPgI",
                      inputDecoration: InputDecoration(
                        hintText: "Search location",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      countries: ["us", "in"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) async {
                        await _goToThisLocation(
                          latitude: double.parse(prediction.lat!),
                          longitude: double.parse(prediction.lng!),
                        );
                        await _updateCityFromCoordinates(
                          double.parse(prediction.lat!),
                          double.parse(prediction.lng!),
                        );
                      },
                      itemClick: (Prediction prediction) {
                        searchController.text = prediction.description!;
                        searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length),
                        );
                      },
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: polylineCoordinates.length,
                    itemBuilder: (context, index) {
                      return Text(
                        'lat: ${polylineCoordinates[index].latitude}, lng: ${polylineCoordinates[index].longitude}',
                        overflow: TextOverflow.ellipsis,
                        style: kSmallText(),
                      );
                    },
                  ),
                  SizedBox(height: 10.0),
                  KButton(
                    title: 'Delete Current',
                    onClick: () {
                      setState(() {
                        _markers = {};
                        polylineCoordinates = [];
                        _polygons = {};
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: KTextField(
                      title: 'City',
                      controller: cityName,
                      readOnly: true,
                      onClick: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return SetLocation();
                          },
                        ).then((value) => setState(() {
                          cityName.text = LocationService.pickedCity;
                          cityID = LocationService.pickedCityID;
                        }));
                      },
                    ),
                  ),
                  isLoading != true
                      ? KButton(
                          title: 'Save',
                          onClick: () {
                            if (cityName.text != '') {
                              setState(() {
                                isLoading = true;
                              });
                              widget.workAreaID != null ? updateRoute() : addWorkArea();
                            } else {
                              toastMessage(message: 'Select City', colors: kRedColor);
                            }
                          },
                        )
                      : LoadingButton(),
                  SizedBox(height: 10.0),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _goToThisLocation({required double latitude, required double longitude}) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 19.151926040649414,
      ),
    ));
    _addMarker(latitude, longitude, "1", "tr");
  }

  void _addMarker(double latitude, double longitude, String markerId, String markerTitle) {
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: markerTitle),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _addPolyLine(LatLng value) {
    if (polylineCoordinates.length < 4) {
      setState(() {
        polylineCoordinates.add(value);
      });
    } else if (polylineCoordinates.length == 3) {
      setState(() {
        polylineCoordinates.add(polylineCoordinates[0]);
      });
    }
    _addPolygon(polylineCoordinates);
  }

  void _addPolygon(List<LatLng> points) {
    final Polygon polygon = Polygon(
      polygonId: PolygonId('square'),
      points: points,
      fillColor: Colors.blue.withOpacity(0.5),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    );
    setState(() {
      _polygons = {polygon};
    });
  }

  LatLng _calculatePolygonCenter(List<LatLng> polygonPoints) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (LatLng point in polygonPoints) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    _goToThisLocation(latitude: latSum / polygonPoints.length, longitude: lngSum / polygonPoints.length);

    return LatLng(latSum / polygonPoints.length, lngSum / polygonPoints.length);
  }

  Future<void> _updateCityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          cityName.text = place.locality ?? '';
          cityID = place.locality ?? '';
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void updateRoute() {
    List routeList = [];
    for (var item in polylineCoordinates) {
      routeList.add({
        'lat': item.latitude,
        'lng': item.longitude,
      });
    }

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea').doc(widget.workAreaID).update({
        'cityID': cityID,
        'cityName': cityName.text,
        'route': routeList,
      }).then((value) {
        Navigator.pop(context);
        toastMessage(message: 'Area Saved');
      });
    } catch (e) {
      // Handle error
    }
  }

  void addWorkArea() {
    List routeList = [];
    for (var item in polylineCoordinates) {
      routeList.add({
        'lat': item.latitude,
        'lng': item.longitude,
      });
    }

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea').add({
        'cityID': cityID,
        'cityName': cityName.text,
        'route': routeList,
      }).then((value) {
        Navigator.pop(context);
        toastMessage(message: 'Area Saved');
      });
    } catch (e) {
      // Handle error
    }
  }
}



// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_places_flutter/model/prediction.dart';
// import 'package:googleapis/dfareporting/v4.dart';
// import 'package:khwahish_provider/Components/buttons.dart';
// import 'package:khwahish_provider/Components/textField.dart';
// import 'package:khwahish_provider/Components/util.dart';
// import 'package:khwahish_provider/Screens/setLocation.dart';
// import 'package:khwahish_provider/Services/location.dart';
// import 'package:khwahish_provider/Services/serviceManager.dart';
// import 'package:khwahish_provider/Theme/colors.dart';
// import 'package:khwahish_provider/Theme/style.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';

// class MapWorkArea extends StatefulWidget {
//   String? workAreaID;
//   MapWorkArea({super.key, this.workAreaID});

//   @override
//   State<MapWorkArea> createState() => MapWorkAreaState();
// }

// class MapWorkAreaState extends State<MapWorkArea> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController cityName = TextEditingController();
//   TextEditingController searchController = TextEditingController();

//   double windowWidth = 0;
//   double windowHeight = 0;
//   final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
//   Set<Marker> _markers = {};
//   Set<Polygon> _polygons = {};
//   bool isLoading = false;
//   String cityID = '';

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(LocationService.userLatitude, LocationService.userLongitude),
//     zoom: 14.4746,
//   );

//   List<LatLng> polylineCoordinates = [];

//   @override
//   void initState() {
//     super.initState();
//     LocationService().fetchLocation();
//     getWorkArea();
//   }

//   void getWorkArea() async {
//     var collection = _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea');
//     var docs = await collection.doc(widget.workAreaID).get();
//     if(docs.exists){
//       cityName.text = '${docs['cityName']}';
//       cityID = '${docs['cityID']}';
//       for(var item in docs['route']){
//         polylineCoordinates.add(LatLng(item['lat'], item['lng']));
//       }
//       setState(() {});
//       addPolygon();
//     }
//   }

//   void addPolygon() {
//     if(polylineCoordinates.isNotEmpty){
//       _addPolygon(polylineCoordinates);
//       _calculatePolygonCenter(polylineCoordinates);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     windowWidth = MediaQuery.of(context).size.width;
//     windowHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.workAreaID != null ? 'Edit your work area' : 'Add your work area'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.width,
//               width: MediaQuery.of(context).size.width,
//               child: GoogleMap(
//                 mapType: MapType.normal,
//                 initialCameraPosition: _kGooglePlex,
//                 myLocationEnabled: true,
//                 markers: _markers,
//                 onMapCreated: (GoogleMapController controller) {
//                   _controller.complete(controller);
//                 },
//                 polygons: _polygons,
//                 polylines: {
//                   Polyline(
//                     polylineId: PolylineId('polyline_id'),
//                     color: Colors.blue,
//                     points: polylineCoordinates,
//                     width: 5,
//                   ),
//                 },
//                 onTap: (latLng) {
//                   _addPolyLine(latLng);
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(10.0),
//                     decoration: containerDesign(context),
//                     child: GooglePlaceAutoCompleteTextField(
//                       textEditingController: searchController,
//                       googleAPIKey: "AIzaSyDdfA2gdxkMVdQBsm34Qf-cj-0TFUFQPgI",
//                       inputDecoration: InputDecoration(
//                         hintText: "Search location",
//                         border: OutlineInputBorder(),
//                         suffixIcon: Icon(Icons.search),
//                       ),
//                       countries: ["us","in"],
//                       isLatLngRequired: true,
//                       getPlaceDetailWithLatLng: (Prediction prediction) {
//                         _goToThisLocation(
//                           latitude: double.parse(prediction.lat!),
//                           longitude: double.parse(prediction.lng!),
//                         );
//                       },
//                       itemClick: (Prediction prediction) {
//                         searchController.text = prediction.description!;
//                         searchController.selection = TextSelection.fromPosition(
//                           TextPosition(offset: prediction.description!.length),
//                         );
//                       },
//                     ),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     padding: EdgeInsets.zero,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: polylineCoordinates.length,
//                     itemBuilder: (context, index) {
//                       return Text(
//                         'lat: ${polylineCoordinates[index].latitude}, lng: ${polylineCoordinates[index].longitude}',
//                         overflow: TextOverflow.ellipsis,
//                         style: kSmallText(),
//                       );
//                     },
//                   ),
//                   SizedBox(height: 10.0),
//                   KButton(
//                     title: 'Delete Current',
//                     onClick: () {
//                       setState(() {
//                         _markers = {};
//                         polylineCoordinates = [];
//                         _polygons = {};
//                       });
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: KTextField(
//                       title: 'City',
//                       controller: cityName,
//                       readOnly: true,
//                       onClick: () {
//                         showModalBottomSheet(
//                           isScrollControlled: true,
//                           context: context,
//                           builder: (context) {
//                             return SetLocation();
//                           },
//                         ).then((value) => setState(() {
//                           cityName.text = LocationService.pickedCity;
//                           cityID = LocationService.pickedCityID;
//                         }));
//                       },
//                     ),
//                   ),
//                   isLoading != true
//                       ? KButton(
//                           title: 'Save',
//                           onClick: () {
//                             if (cityName.text != '') {
//                               setState(() {
//                                 isLoading = true;
//                               });
//                               widget.workAreaID != null ? updateRoute() : addWorkArea();
//                             } else {
//                               toastMessage(message: 'Select City', colors: kRedColor);
//                             }
//                           },
//                         )
//                       : LoadingButton(),
//                   SizedBox(height: 10.0),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _goToThisLocation({required double latitude, required double longitude}) async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: LatLng(latitude, longitude),
//         zoom: 19.151926040649414,
//       ),
//     ));
//     _addMarker(latitude, longitude, "1", "tr");
//   }

//   void _addMarker(double latitude, double longitude, String markerId, String markerTitle) {
//     final Marker marker = Marker(
//       markerId: MarkerId(markerId),
//       position: LatLng(latitude, longitude),
//       infoWindow: InfoWindow(title: markerTitle),
//     );

//     setState(() {
//       _markers.add(marker);
//     });
//   }

//   void _addPolyLine(LatLng value) {
//     if (polylineCoordinates.length < 4) {
//       setState(() {
//         polylineCoordinates.add(value);
//       });
//     } else if (polylineCoordinates.length == 3) {
//       setState(() {
//         polylineCoordinates.add(polylineCoordinates[0]);
//       });
//     }
//     _addPolygon(polylineCoordinates);
//   }

//   void _addPolygon(List<LatLng> points) {
//     final Polygon polygon = Polygon(
//       polygonId: PolygonId('square'),
//       points: points,
//       fillColor: Colors.blue.withOpacity(0.5),
//       strokeColor: Colors.blue,
//       strokeWidth: 2,
//     );
//     setState(() {
//       _polygons = {polygon};
//     });
//   }

//   LatLng _calculatePolygonCenter(List<LatLng> polygonPoints) {
//     double latSum = 0.0;
//     double lngSum = 0.0;

//     for (LatLng point in polygonPoints) {
//       latSum += point.latitude;
//       lngSum += point.longitude;
//     }

//     _goToThisLocation(latitude: latSum / polygonPoints.length, longitude: lngSum / polygonPoints.length);

//     return LatLng(latSum / polygonPoints.length, lngSum / polygonPoints.length);
//   }

//   void updateRoute() {
//     List routeList = [];
//     for (var item in polylineCoordinates) {
//       routeList.add({
//         'lat': item.latitude,
//         'lng': item.longitude,
//       });
//     }

//     try {
//       _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea').doc(widget.workAreaID).update({
//         'cityID': cityID,
//         'cityName': cityName.text,
//         'route': routeList,
//       }).then((value) {
//         Navigator.pop(context);
//         toastMessage(message: 'Area Saved');
//       });
//     } catch (e) {
//       // Handle error
//     }
//   }

//   void addWorkArea() {
//     List routeList = [];
//     for (var item in polylineCoordinates) {
//       routeList.add({
//         'lat': item.latitude,
//         'lng': item.longitude,
//       });
//     }

//     try {
//       _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea').add({
//         'cityID': cityID,
//         'cityName': cityName.text,
//         'route': routeList,
//       }).then((value) {
//         Navigator.pop(context);
//         toastMessage(message: 'Area Saved');
//       });
//     } catch (e) {
//       // Handle error
//     }
//   }
// }





// class MapWorkArea extends StatefulWidget {

//   String? workAreaID;
//   MapWorkArea({super.key, this.workAreaID});

//   @override
//   State<MapWorkArea> createState() => MapWorkAreaState();
// }

// class MapWorkAreaState extends State<MapWorkArea> {

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController cityName = TextEditingController();

//   double windowWidth = 0;
//   double windowHeight = 0;
//   final Completer<GoogleMapController> _controller =
//   Completer<GoogleMapController>();
//   Set<Marker> _markers = {};
//   Set<Polygon> _polygons = {};
//   bool isLoading = false;
//   String cityID = '';

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     // target: LatLng(37.42796133580664, -122.085749655962),
//     target: LatLng(LocationService.userLatitude, LocationService.userLongitude),
//     zoom: 14.4746,
//   );

//   List<LatLng> polylineCoordinates = [];

//   @override
//   void initState() {
//     super.initState();
//     LocationService().fetchLocation();
//     // ServiceManager().getUserData();
//     getWorkArea();
//   }

//   void getWorkArea() async {
//     var collection = _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea');
//     var docs = await collection.doc(widget.workAreaID).get();
//     if(docs.exists){
//       cityName.text = '${docs['cityName']}';
//       cityID = '${docs['cityID']}';
//       for(var item in docs['route']){
//         polylineCoordinates.add(LatLng(item['lat'], item['lng']));
//       }
//       setState(() {});
//       addPolygon();
//     }
//   }
  
//   void addPolygon(){
//     // polylineCoordinates = ServiceManager.polylineCoordinates;
//     if(polylineCoordinates != []){
//       _addPolygon(polylineCoordinates);
//     }
//     if(polylineCoordinates.isNotEmpty) {
//       _calculatePolygonCenter(polylineCoordinates);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     windowWidth = MediaQuery.of(context).size.width;
//     windowHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.workAreaID != null ?
//         'Edit your work area' : 'Add your work area'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.width,
//               width: MediaQuery.of(context).size.width,
//               child: GoogleMap(
//                 mapType: MapType.normal,
//                 initialCameraPosition: _kGooglePlex,
//                 myLocationEnabled: true,
//                 markers: _markers,
//                 onMapCreated: (GoogleMapController controller) {
//                   _controller.complete(controller);
//                 },
//                 polygons: _polygons,
//                 polylines: {
//                   Polyline(
//                     polylineId: PolylineId('polyline_id'),
//                     color: Colors.blue, // Polyline color
//                     points: polylineCoordinates, // List of LatLng points
//                     width: 5, // Width of the polyline
//                   ),
//                 },
//                 onTap: (latLng){
//                   // _addPolygon([latLng]);
//                   _addPolyLine(latLng);
//                 },
//               ),
//             ),
//             Container(
//               width: MediaQuery.of(context).size.width,
//               padding: EdgeInsets.all(10.0),
//               decoration: containerDesign(context),
//               child: Column(
//                 children: [
//                   ListView.builder(
//                     shrinkWrap: true,
//                     padding: EdgeInsets.zero,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: polylineCoordinates.length,
//                     itemBuilder: (context, index){
//                       return Text('lat: ${polylineCoordinates[index].latitude}, '
//                           'lng: ${polylineCoordinates[index].longitude}',
//                         overflow: TextOverflow.ellipsis,
//                         style: kSmallText(),
//                       );
//                     },
//                   ),
//                   SizedBox(height: 10.0),
//                   KButton(
//                     title: 'Delete Current',
//                     onClick: (){
//                       setState(() {
//                         _markers = {};
//                         polylineCoordinates = [];
//                         _polygons = {};
//                       });
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child:  KTextField(
//                       title: 'City',
//                       controller: cityName,
//                       readOnly: true,
//                       onClick: (){
//                         showModalBottomSheet(
//                           isScrollControlled: true,
//                           context: context,
//                           builder: (context){
//                             return SetLocation();
//                           },
//                         ).then((value) => setState((){
//                           cityName.text = LocationService.pickedCity;
//                           cityID = LocationService.pickedCityID;
//                         }));
//                       },
//                     ),
//                   ),
//                   isLoading != true ? KButton(
//                     title: 'Save',
//                     onClick: (){
//                       if(cityName.text != ''){
//                         setState(() {
//                           isLoading = true;
//                         });
//                         widget.workAreaID != null ?
//                         updateRoute() : addWorkArea();
//                       } else {
//                         toastMessage(message: 'Select City', colors: kRedColor);
//                       }
//                     },
//                   ) : LoadingButton(),
//                   SizedBox(height: 10.0),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _goToThisLocation({required double latitude, required double longitude}) async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(
//           // bearing: 192.8334901395799,
//           target: LatLng(latitude, longitude),
//           // tilt: 59.440717697143555,
//           zoom: 19.151926040649414,
//         )
//     ));
//     _addMarker(latitude, longitude, "1", "tr");
//   }

//   void _addMarker(double latitude, double longitude, String markerId, String markerTitle) {
//     final Marker marker = Marker(
//       markerId: MarkerId(markerId),
//       position: LatLng(latitude, longitude),
//       infoWindow: InfoWindow(title: markerTitle),
//     );

//     setState(() {
//       _markers.add(marker);
//     });
//   }

//   void _addPolyLine(LatLng value){
//     if(polylineCoordinates.length < 4){
//       setState(() {
//         polylineCoordinates.add(value);
//       });
//     } else if (polylineCoordinates.length == 3){
//       setState(() {
//         polylineCoordinates.add(polylineCoordinates[0]);
//       });
//     }
//     _addPolygon(polylineCoordinates);
//   }

//   void _addPolygon(List<LatLng> points) {
//     final Polygon polygon = Polygon(
//       polygonId: PolygonId('square'),
//       points: points,
//       fillColor: Colors.blue.withOpacity(0.5),
//       strokeColor: Colors.blue,
//       strokeWidth: 2,
//     );
//     setState(() {
//       _polygons = {polygon};
//     });
//   }

//   LatLng _calculatePolygonCenter(List<LatLng> polygonPoints) {
//     double latSum = 0.0;
//     double lngSum = 0.0;

//     for (LatLng point in polygonPoints) {
//       latSum += point.latitude;
//       lngSum += point.longitude;
//     }

//     _goToThisLocation(latitude: latSum / polygonPoints.length,
//         longitude: lngSum / polygonPoints.length);

//     return LatLng(
//       latSum / polygonPoints.length,
//       lngSum / polygonPoints.length,
//     );
//   }

//   void updateRoute() {

//     List routeList = [];
//     for(var item in polylineCoordinates){
//       routeList.add({
//         'lat' : item.latitude,
//         'lng' : item.longitude,
//       });
//     }

//     try {
//       _firestore.collection('provider').doc(ServiceManager.userID)
//           .collection('workArea').doc(widget.workAreaID).update({
//         'cityID': cityID,
//         'cityName': cityName.text,
//         'route': routeList,
//       }).then((value) {
//         Navigator.pop(context);
//         toastMessage(message: 'Area Saved');
//       });
//     } catch (e){
//       // toastMessage(message: 'Something went wrong');
//     }
//   }


//   void addWorkArea() {

//     List routeList = [];
//     for(var item in polylineCoordinates){
//       routeList.add({
//         'lat' : item.latitude,
//         'lng' : item.longitude,
//       });
//     }

//     try {
//       _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea').add({
//         'cityID': cityID,
//         'cityName': cityName.text,
//         'route': routeList,
//       }).then((value) {
//         Navigator.pop(context);
//         toastMessage(message: 'Area Saved');
//       });
//     } catch (e){
//       // toastMessage(message: 'Something went wrong');
//     }
//   }
// }

