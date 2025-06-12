import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class PanicPage extends StatefulWidget {
  const PanicPage({super.key});

  @override
  State<PanicPage> createState() => _PanicPageState();
}

final List<Map<String, dynamic>> _morsePattern = [
  // S: ...
  {'on': true, 'duration': 300},
  {'on': false, 'duration': 300},
  {'on': true, 'duration': 300},
  {'on': false, 'duration': 300},
  {'on': true, 'duration': 300},
  {'on': false, 'duration': 900}, // end of S
  // O: ---
  {'on': true, 'duration': 900},
  {'on': false, 'duration': 300},
  {'on': true, 'duration': 900},
  {'on': false, 'duration': 300},
  {'on': true, 'duration': 900},
  {'on': false, 'duration': 900}, // end of O
  // S: ...
  {'on': true, 'duration': 300},
  {'on': false, 'duration': 300},
  {'on': true, 'duration': 300},
  {'on': false, 'duration': 300},
  {'on': true, 'duration': 300},
  {'on': false, 'duration': 2100}, // end of SOS, gap before repeat
];

enum Options { sos, torch, siren }

class _PanicPageState extends State<PanicPage> {
  bool isVisible = false;
  int _colorIndex = 0; // 0: red, 1: white, 2: blue
  Timer? _timer;
  int _index = 0;
  Set<Options> selection = <Options>{Options.sos};
  bool _hasTorch = false;

  static const List<Color> _blinkColors = [
    Colors.red,
    Colors.white,
    Colors.blue,
  ];

  void _runMorseStep() {
    if (!selection.contains(Options.sos)) {
      _runBlinkStep();
      return;
    }
    final current = _morsePattern[_index];
    if (_hasTorch) {
      if (selection.contains(Options.torch)) {
        if (current['on']) {
          TorchLight.enableTorch();
        } else {
          TorchLight.disableTorch();
        }
      } else {
        TorchLight.disableTorch();
      }
    }

    setState(() {
      isVisible = current['on'];
      _colorIndex = 0; // Always red for Morse
    });

    _timer = Timer(Duration(milliseconds: current['duration']), () {
      _index = (_index + 1) % _morsePattern.length;
      _runMorseStep();
    });
  }

  void _runBlinkStep() {
    if (selection.contains(Options.sos)) {
      _index = 0;
      _runMorseStep();
      return;
    }
    setState(() {
      isVisible = true;
      _colorIndex = (_colorIndex + 1) % _blinkColors.length;
    });
    if (_hasTorch) {
      if (selection.contains(Options.torch)) {
        if (_colorIndex % 2 == 0) {
          TorchLight.enableTorch();
        } else {
          TorchLight.disableTorch();
        }
      } else {
        TorchLight.disableTorch();
      }
    }

    _timer = Timer(const Duration(milliseconds: 400), _runBlinkStep);
  }

  void _restartTimer() {
    _timer?.cancel();
    _index = 0;
    _colorIndex = 0;
    if (selection.contains(Options.sos)) {
      _runMorseStep();
    } else {
      _runBlinkStep();
    }
  }

  void _checkTorch() async {
    final isTorchAvailable = await TorchLight.isTorchAvailable();
    setState(() {
      _hasTorch = isTorchAvailable;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkTorch();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panic")),
      body: Stack(
        children: [
          if (isVisible)
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _blinkColors[_colorIndex],
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(40),
                padding: EdgeInsets.all(4),
                child: Center(
                  child: SegmentedButton(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: ColorScheme.of(
                        context,
                      ).surfaceContainerLow.withAlpha(220),
                      disabledBackgroundColor: ColorScheme.of(
                        context,
                      ).surfaceContainerLowest.withAlpha(200),
                      foregroundColor: Colors.white,
                      selectedBackgroundColor: ColorScheme.of(
                        context,
                      ).surfaceBright.withAlpha(220),
                    ),
                    segments: <ButtonSegment<Options>>[
                      ButtonSegment(value: Options.sos, label: Text("SOS")),
                      ButtonSegment(
                        value: Options.torch,
                        label: Text("Torch"),
                        enabled: _hasTorch,
                      ),
                      ButtonSegment(value: Options.siren, label: Text("Siren")),
                    ],
                    selected: selection,
                    onSelectionChanged: (Set<Options> newSelection) {
                      setState(() {
                        selection = newSelection;
                        _restartTimer();
                      });
                    },
                    multiSelectionEnabled: true,
                    emptySelectionAllowed: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
