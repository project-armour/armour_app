import 'package:armour_app/widgets/user_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key, this.mapController, this.markers = const []});

  final MapController? mapController;
  final List<Map<String, dynamic>> markers;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  @override
  Widget build(BuildContext context) {
    const String mapApiKey = String.fromEnvironment("STADIA_MAPS_KEY");
    if (mapApiKey.isEmpty) {
      return const Center(child: Text("No map API key found"));
    } else {
      return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(12.9716, 77.5946),
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(LatLng(-90, -180.0), LatLng(90.0, 180.0)),
          ),
        ),

        children: [
          TileLayer(
            urlTemplate:
                'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}@2x.png?api_key=$mapApiKey',
            userAgentPackageName: 'com.example.app',
            tileProvider: NetworkTileProvider(
              cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
                maxCacheSize: 100_000_000,
              ),
            ),
            minZoom: 1,
          ),

          MarkerLayer(
            markers:
                widget.markers
                    .map(
                      (marker) => getMarker(
                        marker['context'],
                        marker['userId'],
                        marker['isUser'],
                        marker['isSharing'],
                        marker['coordinates'],
                        marker['name'],
                        marker['imageUrl'],
                      ),
                    )
                    .toList(),
            rotate: true,
            alignment: Alignment.topCenter,
          ),
        ],
      );
    }
  }
}

/*
    return GridView.count(
      crossAxisCount: 2, // Two columns
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: List.generate(12, (index) {
        // Generate different colors based on index
        final colors = [
          Colors.blue[300],
          Colors.red[300],
          Colors.green[300],
          Colors.purple[300],
          Colors.orange[300],
          Colors.teal[300],
          Colors.pink[300],
          Colors.amber[300],
          Colors.cyan[300],
          Colors.lime[300],
          Colors.indigo[300],
          Colors.brown[300],
        ];
        return Container(
          decoration: BoxDecoration(
            color: colors[index],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
*/
