import 'package:armour_app/main.dart';
import 'package:armour_app/pages/profile_creation.dart';
import 'package:flutter/material.dart';
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

  void getWpm() async {
    final wpmData = (await supabase
        .from('preferences')
        .select('wpm')
        .eq('user_id', supabase.auth.currentUser!.id)
        .limit(1));
  }

  @override
  void initState() {
    super.initState();
    getWpm();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(20.0),
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
            if (currentWpm != null)
              Text(
                "Current Walking Pace: ${currentWpm!.toStringAsFixed(2)} WPM",
                style: TextTheme.of(context).bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
