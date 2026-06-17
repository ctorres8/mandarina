import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/providers/phrases_provider.dart';

/// ----------------------------------------------------------------------------
/// MANDARINA COLOR SYSTEM & THEME DEFINITIONS
/// ----------------------------------------------------------------------------
class MandarinaColors {
  static const Color background = Color(0xFFFCFAF7);   // Ultra-warm light grey/white background
  static const Color cardBg = Colors.white;            // Pure white cards for separation
  static const Color orangeAccent = Color(0xFFFF6B35);  // Vibrant Mandarina Orange accent
  static const Color orangeLight = Color(0xFFFFF0EA);   // Very soft pastel peach for active background elements
  static const Color textPrimary = Color(0xFF2D2520);   // Elegant dark charcoal with warm undertones
  static const Color textSecondary = Color(0xFF8B8178); // Soft warm grey for subtitles
  static const Color divider = Color(0xFFF3ECE6);       // Delicate divider for list separation
  static const Color successGreen = Color(0xFF43A047);  // Pure green for connectivity and battery
  static const Color shadowColor = Color(0x062D2520);   // Barely visible dark warm shadow
  static const Color iconBgLight = Color(0xFFFAF5F0);   // Beautiful background circle for list icons
  static const Color iconColorWarm = Color(0xFF6E645C); // Standard icon color
}

/// Helper method to guarantee the 'Quicksand' typography is always applied.
/*
TextStyle mandarinaTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.quicksand(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}
*/

/// ----------------------------------------------------------------------------
/// MANDARINA SETTINGS DEMO WRAPPER (Stateful)
/// ----------------------------------------------------------------------------
/// This widget serves as a fully interactive demo wrapper. It handles local state
/// changes with smooth animations so you can run the screen instantly.
/// In your actual app, you can easily plug in the stateless [MandarinaSettingsScreen]
/// directly to your Riverpod state providers.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen ({Key? key}) : super(key: key);
  static const String name = 'settings_screen';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // --- Local State Variables (to be bound to Riverpod / State Management in prod) ---
  bool _keepScreenOn = false;
  String _selectedLanguage = 'Español (ES)';
  String _firstDayOfWeek = 'Lunes';

  bool _petConnected = true;
  int _petBatteryLevel = 87;
  bool _petRgbLightsOn = true;
  double _petRgbBrightness = 0.6;
  bool _petSoundAlertsOn = true;
  bool _petAutoBrightnessOn = false;
  bool _petWakeOnMotion = true;

  @override
  Widget build(BuildContext context) {
    // Provide a beautiful Material App context to display it beautifully in the runner
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: MandarinaColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MandarinaColors.orangeAccent,
          background: MandarinaColors.background,
          primary: MandarinaColors.orangeAccent,
        ),
      ),
      child: Scaffold(
        body: MandarinaSettingsScreen(
          // --- Values ---
          keepScreenOn: _keepScreenOn,
          selectedLanguage: _selectedLanguage,
          firstDayOfWeek: _firstDayOfWeek,
          petConnected: _petConnected,
          petBatteryLevel: _petBatteryLevel,
          petRgbLightsOn: _petRgbLightsOn,
          petRgbBrightness: _petRgbBrightness,
          petSoundAlertsOn: _petSoundAlertsOn,
          petAutoBrightnessOn: _petAutoBrightnessOn,
          petWakeOnMotion: _petWakeOnMotion,
          appVersion: '1.2.0-stable',
          firmwareVersion: '0.9.4-beta (ESP32)',

          // --- Callbacks (with Haptic Feedback for premium feel) ---
          onManageAllowedAppsPressed: () {
            HapticFeedback.lightImpact();
            _showDialog(
              context,
              'Aplicaciones Permitidas',
              'Aquí se abrirá la vista para seleccionar las apps permitidas durante las sesiones de enfoque, evitando distracciones.',
            );
          },
          onCustomPhrasesPressed: () {
            HapticFeedback.lightImpact();
            _showCustomPhrasesDialog(context);
          },
          onKeepScreenOnChanged: (val) {
            HapticFeedback.mediumImpact();
            setState(() {
              _keepScreenOn = val;
            });
          },
          onChangeLanguagePressed: () {
            HapticFeedback.lightImpact();
            _showLanguageSelector(context);
          },
          onFirstDayOfWeekPressed: () {
            HapticFeedback.lightImpact();
            _showDaySelector(context);
          },
          onPetConnectionDetailsPressed: () {
            HapticFeedback.lightImpact();
            _showDialog(
              context,
              'Mandarina PET',
              'Detalles del Hardware:\n• Dispositivo: ESP32-WROOM\n• RSSI: -54 dBm (Excelente)\n• Dirección MAC: 24:0A:C4:8B:58:C2',
            );
          },
          onPetRgbLightsChanged: (val) {
            HapticFeedback.mediumImpact();
            setState(() {
              _petRgbLightsOn = val;
            });
          },
          onPetRgbBrightnessChanged: (val) {
            setState(() {
              _petRgbBrightness = val;
            });
          },
          onPetSoundAlertsChanged: (val) {
            HapticFeedback.mediumImpact();
            setState(() {
              _petSoundAlertsOn = val;
            });
          },
          onPetAutoBrightnessChanged: (val) {
            HapticFeedback.mediumImpact();
            setState(() {
              _petAutoBrightnessOn = val;
            });
          },
          onPetWakeOnMotionChanged: (val) {
            HapticFeedback.mediumImpact();
            setState(() {
              _petWakeOnMotion = val;
            });
          },
          onSendFeedbackPressed: () {
            HapticFeedback.lightImpact();
            _showFeedbackForm(context);
          },
          onNotionPagePressed: () {
            HapticFeedback.lightImpact();
            _showDialog(
              context,
              'Espacio de Notion',
              'Se abrirá el navegador externo con la documentación oficial del proyecto:\nhttps://notion.so/mandarina-project',
            );
          },
          onAboutMandarinaPressed: () {
            HapticFeedback.lightImpact();
            _showAboutDialog(context);
          },
        ),
      ),
    );
  }

  // --- UI Helper Dialogs for Interactive Demo ---
  void _showDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MandarinaAppTheme.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: mandarinaTextStyle(fontWeight: FontWeight.bold, color: MandarinaAppTheme.primaryColor)),
        content: Text(text, style: mandarinaTextStyle(color: MandarinaAppTheme.blueColor, height: 1.4,fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido', style: mandarinaTextStyle(fontWeight: FontWeight.bold, color: MandarinaAppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showCustomPhrasesDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: MandarinaAppTheme.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.65,
              maxWidth: 400,
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final phrases = ref.watch(phrasesProvider);
                final isLimitReached = phrases.length >= 10;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y Contador
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Frases de Enfoque',
                          style: mandarinaTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MandarinaAppTheme.primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLimitReached
                                ? Colors.red.shade50
                                : MandarinaAppTheme.primarySoftColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${phrases.length}/10',
                            style: mandarinaTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isLimitReached
                                  ? Colors.red.shade600
                                  : MandarinaAppTheme.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega frases motivacionales que aparecerán en tus pantallas de enfoque.',
                      style: mandarinaTextStyle(
                        fontSize: 12,
                        color: MandarinaAppTheme.blueColor.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TextField + Botón "+"
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: mandarinaTextStyle(
                              fontSize: 14,
                              color: MandarinaAppTheme.blueBisColor,
                            ),
                            decoration: InputDecoration(
                              hintText: isLimitReached
                                  ? 'Límite alcanzado'
                                  : 'Escribe tu frase aquí...',
                              hintStyle: mandarinaTextStyle(
                                fontSize: 13,
                                color: MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              enabled: !isLimitReached,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: isLimitReached
                              ? null
                              : () {
                                  final text = textController.text.trim();
                                  if (text.isNotEmpty) {
                                    ref.read(phrasesProvider.notifier).addPhrase(text);
                                    textController.clear();
                                    HapticFeedback.lightImpact();
                                  }
                                },
                          icon: Icon(
                            Icons.add_rounded,
                            color: isLimitReached
                                ? Colors.grey
                                : MandarinaAppTheme.whiteColor,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isLimitReached
                                ? Colors.grey.shade300
                                : MandarinaAppTheme.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Lista de frases
                    Expanded(
                      child: phrases.isEmpty
                          ? Center(
                              child: Text(
                                'No hay frases personalizadas.',
                                style: mandarinaTextStyle(
                                  fontSize: 14,
                                  color: MandarinaAppTheme.blueColor.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: phrases.length,
                              itemBuilder: (context, index) {
                                final phrase = phrases[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MandarinaAppTheme.primarySoftColor
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: MandarinaAppTheme.primarySoftColor
                                          .withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          phrase,
                                          style: mandarinaTextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: MandarinaAppTheme.blueBisColor,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          ref
                                              .read(phrasesProvider.notifier)
                                              .removePhrase(index);
                                          HapticFeedback.lightImpact();
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Botón Cerrar
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Cerrar',
                          style: mandarinaTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MandarinaAppTheme.blueColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MandarinaAppTheme.whiteColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final languages = ['Español (ES)', 'English (US)', 'Português (BR)', 'Français (FR)'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccionar Idioma',
                  style: mandarinaTextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MandarinaAppTheme.blueColor),
                ),
                const SizedBox(height: 16),
                ...languages.map((lang) {
                  final isSelected = _selectedLanguage == lang;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      lang,
                      style: mandarinaTextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? MandarinaAppTheme.accentColor : MandarinaAppTheme.blueColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: MandarinaAppTheme.accentColor)
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedLanguage = lang;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDaySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MandarinaAppTheme.whiteColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final days = ['Lunes', 'Domingo'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primer día de la semana',
                  style: mandarinaTextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MandarinaAppTheme.blueColor),
                ),
                const SizedBox(height: 16),
                ...days.map((day) {
                  final isSelected = _firstDayOfWeek == day;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      day,
                      style: mandarinaTextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? MandarinaAppTheme.accentColor : MandarinaAppTheme.blueColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: MandarinaAppTheme.accentColor)
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _firstDayOfWeek = day;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackForm(BuildContext context) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: MandarinaAppTheme.whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enviar una sugerencia',
                style: mandarinaTextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MandarinaAppTheme.primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus ideas hacen crecer a Mandarina. Cuéntanos qué te gustaría mejorar o qué función extra esperas de tu PET.',
                style: mandarinaTextStyle(fontSize: 13, color: MandarinaAppTheme.blueColor, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 4,
                style: mandarinaTextStyle(color: MandarinaAppTheme.primaryOrangeColor),
                decoration: InputDecoration(
                  hintText: 'Escribe tu sugerencia aquí...',
                  hintStyle: mandarinaTextStyle(color: MandarinaAppTheme.primaryOrangeColor.withAlpha(100)),
                  filled: true,
                  fillColor: MandarinaAppTheme.whiteBisColor.withAlpha(70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: MandarinaAppTheme.primaryOrangeColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      HapticFeedback.lightImpact();//.successImpact(); **************************
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Gracias! Sugerencia recibida con éxito.', style: mandarinaTextStyle(color: MandarinaAppTheme.whiteColor)),
                          backgroundColor: MandarinaAppTheme.blueColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MandarinaAppTheme.primaryOrangeColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Enviar sugerencia',
                    style: mandarinaTextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MandarinaAppTheme.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: MandarinaAppTheme.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Custom Mandarina Vector Logo inside Flutter
              Image.asset('assets/images/logo_naranja.png',scale:4,),
              const SizedBox(height: 10),
              Text(
                'Mandarina',
                style: mandarinaTextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MandarinaAppTheme.primaryColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Tu ecosistema de productividad',
                style: mandarinaTextStyle(fontSize: 13, color: MandarinaAppTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.whiteBisColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildAboutRow('Versión de App', 'v0.1.0-stable'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: MandarinaColors.divider, height: 1),
                    ),
                    _buildAboutRow('Firmware', 'v0.0.0-beta'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: MandarinaColors.divider, height: 1),
                    ),
                    _buildAboutRow('Hardware', 'Revision C'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Diseñada para potenciar tu\nespacio de trabajo.',
                textAlign: TextAlign.center,
                style: mandarinaTextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MandarinaAppTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar', style: mandarinaTextStyle(fontWeight: FontWeight.bold, color: MandarinaAppTheme.blueColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: mandarinaTextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: MandarinaAppTheme.primaryColor)),
        Text(value, style: mandarinaTextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: MandarinaAppTheme.blueBisColor)),
      ],
    );
  }
}

/// ----------------------------------------------------------------------------
/// MANDARINA SETTINGS SCREEN (Stateless Core Screen)
/// ----------------------------------------------------------------------------
class MandarinaSettingsScreen extends StatelessWidget {
  // --- States passed from parent/Riverpod ---
  final bool keepScreenOn;
  final String selectedLanguage;
  final String firstDayOfWeek;

  final bool petConnected;
  final int petBatteryLevel;
  final bool petRgbLightsOn;
  final double petRgbBrightness;
  final bool petSoundAlertsOn;
  final bool petAutoBrightnessOn;
  final bool petWakeOnMotion;

  final String appVersion;
  final String firmwareVersion;

  // --- Interactivity Callbacks ---
  final VoidCallback? onManageAllowedAppsPressed;
  final VoidCallback? onCustomPhrasesPressed;
  final ValueChanged<bool>? onKeepScreenOnChanged;
  final VoidCallback? onChangeLanguagePressed;
  final VoidCallback? onFirstDayOfWeekPressed;

  final VoidCallback? onPetConnectionDetailsPressed;
  final ValueChanged<bool>? onPetRgbLightsChanged;
  final ValueChanged<double>? onPetRgbBrightnessChanged;
  final ValueChanged<bool>? onPetSoundAlertsChanged;
  final ValueChanged<bool>? onPetAutoBrightnessChanged;
  final ValueChanged<bool>? onPetWakeOnMotionChanged;

  final VoidCallback? onSendFeedbackPressed;
  final VoidCallback? onNotionPagePressed;
  final VoidCallback? onAboutMandarinaPressed;

  const MandarinaSettingsScreen({
    Key? key,
    required this.keepScreenOn,
    required this.selectedLanguage,
    required this.firstDayOfWeek,
    required this.petConnected,
    required this.petBatteryLevel,
    required this.petRgbLightsOn,
    required this.petRgbBrightness,
    required this.petSoundAlertsOn,
    required this.petAutoBrightnessOn,
    required this.petWakeOnMotion,
    this.appVersion = '1.0.0',
    this.firmwareVersion = '1.0.0',
    this.onManageAllowedAppsPressed,
    this.onCustomPhrasesPressed,
    this.onKeepScreenOnChanged,
    this.onChangeLanguagePressed,
    this.onFirstDayOfWeekPressed,
    this.onPetConnectionDetailsPressed,
    this.onPetRgbLightsChanged,
    this.onPetRgbBrightnessChanged,
    this.onPetSoundAlertsChanged,
    this.onPetAutoBrightnessChanged,
    this.onPetWakeOnMotionChanged,
    this.onSendFeedbackPressed,
    this.onNotionPagePressed,
    this.onAboutMandarinaPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: MandarinaAppTheme.whiteColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: MandarinaAppTheme.backgroundSettingsColor,//primaryOrangeColor.withAlpha(100),
        
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- PREMIUM APPBAR ---
              SliverAppBar(
                floating: true,
                //snap: true,
                pinned: false,
                iconTheme: const IconThemeData(color: MandarinaAppTheme.whiteColor),
                title: Text(
                  'Ajustes',
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  ),//Image.asset('assets/images/logo_blanco.png',scale:18,),
                centerTitle: true,
                elevation: 0,
                backgroundColor: MandarinaAppTheme.primaryColor,//backgroundSettingsColor,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const FaIcon(
                    FontAwesomeIcons.chevronLeft, 
                    size: 16,
                    color: MandarinaAppTheme.whiteColor,
                  ),
                ),
              ),
              /*
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 10.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajustes',
                        style: GoogleFonts.quicksand(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: MandarinaAppTheme.blueColor,//blueBisColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              */

              // --- MAIN SETTINGS LIST ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // ==========================================
                    // BLOQUE 1: Ajustes Generales
                    // ==========================================
                    _buildSectionHeader('Ajustes Generales'),
                    MandarinaCard(
                      children: [
                        MandarinaListTile(
                          icon: Icons.app_blocking_rounded,
                          title: 'Lista de apps permitidas',
                          subtitle: 'Elige qué apps puedes abrir en tus focos',
                          onTap: onManageAllowedAppsPressed,
                        ),
                        const MandarinaDivider(),
                        MandarinaListTile(
                          icon: Icons.format_quote_rounded,
                          title: 'Frases personalizadas',
                          subtitle: 'Tus propios mensajes inspiradores',
                          onTap: onCustomPhrasesPressed,
                        ),
                        const MandarinaDivider(),
                        MandarinaSwitchTile(
                          icon: Icons.screen_lock_rotation_rounded,
                          title: 'No apagar pantalla',
                          subtitle: 'Mantener pantalla activa durante el enfoque',
                          value: keepScreenOn,
                          onChanged: onKeepScreenOnChanged,
                        ),
                        const MandarinaDivider(),
                        MandarinaListTile(
                          icon: Icons.translate_rounded,
                          title: 'Cambiar Idioma',
                          subtitle: selectedLanguage,
                          onTap: onChangeLanguagePressed,
                        ),
                        const MandarinaDivider(),
                        MandarinaListTile(
                          icon: Icons.calendar_today_rounded,
                          title: 'Primer día de la semana',
                          subtitle: firstDayOfWeek,
                          onTap: onFirstDayOfWeekPressed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // BLOQUE 2: Mandarina PET (Dispositivo)
                    // ==========================================
                    _buildSectionHeader('Mandarina PET'),
                    MandarinaCard(
                      children: [
                        // Estado de Conexión
                        MandarinaListTile(
                          icon: Icons.bluetooth_connected_rounded,
                          iconBgColor: petConnected
                              ? MandarinaColors.orangeLight
                              : MandarinaColors.background,
                          iconColor: petConnected
                              ? MandarinaColors.orangeAccent
                              : MandarinaColors.textSecondary,
                          title: 'Mandarina PET',
                          subtitle: petConnected ? 'Dispositivo conectado' : 'Desconectado',
                          onTap: onPetConnectionDetailsPressed,
                          trailing: petConnected
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BatteryIndicator(level: petBatteryLevel),
                                    const SizedBox(width: 8),
                                    const FaIcon(
                                      FontAwesomeIcons.chevronRight,//Icons.chevron_right_rounded,
                                      color: MandarinaAppTheme.blueColor,
                                      size: 12,
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Desconectado',
                                    style: mandarinaTextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                        ),
                        const MandarinaDivider(),
                        
                        // Luces RGB Switch + Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MandarinaSwitchTile(
                              icon: Icons.palette_rounded,
                              title: 'Luces RGB',
                              subtitle: 'Anillo de luz ambiental LED interactivo',
                              value: petRgbLightsOn,
                              onChanged: onPetRgbLightsChanged,
                            ),
                            // Smoothly animate the expansion of the Slider
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              firstChild: Container(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(left: 68.0, right: 24.0, bottom: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Brillo en las luces LED',
                                          style: mandarinaTextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: MandarinaAppTheme.blueColor,
                                          ),
                                        ),
                                        Text(
                                          '${(petRgbBrightness * 100).toInt()}%',
                                          style: mandarinaTextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: MandarinaAppTheme.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.wb_sunny_outlined, size: 16, color: MandarinaAppTheme.blueColor),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 4,
                                              activeTrackColor: MandarinaAppTheme.accentColor,
                                              inactiveTrackColor: MandarinaAppTheme.primaryOrangeColor.withValues(alpha:0.2),
                                              thumbColor: MandarinaAppTheme.accentColor,
                                              overlayColor: MandarinaAppTheme.accentColor.withAlpha(20),
                                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                            ),
                                            child: Slider(
                                              value: petRgbBrightness,
                                              onChanged: onPetRgbBrightnessChanged,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.wb_sunny_rounded, size: 16, color: MandarinaAppTheme.accentColor),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: petRgbLightsOn
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                            ),
                          ],
                        ),
                        const MandarinaDivider(),

                        // Alertas de Sonido (Buzzer)
                        MandarinaSwitchTile(
                          icon: Icons.volume_up_rounded,
                          title: 'Alertas de Sonido (Buzzer)',
                          subtitle: 'Alertas físicas en tonos divertidos de 8-bit',
                          value: petSoundAlertsOn,
                          onChanged: onPetSoundAlertsChanged,
                        ),
                        const MandarinaDivider(),

                        // Brillo Automático (Sensor LDR)
                        MandarinaSwitchTile(
                          icon: Icons.hdr_auto_rounded,
                          title: 'Brillo Automático (Sensor LDR)',
                          subtitle: 'Ajuste inteligente de luz según el entorno',
                          value: petAutoBrightnessOn,
                          onChanged: onPetAutoBrightnessChanged,
                        ),
                        const MandarinaDivider(),

                        // Acelerómetro / Despertar por Movimiento
                        MandarinaSwitchTile(
                          icon: Icons.edgesensor_high_rounded,
                          title: 'Despertar por Movimiento',
                          subtitle: 'Wake-on-motion activo para ahorrar energía',
                          value: petWakeOnMotion,
                          onChanged: onPetWakeOnMotionChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // BLOQUE 3: Soporte y Comunidad
                    // ==========================================
                    _buildSectionHeader('Soporte y Comunidad'),
                    MandarinaCard(
                      children: [
                        MandarinaListTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Enviar una sugerencia',
                          subtitle: 'Escríbenos ideas para Mandarina',
                          onTap: onSendFeedbackPressed,
                        ),
                        const MandarinaDivider(),
                        MandarinaListTile(
                          icon: Icons.menu_book_rounded,
                          title: 'Página de Notion',
                          subtitle: 'Documentación oficial y guías',
                          trailing: Icon(
                            Icons.open_in_new_rounded,
                            color: MandarinaAppTheme.blueColor,
                            size: 18,
                          ),
                          onTap: onNotionPagePressed,
                        ),
                        const MandarinaDivider(),
                        MandarinaListTile(
                          icon: Icons.info_outline_rounded,
                          title: 'Sobre el proyecto',
                          subtitle: 'Información de versión, firmware y créditos',
                          onTap: onAboutMandarinaPressed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Soft minimalist credits at the very bottom
                    Center(
                      child: Text(
                        'Mandarina • IoT Ecosystem\nv$appVersion',
                        textAlign: TextAlign.center,
                        style: mandarinaTextStyle(
                          fontSize: 12,
                          color: MandarinaAppTheme.blueColor.withAlpha(150),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],

        ),
      ),
    );
  }

  // Helper widget to construct stylish category titles with a neat accent dot
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
      child: Row(
        children: [
          /*
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: MandarinaAppTheme.primaryOrangeColor,
              shape: BoxShape.circle,
            ),
          ),
          */
          Image.asset('assets/images/logo_naranja.png',scale:24,),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: MandarinaAppTheme.blueColor,//MandarinaColors.textSecondary,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// CUSTOM MINI-WIDGETS & WRAPPERS FOR A PERFECT ZEN STYLE
/// ----------------------------------------------------------------------------

/// Standard Card container designed for cohesive aesthetic alignment
class MandarinaCard extends StatelessWidget {
  final List<Widget> children;
  const MandarinaCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MandarinaAppTheme.whiteColor,//MandarinaColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        
        boxShadow: [
          BoxShadow(
            color: MandarinaAppTheme.darkBlueColor.withAlpha(40),//MandarinaColors.shadowColor,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

/// A highly polished, custom-made ListTile
class MandarinaListTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MandarinaListTile({
    Key? key,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,//MandarinaColors.orangeLight,
      //highlightColor: MandarinaAppTheme.primaryColor,//MandarinaColors.orangeLight.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            // High-end rounded circle container for the icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MandarinaAppTheme.primarySoftColor.withValues(alpha: 0.7),//iconBgColor ?? MandarinaColors.iconBgLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: MandarinaAppTheme.primaryOrangeColor,//iconColor ?? MandarinaColors.iconColorWarm,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: MandarinaAppTheme.blueBisColor,//MandarinaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                      fontSize: 12.5,
                      color: MandarinaAppTheme.blueColor,//MandarinaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: MandarinaAppTheme.blueColor,//MandarinaColors.textSecondary,
                  size: 12,
                ),
          ],
        ),
      ),
    );
  }
}

/// A highly polished, custom-made SwitchListTile
class MandarinaSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const MandarinaSwitchTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          // High-end rounded circle container for the icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MandarinaAppTheme.primarySoftColor.withValues(alpha: 0.7),//value ? MandarinaColors.orangeLight : MandarinaColors.iconBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: MandarinaAppTheme.primaryOrangeColor,//value ? MandarinaColors.orangeAccent : MandarinaColors.iconColorWarm,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: MandarinaAppTheme.blueBisColor,//MandarinaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    color: MandarinaAppTheme.blueColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Clean custom switch with modern sizing and warm curves
          Switch.adaptive(
            value: value,
            //activeColor: MandarinaColors.orangeAccent,
            activeThumbColor: MandarinaAppTheme.primaryOrangeColor,
            activeTrackColor: MandarinaAppTheme.primarySoftColor.withValues(alpha:0.8),//MandarinaColors.orangeLight,
            inactiveThumbColor: MandarinaAppTheme.blueColor,//MandarinaColors.textSecondary.withOpacity(0.8),
            inactiveTrackColor: MandarinaAppTheme.blueColor.withValues(alpha:0.05),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return MandarinaAppTheme.primaryOrangeColor.withValues(alpha:0.1);//MandarinaColors.orangeAccent.withOpacity(0.2);
              }
              return MandarinaAppTheme.blueColor.withValues(alpha:0.1);
            }),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A very delicate separator divider line matching the clean tone
class MandarinaDivider extends StatelessWidget {
  const MandarinaDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(
        color: MandarinaColors.divider,
        height: 1,
        thickness: 1,
      ),
    );
  }
}

/// Custom Battery indicator with connection status
class BatteryIndicator extends StatelessWidget {
  final int level;
  const BatteryIndicator({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Beautiful green coloring if battery is healthy, orange/red if low
    Color batteryColor;
    if (level > 40) {
      batteryColor = MandarinaColors.successGreen;
    } else if (level > 15) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: batteryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant custom tiny battery cylinder
          Container(
            width: 20,
            height: 11,
            decoration: BoxDecoration(
              border: Border.all(color: batteryColor.withOpacity(0.8), width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                // Battery capacity fill
                FractionallySizedBox(
                  widthFactor: level / 100.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: batteryColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$level%',
            style: mandarinaTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: batteryColor,
            ),
          ),
        ],
      ),
    );
  }
}
