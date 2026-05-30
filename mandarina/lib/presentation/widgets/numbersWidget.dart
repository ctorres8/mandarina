import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';

class NumbersWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildNumberButton(text: 'Tareas', value: 234),
      buildDivider(),
      buildNumberButton(text: 'Minutos', value: 15392),
      buildDivider(),
      buildNumberButton(text: 'Afinidad', value: 8),

    ],
  );

  Widget buildDivider() => Container(
    height: 24,
    child: VerticalDivider(color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.2),),
  );

  Widget buildNumberButton({
    required String text,
    required int value,
  }) => MaterialButton(
    padding: EdgeInsets.symmetric(vertical: 4),
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