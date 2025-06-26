import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:armour_app/helpers/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class BtPairPage extends StatefulWidget {
  const BtPairPage({super.key});

  @override
  State<BtPairPage> createState() => _BtPairPageState();
}

class _BtPairPageState extends State<BtPairPage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();

    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _adapterState = state;
        });
      } else {
        _adapterState = state;
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  Future<void> checkBluetoothStatus() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect your Armour Band"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          _adapterState == BluetoothAdapterState.on
              ? DeviceSelection()
              : BluetoothDisconnected(),
    );
  }
}

class BluetoothDisconnected extends StatelessWidget {
  const BluetoothDisconnected({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(
            LucideIcons.bluetooth200,
            size: 140,
            color: ColorScheme.of(context).primary,
          ),
          SizedBox(height: 12),
          Text(
            "Access nearby devices",
            style: TextTheme.of(context).headlineMedium,
            textAlign: TextAlign.center,
          ),
          Text.rich(
            TextSpan(
              style: TextTheme.of(context).bodyLarge,
              children: <InlineSpan>[
                WidgetSpan(
                  child: SizedBox(
                    height: 22,
                    child: SvgPicture.asset(
                      "assets/images/gradient-wordmark.svg",
                      height: 14,
                    ),
                  ),
                ),
                TextSpan(text: " needs to enable  "),
                TextSpan(
                  text: "Bluetooth",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      " to search and connect to your Armour Band. Tap Continue to enable it.",
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          Text.rich(
            TextSpan(
              style: TextTheme.of(context).bodyLarge,
              children: <InlineSpan>[
                TextSpan(
                  text: "If the permission is not enabled, navigate to ",
                ),
                TextSpan(
                  text: "Permissions > Nearby Devices",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: " in the next screen and select "),
                TextSpan(
                  text: "Allow",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 12,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              FilledButton(
                onPressed: () async {
                  if (Platform.isAndroid && await FlutterBluePlus.isSupported) {
                    try {
                      await FlutterBluePlus.turnOn();
                    } on PlatformException catch (_) {
                      Geolocator.openAppSettings();
                    } on FlutterBluePlusException catch (_) {}
                  }
                },
                child: Text("Continue"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeviceSelection extends StatefulWidget {
  const DeviceSelection({super.key});

  @override
  State<DeviceSelection> createState() => _DeviceSelectionState();
}

class _DeviceSelectionState extends State<DeviceSelection> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  late StreamSubscription<List<ScanResult>> subscription;
  late StreamSubscription? scanListener;

  Future<void> startScan() async {
    final completer = Completer<void>();

    // Listen for scan results
    subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        setState(() {
          scanResults = results;
        });
      }
    }, onError: (e) => print('Scan results error: $e'));

    try {
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 10),
        withServices: [Guid.fromString("0cc04a2c-b3c2-4431-a6f1-b9180ebce500")],
      );
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      print('Error starting scan: $e');
      completer.complete(); // Complete even on error
    }

    scanListener = FlutterBluePlus.isScanning.listen((scanning) {
      setState(() {
        isScanning = scanning;
      });
      if (!scanning) {
        completer.complete();
        scanListener?.cancel();
      }
    });

    FlutterBluePlus.cancelWhenScanComplete(subscription);
    return completer.future;
  }

  @override
  void initState() {
    print("Initstate");
    super.initState();
    startScan();
  }

  @override
  void dispose() {
    subscription.cancel();
    scanListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<BluetoothDeviceProvider>(
      context,
      listen: false,
    );
    final device = deviceProvider.device;

    return RefreshIndicator(
      displacement: 20,
      backgroundColor: ColorScheme.of(context).surfaceContainerLow,
      onRefresh: () {
        return startScan();
      },
      child: Stack(
        children: [
          if (scanResults.isEmpty)
            Center(
              child: Text(
                isScanning
                    ? 'Searching for devices...'
                    : 'No devices found. Swipe down to retry.',
                textAlign: TextAlign.center,
              ),
            ),
          ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  scanResults[index].device.platformName.isNotEmpty
                      ? scanResults[index].device.platformName
                      : 'Unknown Device',
                ),
                subtitle: Text(scanResults[index].device.remoteId.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${scanResults[index].rssi} dBm'),
                    SizedBox(width: 8),
                    Icon(LucideIcons.bluetooth200),
                  ],
                ),
                onTap: () async {
                  // Show connecting indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Connecting to ${scanResults[index].device.platformName}...',
                      ),
                    ),
                  );
                  try {
                    BluetoothDevice device = scanResults[index].device;

                    await device.connect(autoConnect: false);

                    if (device.isConnected) {
                      print("Isconnected True");
                      deviceProvider.setDevice(device);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    print(e);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Connection Failed'),
                      ),
                    );
                  }
                  // Add your connection logic here
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
/*
class BluetoothPermissionDialog extends StatelessWidget {
  const BluetoothPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(
              LucideIcons.bluetooth200,
              size: 140,
              color: ColorScheme.of(context).primary,
            ),
            SizedBox(height: 12),
            Text(
              "Access nearby devices",
              style: TextTheme.of(context).headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text.rich(
              TextSpan(
                style: TextTheme.of(context).bodyLarge,
                children: <InlineSpan>[
                  WidgetSpan(
                    child: SizedBox(
                      height: 22,
                      child: SvgPicture.asset(
                        "assets/images/gradient-wordmark.svg",
                        height: 14,
                      ),
                    ),
                  ),
                  TextSpan(text: " needs to enable  "),
                  TextSpan(
                    text: "Bluetooth",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " to search and connect to your Armour Band. Tap ",
                  ),
                  TextSpan(
                    text: "Allow",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " in the next screen."),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text("Close App"),
                ),
                FilledButton(
                  onPressed: () async {
                    if (Platform.isAndroid &&
                        await FlutterBluePlus.isSupported) {
                      await FlutterBluePlus.turnOn();
                    }
                  },
                  child: Text("Continue"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/