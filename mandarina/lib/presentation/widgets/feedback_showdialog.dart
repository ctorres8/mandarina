import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mandarina/core/theme/app_theme.dart';

/// Muestra un cuadro de diálogo de felicitaciones / feedback con una frase motivacional aleatoria.
Future<void> showFeedbackDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return const FeedbackShowDialog();
    },
  );
}

class FeedbackShowDialog extends StatelessWidget {
  const FeedbackShowDialog({super.key});

  static const List<String> _motivationalPhrases = [
    "¡Excelente trabajo! Un paso más cerca de tus metas 🍊",
    "¡Pomodoro completado! Tómate un merecido descanso ☕",
    "¡Increíble enfoque! Seguimos sumando tiempo de calidad 🍊",
    "¡Objetivo alcanzado! Tu disciplina da frutos 🍊",
    "¡Sesión terminada! Cada esfuerzo cuenta hacia tu éxito 🍊",
    "¡Gran constancia! Sigue cultivando tu enfoque 🍊",
    "¡Lo lograste! Momento de estirar y recargar energías 🔋",
  ];

  @override
  Widget build(BuildContext context) {
    final randomPhrase =
        _motivationalPhrases[Random().nextInt(_motivationalPhrases.length)];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: MandarinaAppTheme.whiteColor,
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono festivo con contenedor circular
          const Icon(Icons.check_circle, size: 48.0, color: Color(0xFF3F7D58)),
          /*
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.transparent, //MandarinaAppTheme.primarySoftColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 48.0,
              color: Color(0xFF3F7D58),
            ),
          ),
          */
          const SizedBox(height: 15.0),
          // Título del diálogo
          Text(
            "¡Felicitaciones!",
            textAlign: TextAlign.center,
            style: mandarinaTextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: MandarinaAppTheme.primaryOrangeColor,
            ),
          ),
          const SizedBox(height: 12.0),
          // Frase motivacional seleccionada aleatoriamente
          Text(
            randomPhrase,
            textAlign: TextAlign.center,
            style: mandarinaTextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: MandarinaAppTheme.blueColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24.0),
          // Botón de cierre centrado
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: MandarinaAppTheme.primaryOrangeColor,
                foregroundColor: MandarinaAppTheme.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 0,
              ),
              child: Text(
                "¡A descansar!",
                style: mandarinaTextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: MandarinaAppTheme.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
