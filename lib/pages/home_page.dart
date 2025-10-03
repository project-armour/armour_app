import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:armour_app/helpers/animated_map.dart';
import 'package:armour_app/helpers/bluetooth.dart';
import 'package:armour_app/helpers/location_helper.dart';
import 'package:armour_app/helpers/url_launch_helper.dart';
import 'package:armour_app/main.dart';
import 'package:armour_app/pages/fake_call.dart';
import 'package:armour_app/pages/panic_page.dart';
import 'package:armour_app/pages/profile_creation.dart';
import 'package:armour_app/widgets/home_page_sheet.dart';
import 'package:armour_app/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  late BluetoothDeviceProvider deviceProvider;
  List<Map<String, dynamic>> markers = [];
  BluetoothDevice? connectedDevice;
  bool isConnected = false;

  bool _isListening = false;
  bool _isTrackingUser = false;

  bool _isSharing = false;
  double speedMps = 0.0;

  String? selfProfilePhotoUrl;

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

    testProfile();

    startListening();

    deviceProvider = Provider.of<BluetoothDeviceProvider>(
      context,
      listen: false,
    );

    updateConnectedDevice();
    refreshMarkers();
    subscribeToLocationSharing();
  }

  void testProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      final profiles = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .limit(1);
      if (profiles.isNotEmpty && markers.isNotEmpty && mounted) {
        setState(() {
          selfProfilePhotoUrl = profiles[0]['profile_photo_url'] ?? '';
          markers[0]['imageUrl'] = selfProfilePhotoUrl;
        });
      }
      if (profiles.isEmpty && mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateProfilePage()),
        );
      }
    }
  }

  void refreshMarkers() async {
    markers = [
      {
        'context': context,
        'userId': supabase.auth.currentUser?.id ?? 'me',
        'coordinates': LatLng(12.9629, 77.5775),
        'name': 'You',
        'isUser': true,
        'isSharing': _isSharing,
      },
    ];

    await supabase.from('location_sharing_with_profiles').select().then((
      shareList,
    ) {
      for (var share in shareList) {
        if (share['sender'] == supabase.auth.currentUser?.id) {
          markers[0]['coordinates'] = LatLng(
            share['latitude'],
            share['longitude'],
          );
          continue;
        }

        setState(() {
          markers += [
            {
              'context': context,
              'userId': share['sender'],
              'coordinates': LatLng(share['latitude'], share['longitude']),
              'name': share['sender_name'] ?? 'User',
              'isUser': share['sender'] == supabase.auth.currentUser?.id,
              'isSharing': share['is_sharing'] ?? false,
              'imageUrl': share['profile_photo_url'] ?? '',
            },
          ];
        });
      }
    });
  }

  void subscribeToLocationSharing() {
    supabase
        .channel('location_sharing')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'location_sharing',
          callback: (payload) async {
            if (payload.newRecord['sender'] != supabase.auth.currentUser?.id) {
              var marker =
                  markers
                      .where(
                        (el) => el['userId'] == payload.newRecord['sender'],
                      )
                      .firstOrNull;
              if (marker != null) {
                if (marker['isSharing'] == false &&
                    payload.newRecord['is_sharing'] == true) {
                  await flutterLocalNotificationsPlugin.show(
                    0,
                    "Location Sharing Started",
                    "A contact started sharing their location.",
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel_id',
                        'General',
                        importance: Importance.max,
                        priority: Priority.high,
                      ),
                    ),
                  );
                } else if (marker['isSharing'] == true &&
                    payload.newRecord['is_sharing'] == false) {
                  // Notify the user
                  flutterLocalNotificationsPlugin.cancel(0);
                }

                setState(() {
                  marker['isSharing'] = payload.newRecord['is_sharing'];
                  marker['coordinates'] = LatLng(
                    payload.newRecord['latitude'],
                    payload.newRecord['longitude'],
                  );
                });
              } else {
                refreshMarkers();
              }
            }
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
            if (markers.isNotEmpty) {
              markers[0]['coordinates'] = coords;
            }
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
              'last_updated': DateTime.now().toIso8601String(),
            }, onConflict: 'sender');
          }
        },
        () => {
          setState(() {
            _isListening = false;
          }),
        },
      );
      if (_positionStream != null && mounted) {
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
    LatLng? userLocation =
        markers.where((el) => el['isUser']).first['coordinates']!;
    if (userLocation != null) {
      AnimateMap.move(this, _mapController, userLocation, destZoom: 16);
    }
    if (!_isListening) {
      startListening();
    } else {
      setState(() {
        _isTrackingUser = true;
      });
    }
  }

  void updateDevice() {
    print("UPDATE DEVICE");
    setState(() {
      connectedDevice = deviceProvider.device;
      if (connectedDevice != null) {
        isConnected = connectedDevice!.isConnected;

        if (isConnected) {
          sendHB(connectedDevice!);
        }
      } else {
        isConnected = false;
      }
    });
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

  void sendHB(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          print("${characteristic.uuid}: ${characteristic.properties}");
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true, forceIndications: true);

            // Listen for notifications
            characteristic.onValueReceived.listen((value) {
              print("Received Notification");
              print("${characteristic.uuid}: ${utf8.decode(value)}");
              if (mounted && utf8.decode(value) == "trg single") {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PanicPage()),
                );
              } else if (mounted && utf8.decode(value) == "trg double") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FakeCallScreen(),
                  ),
                );
              }
            });

            return; // Done
          }
        }
      }

      print("Heart Rate characteristic not found.");
    } catch (e) {
      print("Error in heart rate setup: $e");
    }
  }

  void startSharing() async {
    await supabase.from('location_sharing').upsert({
      'sender': supabase.auth.currentUser!.id,
      'is_sharing': true,
      'latitude': markers[0]['coordinates']!.latitude,
      'longitude': markers[0]['coordinates']!.longitude,
    }, onConflict: 'sender');
    setState(() {
      _isSharing = true;
      markers[0]['isSharing'] = true;
    });
  }

  Future<void> stopSharing() async {
    setState(() {
      _isSharing = false;
      markers[0]['isSharing'] = false;
    });
    await supabase.from('location_sharing').upsert({
      'sender': supabase.auth.currentUser!.id,
      'is_sharing': false,
    }, onConflict: 'sender');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    deviceProvider = Provider.of<BluetoothDeviceProvider>(
      context,
      listen: true,
    );
    deviceProvider.addListener(updateDevice);
  }

  @override
  void dispose() async {
    deviceProvider.removeListener(updateDevice);
    if (_positionStream != null) {
      _positionStream?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      color: ColorScheme.of(
                        context,
                      ).surface.withValues(alpha: 0.5),
                      child: IntrinsicWidth(
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
