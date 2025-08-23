import 'package:armour_app/widgets/marker_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Marker getMarker(
  BuildContext context,
  String userId,
  bool isUser,
  bool isSharing,
  LatLng coordinates,
  String name,
  String? imageUrl,
) {
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
          child: CircleAvatar(
            radius: 18,
            backgroundImage:
                imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
            backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            child:
                imageUrl == null || imageUrl.isEmpty
                    ? Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
          ),
        ),
        Expanded(
          child: Container(
            width: 2,

            color:
                isUser
                    ? Colors.greenAccent
                    : isSharing
                    ? Colors.lightBlueAccent
                    : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
