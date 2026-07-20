import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mandarina/core/theme/app_theme.dart';

Future<void> showTermsBottomSheet(
  BuildContext context, {
  required VoidCallback onAccepted,
}) {
  Future<void> launchPDFUrl() async {
    final Uri url = Uri.parse(
      'https://drive.google.com/file/d/1KB1MlS484ARhToZVhKZ9auudZZ-BQm2z/view?usp=drive_link',
    );
    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
      );
      if (!launched) {
        final bool launchedDefault = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
        if (!launchedDefault) {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo abrir el PDF completo.',
              style: mandarinaTextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: MandarinaAppTheme.blueColor,
          ),
        );
      }
    }
  }

  Widget buildTermItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: MandarinaAppTheme.primaryOrangeColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: mandarinaTextStyle(
                    color: MandarinaAppTheme.primaryOrangeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Text(
              description,
              style: mandarinaTextStyle(
                color: MandarinaAppTheme.blueColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              MandarinaAppTheme.whiteColor,
              MandarinaAppTheme.whiteBisColor,
            ],
            stops: [0.8, 1.0],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.darkBlueColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              'Términos y Condiciones\n(Versión Beta)',
              textAlign: TextAlign.center,
              style: mandarinaTextStyle(
                color: MandarinaAppTheme.primaryOrangeColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTermItem(
                      'Propósito Académico',
                      'Esta aplicación forma parte de un proyecto de investigación y desarrollo técnico para la Tesis de Grado de la carrera de Ingeniería Electrónica de la UTN FRBA. No es un producto comercial.',
                    ),
                    buildTermItem(
                      'Versión Beta',
                      'El software se entrega "tal como está". Al estar en fase de desarrollo, pueden ocurrir bugs, interrupciones o pérdidas de sincronización. La UTN FRBA y el desarrollador quedan eximidos de cualquier tipo de responsabilidad por fallas técnicas.',
                    ),
                    buildTermItem(
                      'Herramientas',
                      'En esta primera fase, tendrás acceso exclusivo al Módulo de Autenticación, Modo Workflow (cronómetro de checkpoints) y Modo Deporte (rutinas HIIT). Nuevas funciones se agregarán en próximas etapas.',
                    ),
                    buildTermItem(
                      'Tus Datos Seguros',
                      'En cumplimiento con la Ley N° 25.326 de Protección de Datos Personales, recopilamos únicamente tu email y métricas de uso para el correcto funcionamiento de la app. Tu información se procesa de forma confidencial.',
                    ),
                    buildTermItem(
                      'Confidencialidad',
                      'Te comprometes a no difundir públicamente capturas ni lógicas internas del software y a ceder de forma gratuita el feedback o sugerencias de optimización que realices para la mejora de la app.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Al presionar el botón de aceptación, declarás estar de acuerdo con estos términos como Tester colaborador.',
                      style: mandarinaTextStyle(
                        color: MandarinaAppTheme.blueColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: launchPDFUrl,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Ver PDF Completo',
                      textAlign: TextAlign.center,
                      style: mandarinaTextStyle(
                        color: MandarinaAppTheme.primaryOrangeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: MandarinaAppTheme.primaryOrangeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onAccepted();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MandarinaAppTheme.primaryOrangeColor,
                      foregroundColor: MandarinaAppTheme.whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: mandarinaTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
