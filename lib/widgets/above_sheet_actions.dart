import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AboveSheetActions extends StatelessWidget {
  const AboveSheetActions({
    super.key,
    required this.focusFunction,
    required this.resetRotationFunction,
    required this.googleMapsFunction,
    required this.isTracking,
  });

  final VoidCallback focusFunction;
  final VoidCallback resetRotationFunction;
  final VoidCallback googleMapsFunction;
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Flex(
        direction: Axis.horizontal,
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "resetRotation",  // Add unique hero tag
            onPressed: resetRotationFunction,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Icon(LucideIcons.compass),
            ),
          ),
          FloatingActionButton.small(
            heroTag: "googleMaps",  // Add unique hero tag
            onPressed: googleMapsFunction,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Center(
              child: Image.asset(
                "assets/images/maps-pin-fullcolor.png",
                width: 28,
              ),
            ),
          ),
          Flexible(fit: FlexFit.tight, child: SizedBox()),
          FloatingActionButton.small(
            heroTag: "share",  // Add unique hero tag
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Icon(LucideIcons.share2),
          ),
          FloatingActionButton.small(
            heroTag: "locate",  // Add unique hero tag
            onPressed: focusFunction,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Icon(
              isTracking ? LucideIcons.locateFixed : LucideIcons.locate,
            ),
          ),
        ],
      ),
    );
  }
}
