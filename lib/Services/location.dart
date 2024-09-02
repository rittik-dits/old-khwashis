import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  static String pickedCity = '';
  static String pickedCityID = '';
  static String userLocation = '';
  static String pickAddress = '';
  static double userLatitude = 37.42796133580664;
  static double userLongitude = -122.085749655962;

  void fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double latitude = position.latitude;
    double longitude = position.longitude;
    userLatitude = position.latitude;
    userLongitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0]; // Assuming you want the first result

    userLocation = '${place.street ?? ''}, ${place.subLocality}, '
        '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}';
  }

  void setPickAddress({required double latitude, required double longitude,}) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0]; // Assuming you want the first result

    pickAddress = '${place.street ?? ''}, ${place.subLocality}, '
        '${place.locality ?? ''}, ${place.administrativeArea ?? ''},'
        ' ${place.postalCode ?? ''}';
  }
}

