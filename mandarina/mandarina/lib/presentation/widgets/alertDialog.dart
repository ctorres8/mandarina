import 'package:flutter/material.dart';

class MandarinaDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Widget? extraContent; // Por si quieres meter un TextField o algo más
  final String buttonText;
  final VoidCallback onConfirm;

  const MandarinaDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.extraContent,
    this.buttonText = 'Entendido',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF1BF98), // Tu color crema base
      title: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 50, color: colors.primary),
            const SizedBox(height: 15),
          ],
          Text(title, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(content, textAlign: TextAlign.center),
          if (extraContent != null) ...[
            const SizedBox(height: 20),
            extraContent!,
          ],
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: onConfirm,
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }
}