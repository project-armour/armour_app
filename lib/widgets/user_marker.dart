import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserMarker {
  static Marker marker(
    BuildContext context,
    LatLng coordinates,
    String name, {
    bool isUser = false,
    String? imageUrl = 'assets/images/default_profile.png',
  }) {
    return Marker(
      width: 40,
      height: 80,
      point: coordinates,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(name),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isUser ? Colors.greenAccent : Colors.lightBlueAccent,
                width: 2,
              ),
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/default_profile.png', // Replace with actual profile image path
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 24, color: Colors.grey);
                },
              ),
            ),
          ),
          Container(
            width: 2,
            height: 20,
            color: isUser ? Colors.greenAccent : Colors.lightBlueAccent,
          ),
        ],
      ),
    );
  }
}
