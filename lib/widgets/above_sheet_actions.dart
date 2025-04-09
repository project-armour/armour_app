import 'package:armour_app/helpers/url_launch_helper.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AboveSheetActions extends StatelessWidget {
  const AboveSheetActions({super.key, required this.focusFunction});

  final VoidCallback focusFunction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16, bottom: 12),
      child: Row(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () {
              UrlLaunchHelper.checkAndLaunchUrl('geo:${12.9716},${77.5946}');
            },
            backgroundColor: Colors.white,
            child: Center(
              child: Image.asset(
                "assets/images/maps-pin-fullcolor.png",
                width: 28,
              ),
            ),
          ),
          FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(LucideIcons.share2),
          ),
          FloatingActionButton.small(
            onPressed: focusFunction,
            child: Icon(LucideIcons.locate),
          ),
        ],
      ),
    );
  }
}
