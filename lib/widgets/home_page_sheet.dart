import 'package:armour_app/widgets/above_sheet_actions.dart';
import 'package:armour_app/widgets/checkin_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:armour_app/helpers/url_launch_helper.dart';

class HomePageSheet extends StatefulWidget {
  const HomePageSheet({super.key, this.mapController});

  final MapController? mapController;

  @override
  State<HomePageSheet> createState() => _HomePageSheetState();
}

class _HomePageSheetState extends State<HomePageSheet> {
  final sheetHeights = [480.0, 240.0];
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

  void _focusOnUserLocation() {
    // Example coordinates - you would replace this with actual user location
    // For example, from a location service or GPS
    final LatLng userLocation = LatLng(12.9716, 77.5946);

    if (widget.mapController != null) {
      widget.mapController!.move(userLocation, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetViewport(
      child: Sheet(
        initialOffset: SheetOffset.absolute(480),
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
                AboveSheetActions(focusFunction: _focusOnUserLocation),
                Container(
                  height: sheetHeights.first + 200,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                      
                    ],
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
