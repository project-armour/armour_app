import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
  static Future<bool> checkPermissions(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    requestPermission() async {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      } else {
        return true;
      }
    }

    if (context.mounted) {
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder:
              (BuildContext context) => Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Text(
                        "Access device location",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text:
                                  "The app requires access to the device's location to work correctly. Please allow ",
                            ),
                            TextSpan(
                              text: "Precise",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: " location access in the next screen.",
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 12,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          FilledButton(
                            onPressed: () {
                              requestPermission();
                              Navigator.pop(context);
                            },
                            child: Text("Continue"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        );
      }
      if (permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        return false;
      }
      return true;
    } else {
      return false;
    }
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
