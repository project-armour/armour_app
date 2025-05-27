import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
    foregroundNotificationConfig: ForegroundNotificationConfig(
      notificationText: "Location in use",
      notificationTitle: "Armour",
      enableWakeLock: true,
    ),
  );

  static Future<bool> checkPermissions(BuildContext context) async {
    // First check if permission already exists
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is already granted as 'always', return true
    if (permission == LocationPermission.always) {
      return true;
    }

    // If permission is denied forever, open app settings
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder:
              (BuildContext context) =>
                  LocationPermissionDialog(isAlwaysRequired: true),
        );
        Geolocator.openAppSettings();
      }
      return false;
    }

    // Keep requesting permission until granted as 'always' or permanently denied
    bool permissionGranted = false;
    while (!permissionGranted &&
        context.mounted &&
        permission != LocationPermission.deniedForever) {
      // Show dialog explaining why we need permission
      if ((permission == LocationPermission.denied ||
              permission == LocationPermission.whileInUse) &&
          context.mounted) {
        await showDialog(
          context: context,
          builder:
              (BuildContext context) => LocationPermissionDialog(
                isAlwaysRequired: permission == LocationPermission.whileInUse,
              ),
        );
      }

      // Request permission
      permission = await Geolocator.requestPermission();

      // Check result - only accept 'always' permission
      if (permission == LocationPermission.always) {
        permissionGranted = true;
      } else if (permission == LocationPermission.whileInUse &&
          context.mounted) {
        // If user only granted 'whileInUse', show dialog again explaining we need 'always' permission
        await showDialog(
          context: context,
          builder:
              (BuildContext context) =>
                  LocationPermissionDialog(isAlwaysRequired: true),
        );
        Geolocator.openAppSettings();
      } else if (permission == LocationPermission.deniedForever &&
          context.mounted) {
        Geolocator.openAppSettings();
        return false;
      }
    }

    return permissionGranted;
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

class LocationPermissionDialog extends StatelessWidget {
  final bool isAlwaysRequired;

  const LocationPermissionDialog({super.key, this.isAlwaysRequired = false});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              isAlwaysRequired
                  ? "Background location access required"
                  : "Access device location",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text:
                        isAlwaysRequired
                            ? "This app requires background access to your location at all times. Please select 'Allow all the time' in the next screen."
                            : "The app requires background access to the device's location to work correctly. Please allow precise location access in the next screen.",
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
                    if (!isAlwaysRequired) {
                      LocationHelper.checkPermissions(context);
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Continue"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
