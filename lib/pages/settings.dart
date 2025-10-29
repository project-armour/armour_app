import 'package:armour_app/main.dart';
import 'package:armour_app/pages/profile_creation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Profile"),
            subtitle: Text("Edit your name, username and profile photo"),
            leading: Icon(LucideIcons.user),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProfilePage(edit: true),
                ),
              );
            },
          ),
          ListTile(
            title: Text("Walking Pace Monitoring"),
            subtitle: Text("Adjust the threshold speed to cause an alert"),
            leading: Icon(LucideIcons.footprints),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const WPEdit(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WPEdit extends StatefulWidget {
  const WPEdit({super.key});

  @override
  State<WPEdit> createState() => _WPEditState();
}

class _WPEditState extends State<WPEdit> {
  double? currentWpm;
  double newWpm = 2.0;

  void getWpm() async {
    final wpmData = await supabase
        .from('preferences')
        .select('wpm')
        .eq('user_id', supabase.auth.currentUser!.id)
        .limit(1);

    if (wpmData.isNotEmpty) {
      setState(() {
        currentWpm = wpmData[0]['wpm']?.toDouble() ?? 0.0;
        newWpm = currentWpm!;
      });
    }
  }

  void setThresholdWpm() async {
    await supabase
        .from('preferences')
        .upsert({'user_id': supabase.auth.currentUser!.id, 'wpm': newWpm})
        .eq('user_id', supabase.auth.currentUser!.id);

    FlutterForegroundTask.sendDataToTask({"threshold_wpm": newWpm});

    print("Updated WPM: $newWpm");
  }

  @override
  void initState() {
    getWpm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              "Walking Pace Monitoring",
              style: TextTheme.of(context).titleMedium,
            ),
            Text(
              "Adjust the threshold speed to cause an alert",
              style: TextTheme.of(context).bodySmall,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12,
              children: [
                Flexible(
                  child: Slider(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    value: newWpm,
                    min: 0.0,
                    max: 10.0,
                    divisions: 100,
                    label: "${newWpm.toStringAsFixed(1)} m/s",
                    onChanged: (value) {
                      setState(() {
                        newWpm = value;
                      });
                    },
                  ),
                ),
                Text("${newWpm.toStringAsFixed(1)} m/s"),
              ],
            ),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    setThresholdWpm();
                    setState(() {
                      currentWpm = newWpm;
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
