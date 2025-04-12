import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
  static Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  static StreamSubscription<Position> startListening(
    Function(LatLng) onLocationChanged,
    Function err,
  ) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if (position != null) {
        onLocationChanged(LatLng(position.latitude, position.longitude));
      } else {
        err();
      }
    });
  }
}
