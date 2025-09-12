import 'package:armour_app/main.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SupabaseClient? _supabase;
  String? _refreshToken;

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _supabase ??= SupabaseClient(
      'https://itmoiuiugcozsppznorl.supabase.co',
      'sb_publishable_H5r64NixD1bYXHoYWbFuzw_sfajBybk',
    );

    // Get the session token from the task data
    final sessionToken = await FlutterForegroundTask.getData(
      key: 'SessionToken',
    );
    if (sessionToken != null && sessionToken.isNotEmpty) {
      _refreshToken = sessionToken;
      // Set the session on the Supabase client
      await _supabase?.auth.setSession(_refreshToken!);
    }

    print('onStart(starter: ${starter.name})');
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('onDestroy(isTimeout: $isTimeout)');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) async {
    print('onReceiveData: $data');

    // If we receive a session token, update it
    if (data is Map<String, dynamic> && data.containsKey('refreshToken')) {
      print("Got refresh token");
      _refreshToken = data['refreshToken'];
      await _supabase?.auth.setSession(_refreshToken!);
      return;
    }

    if (data is Map<String, dynamic> && data.containsKey('sender')) {
      await _supabase
          ?.from('location_sharing')
          .upsert(data, onConflict: 'sender');
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

class BackgroundService {
  static Future<void> startForegroundTask() async {
    // Check if the foreground service is running
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      // Start the foreground service
      await FlutterForegroundTask.startService(
        notificationTitle: 'ARMOUR is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  static Future<void> stopForegroundTask() async {
    await FlutterForegroundTask.stopService();
  }

  static Future<void> restartForegroundTask() async {
    await stopForegroundTask();
    return await startForegroundTask();
  }

  // Initialize the foreground task
  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'armour_foreground_task',
        channelName: 'ARMOUR Foreground Service',
        channelDescription:
            'This notification appears when ARMOUR is running in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }
}
