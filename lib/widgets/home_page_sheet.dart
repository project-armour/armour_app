import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter/material.dart';

class HomePageSheet extends StatefulWidget {
  const HomePageSheet({super.key});

  @override
  State<HomePageSheet> createState() => _HomePageSheetState();
}

class _HomePageSheetState extends State<HomePageSheet> {
  final sheetHeights = [480.0, 240.0];
  late final SheetController controller;

  @override
  void initState() {
    controller = SheetController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetViewport(
      child: Sheet(
        initialOffset: SheetOffset.absolute(480),
        controller: controller,
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
              
            ],
          ),
        ),
      ),
    );
  }
}
