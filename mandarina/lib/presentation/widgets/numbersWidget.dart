import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';

class NumbersWidget extends StatelessWidget {
  final int completedTasks;
  final int focusMinutes;
  final int affinityLevel;

  const NumbersWidget({
    super.key,
    required this.completedTasks,
    required this.focusMinutes,
    required this.affinityLevel,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildNumberButton(text: 'Tareas', value: completedTasks),
      buildDivider(),
      buildNumberButton(text: 'Minutos', value: focusMinutes),
      buildDivider(),
      buildNumberButton(text: 'Afinidad', value: affinityLevel),
    ],
  );

  Widget buildDivider() => const SizedBox(
    height: 24,
    child: VerticalDivider(color: Color.fromRGBO(232, 141, 103, 0.2)),
  );

  Widget buildNumberButton({
    required String text,
    required int value,
  }) => MaterialButton(
    padding: const EdgeInsets.symmetric(vertical: 4),
    onPressed: (){},
    materialTapTargetSize:  MaterialTapTargetSize.shrinkWrap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          formatNumber(value),
          style: GoogleFonts.quicksand(
            color: MandarinaAppTheme.blueColor,
            fontSize: 25,
            fontWeight: FontWeight.w700
          ),
        ),
        const SizedBox(height: 10,),
        Text(
          text,
          style: GoogleFonts.quicksand(
            color: MandarinaAppTheme.blueColor,
            fontSize: 12,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    ),
  );

  String formatNumber(int value) {
    if (value >= 1000000) {
      return '+${(value / 1000000).toStringAsFixed(1)}M'; // Para +1.2M
    } else if (value >= 1000) {
      return '+${(value / 1000).toInt()}k'; // Para +10k, +100k
    } else {
      return value.toString(); // Números bajos se muestran normal
    }
  }
}