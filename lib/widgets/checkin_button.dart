import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Ink(
        width: 80,
        height: 80,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF7AD0FF), Color(0xFF2AB7F1)],
            center: Alignment(-1, -1),
            radius: 1.25,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.shieldCheck300),
            Text(
              "Check-in",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      iconSize: 38,
      padding: EdgeInsets.all(0),
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}
