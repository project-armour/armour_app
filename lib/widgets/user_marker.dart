import 'package:armour_app/widgets/marker_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserMarker {
  UserMarker({
    required this.context,
    required this.coordinates,
    required this.name,
    required this.userId,
    this.isSharing = false,
    this.isUser = false,
    this.imageUrl,
  });

  final BuildContext context;
  final String userId;
  bool isUser;
  bool isSharing;
  LatLng coordinates;
  String name;
  String? imageUrl = 'assets/images/default_profile.png';

  /* TODO: FIX 
  // Function to animate marker movement
  Future<void> animateMoveTo(
    LatLng newCoordinates,
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    final LatLng startPosition = coordinates;
    final double startLat = startPosition.latitude;
    final double startLng = startPosition.longitude;
    final double endLat = newCoordinates.latitude;
    final double endLng = newCoordinates.longitude;

    final AnimationController controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: curve,
    );

    controller.addListener(() {
      final double t = animation.value;
      final double lat = startLat + (endLat - startLat) * t;
      final double lng = startLng + (endLng - startLng) * t;

      coordinates = LatLng(lat, lng);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        coordinates = newCoordinates;
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    await controller.forward();
  }
  */

  // Remove the _getTickerProvider method as we no longer need it
  Marker get() {
    return Marker(
      width: 160,
      height: 80,
      point: coordinates,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 2,
            children: [
              Stack(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      foreground:
                          Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color =
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      color:
                          isSharing
                              ? (isUser
                                  ? Colors.greenAccent
                                  : Colors.lightBlueAccent)
                              : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              MarkerStatus(isOnline: isSharing),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isUser
                        ? Colors.greenAccent
                        : isSharing
                        ? Colors.lightBlueAccent
                        : Colors.grey,
                width: 2,
              ),
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
            child: ClipOval(
              child: Icon(Icons.person, size: 24, color: Colors.grey),
            ),
          ),
          Container(
            width: 2,
            height: 20,
            color:
                isUser
                    ? Colors.greenAccent
                    : isSharing
                    ? Colors.lightBlueAccent
                    : Colors.grey,
          ),
        ],
      ),
    );
  }
}
