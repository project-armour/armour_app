import 'dart:async';

import 'package:armour_app/helpers/location_helper.dart';
import 'package:armour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global variable to store user data that can be accessed by the task handler
// @pragma('vm:entry-point')
// Map<String, dynamic> taskData = {};

@pragma('vm:entry-point')
void _taskCallback() {
  // Initialize the foreground task
  FlutterForegroundTask.setTaskHandler(FgTaskHandler());
}

class FgTaskHandler extends TaskHandler {
  // Store Supabase client
  late SupabaseClient? supabase;
  String? _refreshToken;
  bool isLoggedIn = false;
  bool isSharing = false;
  StreamSubscription<Position>? _positionStream;
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late RealtimeChannel? notificationsChannel;

  final NotificationDetails notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      'armour_fg',
      'Foreground Service Channel',
      channelDescription: 'Channel for foreground service notifications',
      priority: Priority.high,
    ),
  );

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    try {
      await Supabase.initialize(
        url: 'https://itmoiuiugcozsppznorl.supabase.co',
        anonKey: 'sb_publishable_H5r64NixD1bYXHoYWbFuzw_sfajBybk',
      );

      supabase = Supabase.instance.client;
    } catch (e) {
      print('Error initializing Supabase in foreground service: $e');
    }

    _positionStream = await LocationHelper.startListening((
      coords,
      speed,
    ) async {
      FlutterForegroundTask.sendDataToMain({
        'location_info': {
          'latitude': coords.latitude,
          'longitude': coords.longitude,
          'speed': speed,
        },
      });

      if (isSharing) {
        await supabase?.from('location_sharing').upsert({
          'sender': supabase?.auth.currentUser!.id,
          'latitude': coords.latitude,
          'longitude': coords.longitude,
          'is_sharing': true,
          'last_updated': DateTime.now().toIso8601String(),
        }, onConflict: 'sender');
      }
    }, () => {print("Error in starting location stream")});

    subscribeToNotifications();
    print("Started Foreground Service");
  }

  @override
  Future<void> onDestroy(DateTime? timestamp, bool? isRepeating) async {
    print("Stopping Service");
    if (_positionStream != null) {
      await _positionStream!.cancel();
    }
    if (notificationsChannel != null) {
      notificationsChannel!.unsubscribe();
    }
    stopSharing();
    FlutterForegroundTask.sendDataToMain({'is_sharing': false});
  }

  @override
  void onReceiveData(Object data) async {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('loginStatus')) {
        isLoggedIn = data['loginStatus'];
        if (!isLoggedIn && supabase != null) {
          supabase?.auth.stopAutoRefresh();
        }
      }
      if (data.containsKey('refreshToken')) {
        _refreshToken = data['refreshToken'];
        if (_refreshToken != null) {
          await supabase?.auth.setSession(_refreshToken!);
          supabase?.auth.startAutoRefresh();
        } else {
          supabase?.auth.stopAutoRefresh();
        }
      }
      if (data.containsKey('is_sharing')) {
        if (data['is_sharing']) {
          startSharing();
        } else {
          stopSharing();
        }
      }
    }
  }

  void startSharing() async {
    isSharing = true;

    if (supabase != null) {
      // get my own name from profiels table
      final myProfile =
          await supabase
              ?.from('profiles')
              .select()
              .eq('id', supabase?.auth.currentUser?.id as String)
              .single();
      final myName = myProfile?['name'] as String? ?? 'User';

      await supabase?.from('notifications').insert({
        'sender': supabase?.auth.currentUser?.id,
        'priority': 'high',
        'type': 'location_sharing_started',
        'message':
            '$myName has started sharing their location, tap to view their location on the map',
      });
      supabase?.auth.stopAutoRefresh();
    }

    FlutterForegroundTask.sendDataToMain({'is_sharing': true});
    FlutterForegroundTask.updateService(
      notificationTitle: 'ARMOUR is sharing your location',
      notificationButtons: [
        const NotificationButton(id: 'btn_stop', text: 'Stop Service'),
        const NotificationButton(id: 'btn_stopshare', text: 'Stop Sharing'),
      ],
    );
  }

  void stopSharing() async {
    isSharing = false;

    if (supabase != null) {
      await supabase?.from('location_sharing').upsert({
        'sender': supabase?.auth.currentUser?.id,
        'is_sharing': false,
      }, onConflict: 'sender');
      supabase?.auth.stopAutoRefresh();
    }
    FlutterForegroundTask.sendDataToMain({'is_sharing': false});
    FlutterForegroundTask.updateService(
      notificationTitle: 'ARMOUR is active in the background',
      notificationButtons: [
        const NotificationButton(id: 'btn_stop', text: 'Stop Service'),
      ],
    );
  }

  void subscribeToNotifications() async {
    void handleNotification(PostgresChangePayload payload) {
      if (payload.newRecord['type'] == 'location_sharing_started') {
        notificationsPlugin.show(
          payload.newRecord['id'],
          'Location Sharing Started',
          payload.newRecord['message'],
          notificationDetails,
        );
      } else if (payload.newRecord['type'] == 'contact_request') {
        if (notificationTitleMap.containsKey(payload.newRecord['type'])) {
          notificationsPlugin.show(
            payload.newRecord['id'],
            notificationTitleMap[payload.newRecord['type']],
            payload.newRecord['message'],
            notificationDetails,
          );
        }
      }
    }

    if (supabase != null) {
      notificationsChannel =
          supabase
              ?.channel('notifications')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'notifications',
                callback: handleNotification,
              )
              .subscribe();
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'btn_stop') {
      FlutterForegroundTask.stopService();
    }
    if (id == 'btn_stopshare') {
      stopSharing();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

class ForegroundServiceHelper {
  static void initForegroundService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'armour_fg',
        channelName: 'Foreground Service Channel',
        channelDescription: 'Channel for foreground service notifications',
        priority:
            NotificationPriority.HIGH, // Changed to HIGH for better reliability
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<ServiceRequestResult> startService([
    bool withConnectedDevice = false,
  ]) async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceTypes: [
          ForegroundServiceTypes.dataSync,
          ForegroundServiceTypes.location,
          if (withConnectedDevice) ForegroundServiceTypes.connectedDevice,
        ],
        notificationTitle: 'ARMOUR is active in the background',
        notificationText: 'Tap here to return to the app',
        notificationIcon: NotificationIcon(
          metaDataName: 'com.project_armour.service.NOTIFICATION_ICON',
        ),
        notificationButtons: [
          const NotificationButton(id: 'btn_stop', text: 'Stop Service'),
        ],
        callback: _taskCallback,
      );
    }
  }

  static Future<bool> requestNotificationPermission(
    BuildContext context,
  ) async {
    var result = await FlutterForegroundTask.checkNotificationPermission();

    while (result != NotificationPermission.granted) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => NotificationPermissionDialog(),
        );
        await FlutterForegroundTask.requestNotificationPermission();
        result = await FlutterForegroundTask.checkNotificationPermission();
        if (result == NotificationPermission.granted) return true;
        if (result == NotificationPermission.permanently_denied) {
          await FlutterForegroundTask.openSystemAlertWindowSettings();
        }
      }
      if (result == NotificationPermission.permanently_denied) {
        return false;
      }
    }

    return true;
  }
}

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(
              LucideIcons.bell200,
              size: 140,
              color: ColorScheme.of(context).primary,
            ),
            SizedBox(height: 12),
            Text(
              "Enable notifications",
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
                  TextSpan(text: " needs notification access to "),
                  TextSpan(
                    text: "run in the background",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " and provide "),
                  TextSpan(
                    text: "emergency alerts",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ". Please allow notifications in the next screen.",
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
                  onPressed: () => SystemNavigator.pop(),
                  child: Text("Close App"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
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
