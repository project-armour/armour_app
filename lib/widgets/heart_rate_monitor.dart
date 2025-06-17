import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HeartRateMonitor extends StatefulWidget {
  const HeartRateMonitor({
    super.key,
    required this.controller,
    required this.walkingPace,
  });

  final AnimationController controller;
  final double? walkingPace;

  @override
  State<HeartRateMonitor> createState() => _HeartRateMonitorState();
}

class _HeartRateMonitorState extends State<HeartRateMonitor> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12 + 4 * widget.controller.value,
          0 + 4 * widget.controller.value,
          12 + 4 * widget.controller.value,
          0 + 4 * widget.controller.value,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            Row(
              spacing: 2 + 4 * widget.controller.value,
              children: [
                Icon(
                  LucideIcons.footprints300,
                  size: 18 + 4 * widget.controller.value,
                ),
                Text(
                  "Walking Pace:",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16 * widget.controller.value,
                  ),
                ),
                widget.walkingPace != null
                    ? Text(
                      "${widget.walkingPace!.toStringAsFixed(2)} m/s",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                    : Text("N/A"),
              ],
            ),
            Row(
              spacing: 2 + 4 * widget.controller.value,
              children: [
                Icon(
                  LucideIcons.heartPulse300,
                  size: 18 + 4 * widget.controller.value,
                ),
                Text(
                  "Heart Rate:",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16 * widget.controller.value,
                  ),
                ),
                Text("N/A"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
