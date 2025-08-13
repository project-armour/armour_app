import 'dart:async';
import 'dart:ui';

import 'package:armour_app/helpers/animated_map.dart';
import 'package:armour_app/helpers/bluetooth.dart';
import 'package:armour_app/helpers/location_helper.dart';
import 'package:armour_app/helpers/url_launch_helper.dart';
import 'package:armour_app/main.dart';
import 'package:armour_app/widgets/home_page_sheet.dart';
import 'package:armour_app/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:armour_app/widgets/user_marker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late List<UserMarker> markers;
  late StreamSubscription<Position>? _positionStream;
  late BluetoothDeviceProvider deviceProvider;

  bool _isListening = false;
  bool _isTrackingUser = false;

  bool _isSharing = false;
  LatLng currentLocation = LatLng(12.9716, 77.5946);
  double speedMps = 0.0;

  @override
  void initState() {
    super.initState();
    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove &&
          event.source != MapEventSource.mapController) {
        setState(() {
          _isTrackingUser = false;
        });
      }
    });

    startListening();

    deviceProvider = Provider.of<BluetoothDeviceProvider>(
      context,
      listen: false,
    );

    updateConnectedDevice();
  }

  // TODO: Make this proper
  void subscribeToLocationSharing() {
    supabase
        .channel('location_sharing')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'location_sharing',
          callback: (payload) {
            print('Change received: ${payload.toString()}');
          },
        )
        .subscribe();
  }

  void startListening() async {
    bool locationPermission = await LocationHelper.checkPermissions(context);

    if (locationPermission) {
      _positionStream = await LocationHelper.startListening(
        (coords, speed) async {
          setState(() {
            speedMps = speed;
            currentLocation = coords;
          });
          if (_isTrackingUser) {
            AnimateMap.move(this, _mapController, coords, destZoom: 16);
          }
          if (_isSharing) {
            await supabase.from('location_sharing').upsert({
              'sender': supabase.auth.currentUser!.id,
              'latitude': coords.latitude,
              'longitude': coords.longitude,
              'is_sharing': true,
            }, onConflict: 'sender');
          }
        },
        () => {
          setState(() {
            _isListening = false;
          }),
        },
      );
      if (_positionStream != null) {
        setState(() {
          _isListening = true;
          _isTrackingUser = true;
        });
      } else {
        if (mounted) {
          // TODO: Start listening again after the user enables location services
          LocationHelper.requestLocationService(context);
        }
        setState(() {
          _isListening = false;
          _isTrackingUser = false;
        });
      }
    } else {
      setState(() {
        _isListening = false;
        _isTrackingUser = false;
      });
    }
  }

  void trackUser() {
    LatLng userLocation = markers.where((el) => el.isUser).first.coordinates;
    AnimateMap.move(this, _mapController, userLocation, destZoom: 16);
    if (!_isListening) {
      startListening();
    } else {
      setState(() {
        _isTrackingUser = true;
      });
    }
  }

  Future<void> updateConnectedDevice() async {
    List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;

    for (var device in connectedDevices) {
      // Check if the device name matches
      if (device.advName == "Brick(tm)") {
        deviceProvider.setDevice(device);
      }
    }
  }

  void startSharing() async {
    await supabase.from('location_sharing').upsert({
      'sender': supabase.auth.currentUser!.id,
      'is_sharing': true,
    }, onConflict: 'sender');
    setState(() {
      _isSharing = true;
    });
  }

  Future<void> stopSharing() async {
    setState(() {
      _isSharing = false;
    });
    await supabase.from('location_sharing').upsert({
      'sender': supabase.auth.currentUser!.id,
      'is_sharing': false,
    }, onConflict: 'sender');
  }

  @override
  void dispose() async {
    await stopSharing();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    markers = [
      UserMarker(
        context: context,
        coordinates: currentLocation,
        name: "You",
        userId: "123",
        isUser: true,
        isSharing: _isSharing,
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
        isSharing: true,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
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
        actions: [
          IconButton(
            onPressed: () {
              supabase.auth.signOut();
            },
            icon: Icon(LucideIcons.logOut),
          ),
        ],
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

          if (_isSharing)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      width: 180,
                      color: ColorScheme.of(
                        context,
                      ).surface.withValues(alpha: 0.5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 6,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Icon(LucideIcons.mapPin300, size: 20),
                              Text(
                                "Sharing location",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          FilledButton(
                            onPressed: () {
                              stopSharing();
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text("Tap to stop"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: HomePageSheet(
              shareLocation: startSharing,
              mapController: _mapController,
              markers: markers,
              isTracking: _isTrackingUser,
              trackUser: trackUser,
              walkingPace: speedMps,
            ),
          ),
        ],
      ),
    );
  }
}
