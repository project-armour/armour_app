import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationHelper {
  static final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
    foregroundNotificationConfig: ForegroundNotificationConfig(
      notificationText: "Location in use",
      notificationTitle: "Armour",
    ),
  );
  static Future<bool> checkPermissions(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    while (permission != LocationPermission.always) {
      if (context.mounted) {
        if (permission == LocationPermission.whileInUse) {
          await showDialog(
            context: context,
            builder: (context) => LocationPermissionDialog(requestAlways: true),
          );
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.always) return true;
          await Geolocator.openAppSettings();
        } else {
          await showDialog(
            context: context,
            builder: (context) => LocationPermissionDialog(),
          );
          permission = await Geolocator.requestPermission();
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
    }

    return true;
  }

  static Future<StreamSubscription<Position>> startListening(
    Function(LatLng) onLocationChanged,
    Function err,
  ) async {
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
  final bool requestAlways;

  const LocationPermissionDialog({super.key, this.requestAlways = false});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(
              LucideIcons.mapPin200,
              size: 140,
              color: ColorScheme.of(context).primary,
            ),
            SizedBox(height: 12),
            Text(
              requestAlways
                  ? "Background location access required"
                  : "Access device location",
              style: TextTheme.of(context).headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text.rich(
              TextSpan(
                style: TextTheme.of(context).bodyLarge,
                children:
                    (requestAlways
                        ? <InlineSpan>[
                          WidgetSpan(
                            child: SizedBox(
                              height: 22,
                              child: SvgPicture.asset(
                                "assets/images/gradient-wordmark.svg",
                                height: 14,
                              ),
                            ),
                          ),
                          TextSpan(text: " needs access to your location "),
                          TextSpan(
                            text: "in the background",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ". Navigate to "),
                          TextSpan(
                            text: "Permissions > Location",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: " in the next screen and select "),
                          TextSpan(
                            text: "Allow all the time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ]
                        : <InlineSpan>[
                          WidgetSpan(
                            child: SizedBox(
                              height: 22,
                              child: SvgPicture.asset(
                                "assets/images/gradient-wordmark.svg",
                                height: 14,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: " needs access to your location to enable ",
                          ),
                          TextSpan(
                            text: "alerts and location sharing",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ". Enable "),
                          TextSpan(
                            text: "Precise Location",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: " access in the next screen."),
                        ]),
              ),
              textAlign: TextAlign.justify,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text("Close App"),
                ),
                FilledButton(
                  onPressed: () {
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
