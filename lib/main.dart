import 'package:armour_app/pages/home_page.dart';
import 'package:armour_app/pages/location_permission_page.dart';
import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color primaryColor = const Color(0xFF2AB7F1);
  ThemeMode _themeMode = ThemeMode.dark;

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
      home: LocationPermissionPage(),
    );
  }

  void _toggleDark() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }
}
