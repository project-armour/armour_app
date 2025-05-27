import 'package:flutter/material.dart';

class SheetMainButton extends StatelessWidget {
  const SheetMainButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(80, 24)),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(14, 10, 14, 10)),
        iconSize: WidgetStatePropertyAll(22),
      ),

      onPressed: onPressed,
      child: Flex(
        direction: Axis.vertical,
        spacing: 4,
        children: [
          Icon(icon),
          Text(style: Theme.of(context).textTheme.labelMedium, text),
        ],
      ),
    );
  }
}
