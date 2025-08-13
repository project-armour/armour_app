import 'dart:ui';

import 'package:armour_app/helpers/url_launch_helper.dart';
import 'package:armour_app/pages/panic_page.dart';
import 'package:armour_app/widgets/above_sheet_actions.dart';
import 'package:armour_app/widgets/band_status.dart';
import 'package:armour_app/widgets/checkin_button.dart';
import 'package:armour_app/widgets/heart_rate_monitor.dart';
import 'package:armour_app/widgets/sheet_main_button.dart';
import 'package:armour_app/widgets/user_marker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:armour_app/helpers/animated_map.dart';

class HomePageSheet extends StatefulWidget {
  const HomePageSheet({
    super.key,
    this.mapController,
    this.markers = const [],
    this.isTracking = false,
    this.walkingPace,
    required this.trackUser,
    required this.shareLocation,
  });

  final MapController? mapController;
  final List<UserMarker> markers;
  final bool isTracking;
  final VoidCallback trackUser;
  final VoidCallback shareLocation;
  final double? walkingPace;

  @override
  State<HomePageSheet> createState() => _HomePageSheetState();
}

class _HomePageSheetState extends State<HomePageSheet>
    with TickerProviderStateMixin {
  final sheetHeights = [450.0, 200.0];
  late final SheetController sheetController;
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    sheetController = SheetController();

    // Create an AnimationController with the same range as sheet movement
    animationController = AnimationController(
      vsync: this,
      duration: Duration.zero,
      value: 0,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // Add listener to update the AnimationController when sheet position changes
    sheetController.addListener(_updateAnimationFromSheet);
  }

  void _updateAnimationFromSheet() {
    if (sheetController.value != null) {
      // Calculate normalized progress between min and max sheet heights
      final progress =
          (sheetController.value! - sheetHeights[1]) /
          (sheetHeights[0] - sheetHeights[1]);

      // Update animation controller with clamped value
      animationController.value = progress.clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    sheetController.removeListener(_updateAnimationFromSheet);
    sheetController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _resetMapRotation() {
    if (widget.mapController != null) {
      AnimateMap.rotate(this, widget.mapController!, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheetBorder = BorderSide(
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.75),
    );

    return SheetViewport(
      child: Sheet(
        initialOffset: SheetOffset(0.3125),
        controller: sheetController,
        snapGrid: SheetSnapGrid(
          snaps:
              sheetHeights.map((value) => SheetOffset.absolute(value)).toList(),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AboveSheetActions(
                  focusFunction: widget.trackUser,
                  resetRotationFunction: _resetMapRotation,
                  isTracking: widget.isTracking,
                  googleMapsFunction: () {
                    final userLocation =
                        widget.markers
                            .where((el) => el.isUser)
                            .first
                            .coordinates;
                    UrlLaunchHelper.checkAndLaunchUrl(
                      'geo:${userLocation.latitude},${userLocation.longitude}',
                    );
                  },
                  shareFunction: () {
                    widget.shareLocation();
                  },
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: sheetHeights.first + 130,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 220),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SheetMainButton(
                                text: "Fake Call",
                                icon: LucideIcons.phoneCall,
                                onPressed: () {},
                              ),
                              SheetMainButton(
                                text: "Panic",
                                icon: LucideIcons.messageCircle,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PanicPage(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 72),
                              SheetMainButton(
                                text: "SOS",
                                icon: LucideIcons.circleAlert,
                                onPressed: () {},
                              ),
                              SheetMainButton(
                                text: "Settings",
                                icon: LucideIcons.settings,
                                onPressed: () {},
                              ),
                            ],
                          ),

                          // Add content that transitions based on sheet position
                          SheetAnimation(
                            controller: animationController,
                            sheetHeights: sheetHeights,
                            walkingPace: widget.walkingPace,
                          ),
                        ],
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

class SheetAnimation extends StatelessWidget {
  const SheetAnimation({
    super.key,
    required this.controller,
    required this.sheetHeights,
    this.walkingPace,
  });

  final AnimationController controller;
  final List<double> sheetHeights;
  final double? walkingPace;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final deviceSize = MediaQuery.of(context).size;
        return Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 16,
                  width: 180 + (deviceSize.width - 212) * controller.value,
                  height: 60 + 20 * controller.value,
                  child: BandStatus(animationValue: controller.value),
                ),
                Positioned(
                  top: 4 + 96 * controller.value,
                  right: 16,
                  width: 180 + (deviceSize.width - 212) * controller.value,
                  height: 60 + 20 * controller.value,
                  child: HeartRateMonitor(
                    controller: controller,
                    walkingPace: walkingPace,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Add this new widget for contact items
class _ContactItem extends StatelessWidget {
  final String name;
  final bool isSharing;

  const _ContactItem({required this.name, this.isSharing = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            color: isSharing ? Colors.greenAccent : Colors.grey,
          ),
          SizedBox(height: 8),
          Text(name),
          Text(
            isSharing ? "Sharing location" : "Not sharing location",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSharing ? Colors.greenAccent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
