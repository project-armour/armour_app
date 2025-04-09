import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter/material.dart';

class HomePageSheet extends StatefulWidget {
  const HomePageSheet({super.key});

  @override
  State<HomePageSheet> createState() => _HomePageSheetState();
}

class _HomePageSheetState extends State<HomePageSheet> {
  @override
  Widget build(BuildContext context) {
    const sheetHeights = [480.0, 240.0];
    return SheetViewport(
      child: Sheet(
        initialOffset: SheetOffset.absolute(sheetHeights.first),
        snapGrid: SheetSnapGrid(
          snaps:
              sheetHeights.map((value) => SheetOffset.absolute(value)).toList(),
        ),
        decoration: MaterialSheetDecoration(
          size: SheetSize.fit,
          elevation: 1.0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Container(
          height: sheetHeights.first + 200,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 6,
                width: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
                margin: const EdgeInsets.only(bottom: 16, top: 12),
              ),
              const Text(
                'Persistent Bottom Sheet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Your content goes here'),
            ],
          ),
        ),
      ),
    );
  }
}
