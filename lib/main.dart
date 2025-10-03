import 'package:armour_app/helpers/bluetooth.dart';
import 'package:armour_app/pages/home_page.dart';
import 'package:armour_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check network connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (!connectivityResult.contains(ConnectivityResult.wifi) &&
      !connectivityResult.contains(ConnectivityResult.mobile)) {
    // No network, show error or exit
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'No internet connection. Please connect to WiFi or mobile data.',
            ),
          ),
        ),
      ),
    );
    return;
  }

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

  await Supabase.initialize(
    url: 'https://itmoiuiugcozsppznorl.supabase.co',
    anonKey: 'sb_publishable_H5r64NixD1bYXHoYWbFuzw_sfajBybk',
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Allow portrait mode (upright)
    DeviceOrientation.portraitDown, // Allow portrait mode (upside-down)
  ]);

  // Initialize local notifications
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/notification_icon');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(
    ChangeNotifierProvider(
      create: (_) => BluetoothDeviceProvider(),
      child: MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color primaryColor = const Color(0xFF2AB7F1);
  final ThemeMode _themeMode = ThemeMode.dark;
  bool loginState = false;

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.initialSession) {
        setState(() {
          loginState = data.session != null;
        });
        if (data.session != null) {
          supabase.auth.startAutoRefresh();
        }
      } else if (event == AuthChangeEvent.signedIn) {
        setState(() {
          loginState = true;
        });
        supabase.auth.startAutoRefresh();
      } else {
        if (data.session == null) {
          setState(() {
            loginState = false;
          });
          supabase.auth.stopAutoRefresh();
        } else {
          setState(() {
            loginState = true;
          });
          supabase.auth.startAutoRefresh();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    /*final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: primaryColor,
      variant: FlexSchemeVariant.chroma,
    );*/
    final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
      brightness: Brightness.dark,
      primaryKey: primaryColor,
      variant: FlexSchemeVariant.chroma,
    );

    return MaterialApp(
      title: 'ARMOUR',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: schemeDark, // Dark theme default
      ),
      /*darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: schemeDark,
      ),*/
      themeMode: _themeMode,
      home: loginState ? HomePage() : LoginPage(),
    );
  }
}
