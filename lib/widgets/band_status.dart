import 'package:armour_app/helpers/bluetooth.dart';
import 'package:armour_app/pages/bt_pair_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class BandStatus extends StatefulWidget {
  BandStatus({super.key, required this.animationValue});

  final double animationValue;

  @override
  State<BandStatus> createState() => _BandStatusState();
}

class _BandStatusState extends State<BandStatus> {
  final int batteryLevel = 72;
  BluetoothDevice? connectedDevice;
  bool isConnected = false;
  late BluetoothDeviceProvider deviceProvider;

  void updateDevice() {
    print("UPDATE DEVICE");
    setState(() {
      connectedDevice = deviceProvider.device;
      if (connectedDevice != null) {
        isConnected = connectedDevice!.isConnected;
      } else {
        isConnected = false;
      }
    });
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
  void dispose() {
    deviceProvider.removeListener(updateDevice);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => BtPairPage()));
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
                  Row(
                    spacing: 6,
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          isConnected
                              ? "Connected to ${connectedDevice?.advName}"
                              : "Not connected",
                          style:
                              isConnected
                                  ? TextTheme.of(context).bodySmall
                                  : TextTheme.of(
                                    context,
                                  ).bodySmall!.copyWith(color: Colors.red[300]),

                          softWrap: true,
                        ),
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
