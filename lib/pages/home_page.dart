import 'dart:async';
import 'dart:ui';

import 'package:armour_app/helpers/url_launch_helper.dart';
import 'package:armour_app/widgets/home_page_sheet.dart';
import 'package:armour_app/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:armour_app/widgets/user_marker.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late List<UserMarker> markers;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
  );

  @override
  void initState() {
    markers = [
      UserMarker(
        context: context,
        coordinates: LatLng(12.9716, 77.5946),
        name: "You",
        userId: "123",
        isUser: true,
      ),
      UserMarker(
        context: context,
        coordinates: LatLng(12.9816, 77.6006),
        name: "Not sharing",
        userId: "456",
      ),
      UserMarker(
        context: context,
        coordinates: LatLng(12.9656, 77.5846),
        name: "Sharing Location",
        userId: "789",
        isOnline: true,
      ),
    ];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 68,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            title: SvgPicture.asset(
              "assets/images/gradient-wordmark.svg",
              height: 24,
            ),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(LucideIcons.settings)),
            ],
          ),
          body: Stack(
            children: [
              MapView(mapController: _mapController, markers: markers),
              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          UrlLaunchHelper.checkAndLaunchUrl("tel:108");
                        },
                        label: Text("Ambulance"),
                        icon: Icon(LucideIcons.heartPulse),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                      ),

                      FilledButton.icon(
                        onPressed: () {
                          UrlLaunchHelper.checkAndLaunchUrl("tel:100");
                        },
                        label: Text("Police"),
                        icon: Icon(LucideIcons.siren),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      ),

                      FilledButton.icon(
                        onPressed: () {
                          UrlLaunchHelper.checkAndLaunchUrl("tel:101");
                        },
                        label: Text("Fire"),
                        icon: Icon(LucideIcons.flame),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        HomePageSheet(mapController: _mapController, markers: markers),
      ],
    );
  }
}
