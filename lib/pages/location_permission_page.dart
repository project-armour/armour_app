import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:armour_app/pages/home_page.dart';
import 'package:armour_app/helpers/location_helper.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _isLoading = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  Future<void> _checkLocationServices() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Checking location services...";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage =
            "Location services are disabled. Please enable them to continue.";
        _isLoading = false;
      });
      return;
    }

    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _statusMessage = "Checking location permissions...";
    });

    // Use LocationHelper's checkPermissions method with a custom context handler
    if (mounted) {
      // Create a BuildContext wrapper that will handle dialogs differently
      bool permissionGranted = await LocationHelper.checkPermissions(context);

      if (permissionGranted) {
        _navigateToHomePage();
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage =
              "Please grant 'Allow all the time' permission to continue.";
        });
      }
    }
  }

  void _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              Text(
                "Location Access Required",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "This app requires background access to your location at all times to provide safety features and location sharing.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: _checkPermissions,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Grant Permission"),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _openAppSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text("Open App Settings"),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _openLocationSettings,
                      icon: const Icon(Icons.location_on),
                      label: const Text("Open Location Settings"),
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
