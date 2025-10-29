import 'package:armour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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
  bool isMonitoring = false;
  double thresholdWpm = 2.0;

  void toggleMonitoring() {
    setState(() {
      isMonitoring = !isMonitoring;
    });
    FlutterForegroundTask.sendDataToTask({"is_tracking_wpm": isMonitoring});
    if (isMonitoring) {
      getThresholdWpm();
    }
  }

  void getThresholdWpm() async {
    final wpmData = await supabase
        .from('preferences')
        .select('wpm')
        .eq('user_id', supabase.auth.currentUser!.id)
        .limit(1);
    if (wpmData.isNotEmpty) {
      setState(() {
        thresholdWpm = wpmData[0]['wpm'];
      });

      FlutterForegroundTask.sendDataToTask({"threshold_wpm": thresholdWpm});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: InkWell(
        onTap: toggleMonitoring,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12 + 4 * widget.controller.value,
            0 + 4 * widget.controller.value,
            12 + 4 * widget.controller.value,
            0 + 4 * widget.controller.value,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : Text("N/A"),
                    ],
                  ),
                  /*Row(
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
                  ),*/
                ],
              ),
              Text(
                isMonitoring ? "Monitoring" : "Tap to Monitor",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16 * widget.controller.value,
                ),
              ),
              Icon(
                size: 24 + 4 * widget.controller.value,
                isMonitoring ? LucideIcons.bell : LucideIcons.bellOff,
                color:
                    isMonitoring
                        ? Colors.amber
                        : ColorScheme.of(
                          context,
                        ).onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
