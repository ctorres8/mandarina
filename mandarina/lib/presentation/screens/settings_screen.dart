import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/phrases_notifier.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';

const Map<String, String> timerSoundOptions = {
  'bell_sound': 'Campana Clásica',
  'success_bip': 'Bip Sutil',
  'success_treble': 'Triple',
  'success_victory': 'Victoria',
};

/// ----------------------------------------------------------------------------

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
  const SettingsScreen({Key? key}) : super(key: key);
  static const String name = 'settings_screen';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // --- Local State Variables (to be bound to Riverpod / State Management in prod) ---
  String _selectedLanguage = 'Español (ES)';
  String _firstDayOfWeek = 'Lunes';
  double? _localTimerVolume;

  bool _petConnected = true;
  int _petBatteryLevel = 87;
  bool _petRgbLightsOn = true;
  double _petRgbBrightness = 0.6;
  bool _petSoundAlertsOn = true;
  bool _petAutoBrightnessOn = false;
  bool _petWakeOnMotion = true;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final keepScreenOn = ref.watch(keepScreenOnProvider);
    final currentTimerSound = profileState.profile?.timerSound ?? 'bell_sound';
    final currentTimerVolume =
        _localTimerVolume ?? profileState.profile?.timerVolume ?? 0.8;

    // Provide a beautiful Material App context to display it beautifully in the runner
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: MandarinaAppTheme.backgroundSettingsColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MandarinaAppTheme.primaryOrangeColor,
          surface: MandarinaAppTheme.whiteColor,
          primary: MandarinaAppTheme.primaryOrangeColor,
        ),
      ),
      child: Scaffold(
        body: MandarinaSettingsScreen(
          // --- Values ---
          keepScreenOn: keepScreenOn,
          selectedLanguage: _selectedLanguage,
          firstDayOfWeek: _firstDayOfWeek,
          timerSound: currentTimerSound,
          timerVolume: currentTimerVolume,
          petConnected: _petConnected,
          petBatteryLevel: _petBatteryLevel,
          petRgbLightsOn: _petRgbLightsOn,
          petRgbBrightness: _petRgbBrightness,
          petSoundAlertsOn: _petSoundAlertsOn,
          petAutoBrightnessOn: _petAutoBrightnessOn,
          petWakeOnMotion: _petWakeOnMotion,
          appVersion: '1.2.0-stable',
          firmwareVersion: '0.9.4-beta (ESP32)',
          onTimerSoundPressed: () {
            HapticFeedback.lightImpact();
            _showTimerSoundSelector(context, currentTimerSound);
          },
          onTimerVolumeChanged: (val) {
            setState(() {
              _localTimerVolume = val;
            });
          },
          onTimerVolumeChangeEnd: (val) {
            setState(() {
              _localTimerVolume = val;
            });
            ref.read(profileProvider.notifier).updateTimerVolume(val);
            ref
                .read(pomoProvider.notifier)
                .playPreviewSound(currentTimerSound, val);
            ref
                .read(pomoProvider.notifier)
                .preloadTimerSound(currentTimerSound, val);
          },

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
            ref.read(keepScreenOnProvider.notifier).setKeepScreenOn(val);
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
              'Se abrirá el navegador externo con la documentación oficial del proyecto:\nhttps://mandarinaapp.notion.site/',
              onConfirm: () => _launchNotionUrl(context),
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

  Future<void> _launchNotionUrl(BuildContext context) async {
    final Uri url = Uri.parse('https://mandarinaapp.notion.site/');
    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se pudo abrir el enlace de Notion.',
                style: mandarinaTextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: MandarinaAppTheme.blueColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al abrir el navegador.',
              style: mandarinaTextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: MandarinaAppTheme.blueColor,
          ),
        );
      }
    }
  }

  // --- UI Helper Dialogs for Interactive Demo ---
  void _showDialog(
    BuildContext context,
    String title,
    String text, {
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MandarinaAppTheme.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: mandarinaTextStyle(
            fontWeight: FontWeight.bold,
            color: MandarinaAppTheme.primaryOrangeColor,
          ),
        ),
        content: Text(
          text,
          style: mandarinaTextStyle(
            color: MandarinaAppTheme.blueColor,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) {
                onConfirm();
              }
            },
            child: Text(
              'Entendido',
              style: mandarinaTextStyle(
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.primaryOrangeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimerSoundSelector(BuildContext context, String currentSound) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MandarinaAppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note_rounded,
                        color: MandarinaAppTheme.primaryOrangeColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sonido de fin de temporizador',
                        style: mandarinaTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MandarinaAppTheme.primaryOrangeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el sonido que se reproducirá al finalizar la sesión:',
                    style: mandarinaTextStyle(
                      fontSize: 13,
                      color: MandarinaAppTheme.blueColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...timerSoundOptions.entries.map((entry) {
                    final isSelected = entry.key == currentSound;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MandarinaAppTheme.primarySoftColor.withValues(
                                alpha: 0.5,
                              )
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? MandarinaAppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: entry.key,
                        groupValue: currentSound,
                        activeColor: MandarinaAppTheme.accentColor,
                        title: Text(
                          entry.value,
                          style: mandarinaTextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: MandarinaAppTheme.blueColor,
                          ),
                        ),
                        onChanged: (String? val) {
                          if (val != null) {
                            HapticFeedback.lightImpact();
                            setModalState(() {
                              currentSound = val;
                            });
                            ref
                                .read(profileProvider.notifier)
                                .updateTimerSound(val);
                            ref
                                .read(pomoProvider.notifier)
                                .playPreviewSound(val);
                            ref
                                .read(pomoProvider.notifier)
                                .preloadTimerSound(val);
                            Navigator.pop(modalContext);
                          }
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomPhrasesDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: MandarinaAppTheme.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                            color: MandarinaAppTheme.primaryOrangeColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLimitReached
                                ? Colors.red.shade50
                                : MandarinaAppTheme.primarySoftColor.withValues(
                                    alpha: 0.7,
                                  ),
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
                        color: MandarinaAppTheme.blueColor.withValues(
                          alpha: 0.7,
                        ),
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
                                color: MandarinaAppTheme.blueColor.withValues(
                                  alpha: 0.4,
                                ),
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
                                    ref
                                        .read(phrasesProvider.notifier)
                                        .addPhrase(text);
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
                                  color: MandarinaAppTheme.blueColor.withValues(
                                    alpha: 0.5,
                                  ),
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
                                            color: MandarinaAppTheme.blueColor,
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
                                          color: MandarinaAppTheme.accentColor,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MandarinaAppTheme.primaryOrangeColor,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final languages = [
          'Español (ES)',
          'English (US)',
          //'Português (BR)',
          //'Français (FR)',
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccionar Idioma',
                  style: mandarinaTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MandarinaAppTheme.blueColor,
                  ),
                ),
                const SizedBox(height: 16),
                ...languages.map((lang) {
                  final isSelected = _selectedLanguage == lang;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      lang,
                      style: mandarinaTextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? MandarinaAppTheme.accentColor
                            : MandarinaAppTheme.blueColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: MandarinaAppTheme.accentColor,
                          )
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
                  style: mandarinaTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MandarinaAppTheme.primaryOrangeColor,
                  ),
                ),
                const SizedBox(height: 16),
                ...days.map((day) {
                  final isSelected = _firstDayOfWeek == day;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      day,
                      style: mandarinaTextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? MandarinaAppTheme.accentColor
                            : MandarinaAppTheme.blueColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: MandarinaAppTheme.accentColor,
                          )
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
    bool isLoading = false;
    bool hasError = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: MandarinaAppTheme.whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
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
                    style: mandarinaTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MandarinaAppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus ideas hacen crecer a Mandarina. Cuéntanos si tuviste algún problema, qué te gustaría mejorar o qué función extra esperas de la app.',
                    style: mandarinaTextStyle(
                      fontSize: 13,
                      color: MandarinaAppTheme.blueColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    enabled: !isLoading,
                    maxLines: 4,
                    onChanged: (val) {
                      if (hasError && val.trim().isNotEmpty) {
                        setBottomSheetState(() {
                          hasError = false;
                        });
                      }
                    },
                    style: mandarinaTextStyle(
                      color: MandarinaAppTheme.primaryOrangeColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu sugerencia aquí...',
                      hintStyle: mandarinaTextStyle(
                        color: MandarinaAppTheme.primaryOrangeColor.withAlpha(
                          100,
                        ),
                      ),
                      errorText: hasError ? 'Escribe tu sugerencia' : null,
                      errorStyle: mandarinaTextStyle(
                        color: MandarinaAppTheme.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: MandarinaAppTheme.whiteBisColor.withAlpha(70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: hasError
                            ? BorderSide(
                                color: MandarinaAppTheme.accentColor,
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: hasError
                              ? Colors.redAccent
                              : MandarinaAppTheme.primaryOrangeColor,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final suggestionText = textController.text.trim();
                              if (suggestionText.isEmpty) {
                                setBottomSheetState(() {
                                  hasError = true;
                                });
                                HapticFeedback.vibrate();
                                return;
                              }

                              setBottomSheetState(() {
                                isLoading = true;
                              });

                              try {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                final email = currentUser?.email ?? 'anonymous';

                                await Future.wait([
                                  FirebaseFirestore.instance
                                      .collection('suggestions')
                                      .add({
                                        'message': suggestionText,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                        'email': email,
                                      }),
                                  Future.delayed(const Duration(seconds: 1)),
                                ]);

                                HapticFeedback.lightImpact();

                                if (bottomSheetContext.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                }

                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      backgroundColor:
                                          MandarinaAppTheme.whiteColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      title: Text(
                                        '¡Gracias!',
                                        style: mandarinaTextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: MandarinaAppTheme.primaryColor,
                                        ),
                                      ),
                                      content: Text(
                                        '¡Gracias por tu sugerencia! La hemos recibido con éxito.',
                                        style: mandarinaTextStyle(
                                          color: MandarinaAppTheme.blueColor,
                                          height: 1.4,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: MandarinaAppTheme
                                                .primaryOrangeColor,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'continuar',
                                            style: mandarinaTextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  MandarinaAppTheme.whiteColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                setBottomSheetState(() {
                                  isLoading = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al enviar la sugerencia: $e',
                                        style: mandarinaTextStyle(
                                          color: MandarinaAppTheme.whiteColor,
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom +
                                            90,
                                        left: 24,
                                        right: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MandarinaAppTheme.primaryOrangeColor,
                        disabledBackgroundColor: MandarinaAppTheme
                            .primaryOrangeColor
                            .withAlpha(150),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: MandarinaAppTheme.whiteColor,
                              ),
                            )
                          : Text(
                              'Enviar sugerencia',
                              style: mandarinaTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: MandarinaAppTheme.whiteColor,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
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
              Image.asset(
                'assets/images/logo_naranja.png',
                scale: 5,
                //opacity: const AlwaysStoppedAnimation<double>(0.2),
              ),
              const SizedBox(height: 10),
              Text(
                'Mandarina',
                style: mandarinaTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MandarinaAppTheme.primaryOrangeColor,
                ),
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
                      child: Divider(
                        color: MandarinaAppTheme.primarySoftColor,
                        height: 1,
                      ),
                    ),
                    _buildAboutRow('Firmware', 'v0.0.0-beta'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        color: MandarinaAppTheme.primarySoftColor,
                        height: 1,
                      ),
                    ),
                    _buildAboutRow('Hardware', 'Revision C'),
                  ],
                ),
              ),
              /*
              const SizedBox(height: 24),
              Text(
                'Diseñada para potenciar tu\nespacio de trabajo.',
                textAlign: TextAlign.center,
                style: mandarinaTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MandarinaAppTheme.primaryColor,
                ),
              ),
              */
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: mandarinaTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MandarinaAppTheme.primaryOrangeColor,
                  ),
                ),
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
        Text(
          label,
          style: mandarinaTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: MandarinaAppTheme.primaryOrangeColor,
          ),
        ),
        Text(
          value,
          style: mandarinaTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: MandarinaAppTheme.primaryOrangeColor,
          ),
        ),
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
  final String timerSound;
  final double timerVolume;

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
  final VoidCallback? onTimerSoundPressed;
  final ValueChanged<double>? onTimerVolumeChanged;
  final ValueChanged<double>? onTimerVolumeChangeEnd;

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
    this.timerSound = 'bell_sound',
    this.timerVolume = 0.8,
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
    this.onTimerSoundPressed,
    this.onTimerVolumeChanged,
    this.onTimerVolumeChangeEnd,
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
        backgroundColor: MandarinaAppTheme
            .backgroundSettingsColor, //primaryOrangeColor.withAlpha(100),
        drawer: const DrawerMenu(currentScreen: 'Ajustes'),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- PREMIUM APPBAR ---
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              floating: true,
              //snap: true,
              pinned: false,
              iconTheme: const IconThemeData(
                color: MandarinaAppTheme.whiteColor,
              ),
              title: Image.asset('assets/images/logo_blanco.png', scale: 18),
              centerTitle: true,
              elevation: 0,
              backgroundColor: MandarinaAppTheme.backgroundSettingsColor,
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(
                    Icons.menu,
                    color: MandarinaAppTheme.blueColor,
                  ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ==========================================
                  // BLOQUE 1: Ajustes Generales
                  // ==========================================
                  _buildSectionHeader('Ajustes Generales'),
                  MandarinaCard(
                    children: [
                      /*
                      MandarinaListTile(
                        icon: Icons.app_blocking_rounded,
                        title: 'Lista de apps permitidas',
                        subtitle: 'Elige qué apps puedes abrir en tus focos',
                        onTap: onManageAllowedAppsPressed,
                      ),
                      const MandarinaDivider(),
                      */
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
                      const MandarinaDivider(),
                      MandarinaListTile(
                        icon: Icons.music_note_rounded,
                        title: 'Sonido de fin de temporizador',
                        subtitle:
                            timerSoundOptions[timerSound] ?? 'Campana Clásica',
                        onTap: onTimerSoundPressed,
                      ),
                      const MandarinaDivider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 16.0,
                              bottom: 4.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: MandarinaAppTheme
                                            .primarySoftColor
                                            .withValues(alpha: 0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.volume_up_rounded,
                                        color: MandarinaAppTheme
                                            .primaryOrangeColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Volumen de Alarma',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: MandarinaAppTheme.blueColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${(timerVolume * 100).round()}%',
                                  style: mandarinaTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: MandarinaAppTheme.primaryOrangeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 68.0,
                              right: 24.0,
                              bottom: 16.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.volume_down_rounded,
                                  size: 16,
                                  color: MandarinaAppTheme.blueColor,
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 4,
                                      activeTrackColor:
                                          MandarinaAppTheme.primaryOrangeColor,
                                      inactiveTrackColor: MandarinaAppTheme
                                          .primaryOrangeColor
                                          .withValues(alpha: 0.2),
                                      thumbColor:
                                          MandarinaAppTheme.primaryOrangeColor,
                                      overlayColor: MandarinaAppTheme
                                          .primaryOrangeColor
                                          .withAlpha(20),
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 7,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 16,
                                          ),
                                    ),
                                    child: Slider(
                                      value: timerVolume.clamp(0.0, 1.0),
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: onTimerVolumeChanged,
                                      onChangeEnd: onTimerVolumeChangeEnd,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.volume_up_rounded,
                                  size: 16,
                                  color: MandarinaAppTheme.primaryOrangeColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  /*
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
                            ? MandarinaAppTheme.primarySoftColor
                            : MandarinaAppTheme.whiteColor,
                        iconColor: petConnected
                            ? MandarinaAppTheme.primaryOrangeColor
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.6,
                              ),
                        title: 'Mandarina PET',
                        subtitle: petConnected
                            ? 'Dispositivo conectado'
                            : 'Desconectado',
                        onTap: onPetConnectionDetailsPressed,
                        trailing: petConnected
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BatteryIndicator(level: petBatteryLevel),
                                  const SizedBox(width: 8),
                                  const FaIcon(
                                    FontAwesomeIcons
                                        .chevronRight, //Icons.chevron_right_rounded,
                                    color: MandarinaAppTheme.blueColor,
                                    size: 12,
                                  ),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
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
                              padding: const EdgeInsets.only(
                                left: 68.0,
                                right: 24.0,
                                bottom: 20.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      const Icon(
                                        Icons.wb_sunny_outlined,
                                        size: 16,
                                        color: MandarinaAppTheme.blueColor,
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 4,
                                            activeTrackColor:
                                                MandarinaAppTheme.accentColor,
                                            inactiveTrackColor:
                                                MandarinaAppTheme
                                                    .primaryOrangeColor
                                                    .withValues(alpha: 0.2),
                                            thumbColor:
                                                MandarinaAppTheme.accentColor,
                                            overlayColor: MandarinaAppTheme
                                                .accentColor
                                                .withAlpha(20),
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                  enabledThumbRadius: 7,
                                                ),
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                                  overlayRadius: 16,
                                                ),
                                          ),
                                          child: Slider(
                                            value: petRgbBrightness,
                                            onChanged:
                                                onPetRgbBrightnessChanged,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.wb_sunny_rounded,
                                        size: 16,
                                        color: MandarinaAppTheme.accentColor,
                                      ),
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
                        subtitle:
                            'Alertas físicas en tonos divertidos de 8-bit',
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

                  */
                  //const SizedBox(height: 24),

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
                        subtitle:
                            'Documentación oficial e información del proyecto',
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
          //Image.asset('assets/images/logo_blanco.png', scale: 24),
          //const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: MandarinaAppTheme.blueColor,
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
        color: MandarinaAppTheme.whiteColor,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: MandarinaAppTheme.darkBlueColor.withAlpha(40),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
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
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            // High-end rounded circle container for the icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MandarinaAppTheme.primarySoftColor.withValues(
                  alpha: 0.7,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: MandarinaAppTheme.primaryOrangeColor,
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
                      color: MandarinaAppTheme.blueColor,
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
            trailing ??
                const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: MandarinaAppTheme.blueColor,
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
              color: MandarinaAppTheme.primarySoftColor.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: MandarinaAppTheme.primaryOrangeColor,
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
                    color: MandarinaAppTheme.blueBisColor,
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
            activeThumbColor: MandarinaAppTheme.primaryOrangeColor,
            activeTrackColor: MandarinaAppTheme.primarySoftColor.withValues(
              alpha: 0.8,
            ),
            inactiveThumbColor: MandarinaAppTheme.blueColor,
            inactiveTrackColor: MandarinaAppTheme.blueColor.withValues(
              alpha: 0.05,
            ),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return MandarinaAppTheme.primaryOrangeColor.withValues(
                  alpha: 0.1,
                );
              }
              return MandarinaAppTheme.blueColor.withValues(alpha: 0.1);
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
        color: MandarinaAppTheme.primarySoftColor,
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
      batteryColor = const Color(0xFF43A047);
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
              border: Border.all(
                color: batteryColor.withOpacity(0.8),
                width: 1.5,
              ),
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
