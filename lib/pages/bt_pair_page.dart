import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
      appBar: AppBar(title: Text("Connect your Armour Band")),
      body:
          _adapterState == BluetoothAdapterState.off ||
                  _adapterState == BluetoothAdapterState.unknown
              ? BluetoothDisconnected()
              : Placeholder(),
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