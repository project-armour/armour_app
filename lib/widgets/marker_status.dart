import 'package:flutter/material.dart';

class MarkerStatus extends StatefulWidget {
  const MarkerStatus({super.key, this.isOnline = false});
  final bool isOnline;

  @override
  State<MarkerStatus> createState() => _MarkerStatusState();
}

class _MarkerStatusState extends State<MarkerStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    );
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          size: 16,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        widget.isOnline
            ? FadeTransition(
              opacity: _animationController,
              child: Icon(Icons.circle, size: 12, color: Colors.greenAccent),
            )
            : Icon(Icons.circle_outlined, size: 12, color: Colors.grey),
      ],
    );
  }
}
