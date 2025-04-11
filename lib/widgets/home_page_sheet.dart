import 'dart:ui';

import 'package:armour_app/widgets/above_sheet_actions.dart';
import 'package:armour_app/widgets/checkin_button.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/animated_map.dart';

class HomePageSheet extends StatefulWidget {
  const HomePageSheet({super.key, this.mapController, this.markers = const []});

  final MapController? mapController;
  final List<Marker> markers;

  @override
  State<HomePageSheet> createState() => _HomePageSheetState();
}

class _HomePageSheetState extends State<HomePageSheet>
    with TickerProviderStateMixin {
  final sheetHeights = [450.0, 240.0];
  late final SheetController controller;

  @override
  void initState() {
    controller = SheetController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _resetMapRotation() {
    if (widget.mapController!= null) {
      AnimateMap.rotate(this, widget.mapController!, 0);
    }
  }

  void _focusOnUserLocation() {
    // Example coordinates - you would replace this with actual user location
    // For example, from a location service or GPS
    final LatLng userLocation = widget.markers.first.point;

    if (widget.mapController != null) {
      AnimateMap.move(this, widget.mapController!, userLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final sheetBorder = BorderSide(
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.75),
    );
    return SheetViewport(
      child: Sheet(
        initialOffset: RelativeSheetOffset(sheetHeights.last / size.height),
        controller: controller,
        snapGrid: SheetSnapGrid(
          snaps:
              sheetHeights.map((value) => SheetOffset.absolute(value)).toList(),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AboveSheetActions(focusFunction: _focusOnUserLocation, resetRotationFunction: _resetMapRotation),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: sheetHeights.first + 150,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow
                            .withValues(alpha: 0.75),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(top: sheetBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(top: 36),
              child: CheckInButton(onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
