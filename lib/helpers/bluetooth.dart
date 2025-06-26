import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceProvider with ChangeNotifier {
  BluetoothDevice? _device;

  BluetoothDevice? get device => _device;

  void setDevice(BluetoothDevice device) {
    _device = device;
    notifyListeners();
  }

  void clearDevice() {
    _device = null;
    notifyListeners();
  }
}
