import 'dart:async';

import 'package:armour_app/helpers/location_helper.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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

    print("Started Foreground Service");
  }

  @override
  Future<void> onDestroy(DateTime? timestamp, bool? isRepeating) async {
    if (supabase != null) {
      supabase!.auth.stopAutoRefresh();
    }
  }

  @override
  void onReceiveData(Object data) async {
    print('onReceiveData(data: $data)');
    if (data is Map<String, dynamic>) {
      if (data.containsKey('loginStatus')) {
        isLoggedIn = data['loginStatus'];
        if (!isLoggedIn) {
          supabase!.auth.stopAutoRefresh();
        }
      }
      if (data.containsKey('refreshToken')) {
        _refreshToken = data['refreshToken'];
        if (_refreshToken != null) {
          await supabase!.auth.setSession(_refreshToken!);
          supabase!.auth.startAutoRefresh();
        } else {
          supabase!.auth.stopAutoRefresh();
        }
      }
      if (data.containsKey('is_sharing')) {
        isSharing = data['is_sharing'];
      }
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  void onNotificationPressed() {
    // Notification was pressed - you can navigate to a specific page if needed
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
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<ServiceRequestResult> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceTypes: [
          ForegroundServiceTypes.dataSync,
          ForegroundServiceTypes.location,
        ],
        notificationTitle: 'ARMOUR is active in the background',
        notificationText: 'Tap here to return to the app',
        notificationIcon: NotificationIcon(
          metaDataName: 'com.project_armour.service.NOTIFICATION_ICON',
        ),
        callback: _taskCallback,
      );
    }
  }

  static Future<ServiceRequestResult> stopService() {
    return FlutterForegroundTask.stopService();
  }
}
