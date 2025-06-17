import 'dart:async';

import 'package:armour_app/pages/bt_pair_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BandStatus extends StatefulWidget {
  BandStatus({super.key, required this.animationValue});

  final double animationValue;

  @override
  State<BandStatus> createState() => _BandStatusState();
}

class _BandStatusState extends State<BandStatus> {
  final int batteryLevel = 72;

  bool isConnected = false;

  BluetoothDevice? device;
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;

  @override
  void dispose() {
    connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          device = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => BtPairPage()));
          if (device != null) {
            connectionSubscription = device?.connectionState.listen((state) {
              if (state == BluetoothConnectionState.connected) {
                setState(() {
                  isConnected = true;
                });
              } else {
                setState(() {
                  isConnected = false;
                });
              }
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 12 + 4 * widget.animationValue,
            right: 12 + 4 * widget.animationValue,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                spacing: 12 * widget.animationValue,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).surfaceBright,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      LucideIcons.watch200,
                      size: 28 + 12 * widget.animationValue,
                    ),
                  ),
                  Text(
                    "My Armour Band",
                    style: TextTheme.of(context).titleMedium!.copyWith(
                      fontSize: 18 * widget.animationValue,
                      color: Colors.white.withValues(
                        alpha: widget.animationValue,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2 + 2 * widget.animationValue,
                children: [
                  if (isConnected)
                    Row(
                      spacing: 4,
                      children: [
                        Text("72%", style: TextTheme.of(context).bodyMedium),
                        RotatedBox(
                          quarterTurns: -1,
                          child: Icon(LucideIcons.batteryMedium300, size: 18),
                        ),
                      ],
                    ),
                  Row(
                    spacing: 6,
                    children: [
                      Text(
                        isConnected ? "Connected" : "Not connected",
                        style:
                            isConnected
                                ? TextTheme.of(context).bodySmall
                                : TextTheme.of(
                                  context,
                                ).bodySmall!.copyWith(color: Colors.red[300]),
                      ),
                      Icon(
                        isConnected
                            ? LucideIcons.bluetoothConnected300
                            : LucideIcons.bluetoothOff300,
                        size: 18,
                        color: isConnected ? Colors.blue : Colors.red[300],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
