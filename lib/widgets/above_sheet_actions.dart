import 'dart:math';

import 'package:armour_app/helpers/url_launch_helper.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AboveSheetActions extends StatelessWidget {
  const AboveSheetActions({
    super.key,
    required this.focusFunction,
    required this.resetRotationFunction,
  });

  final VoidCallback focusFunction;
  final VoidCallback resetRotationFunction;

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
            onPressed: resetRotationFunction,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Icon(LucideIcons.compass),
            ),
          ),
          FloatingActionButton.small(
            onPressed: () {
              UrlLaunchHelper.checkAndLaunchUrl('geo:${12.9716},${77.5946}');
            },
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
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Icon(LucideIcons.share2),
          ),
          FloatingActionButton.small(
            onPressed: focusFunction,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            child: Icon(LucideIcons.locate),
          ),
        ],
      ),
    );
  }
}
