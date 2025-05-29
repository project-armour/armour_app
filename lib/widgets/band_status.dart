import 'package:armour_app/pages/bt_pair_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BandStatus extends StatelessWidget {
  const BandStatus({super.key, required this.animationValue});

  final double animationValue;
  final int batteryLevel = 72;
  final bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => BtPairPage()));
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 12 + 4 * animationValue,
            right: 12 + 4 * animationValue,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                spacing: 12 * animationValue,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).surfaceBright,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      LucideIcons.watch200,
                      size: 28 + 12 * animationValue,
                    ),
                  ),
                  Text(
                    "My Armour Band",
                    style: TextTheme.of(context).titleMedium!.copyWith(
                      fontSize: 18 * animationValue,
                      color: Colors.white.withValues(alpha: animationValue),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2 + 2 * animationValue,
                children: [
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
