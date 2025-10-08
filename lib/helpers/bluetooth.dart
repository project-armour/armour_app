import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceProvider with ChangeNotifier {
  BluetoothDevice? _device;

  BluetoothDevice? get device => _device;

  StreamSubscription<BluetoothConnectionState>? connStream;

  void setDevice(BluetoothDevice device) {
    _device = device;
    notifyListeners();
    subscribe();
  }

  void subscribe() {
    if (_device != null) {
      connStream = _device?.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          notifyListeners();
        }
      });
    }
  }

  void clearDevice() {
    _device = null;
    if (connStream != null) {
      connStream?.cancel();
    }
    notifyListeners();
  }
}
