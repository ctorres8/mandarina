import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/pomonotifiers.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';
import 'package:mandarina/presentation/viewmodel/state/sport_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/sport_notifier.dart';
import 'package:mandarina/presentation/widgets/tag_selector.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/phrases_notifier.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const name = 'home_screen';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final PomoState pomoState = ref.watch(pomoProvider);
    final PomoNotifier pomoNotifier = ref.read(pomoProvider.notifier);
    final bool isSport = pomoState.currentTask.title == 'Deporte';
    final sportState = ref.watch(sportProvider);
    final sportNotifier = ref.read(sportProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            MandarinaAppTheme.primaryOrangeColor,
            MandarinaAppTheme.primaryColor,

            //MandarinaAppTheme.primaryOrangeColor,
          ],
          stops: const [0.1, 0.7],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, //MandarinaAppTheme.primaryColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: MandarinaAppTheme.whiteColor),
          title: Image.asset('assets/images/logo_blanco.png', scale: 18),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        drawer: const DrawerMenu(currentScreen: 'Inicio'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 16.0,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Frase Motivacional flotante/sutil (puramente transparente)
                  Consumer(
                    builder: (context, ref, child) {
                      final phrase = ref.watch(randomPhraseProvider);
                      if (phrase.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          top: 4.0,
                          bottom: 4.0,
                        ),
                        child: Text(
                          phrase,
                          textAlign: TextAlign.center,
                          style: mandarinaTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MandarinaAppTheme.whiteColor.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(flex: 1), // Espaciador flexible
                  const SizedBox(height: 6),
                  //Cronometro General
                  _cronometer(
                    isSport: isSport,
                    pomoState: pomoState,
                    pomoNotifier: pomoNotifier,
                    sportState: sportState,
                    sportNotifier: sportNotifier,
                  ),

                  const Spacer(flex: 1), // Espaciador flexible
                  const SizedBox(height: 8),

                  _statsRow(),

                  const Spacer(flex: 1), // Espaciador flexible
                  // Tiempo (texto) envuelto en un FittedBox para que no rompa el ancho total
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isSport
                          ? '${sportState.remainingSeconds}s'
                          : ref
                                .watch(pomoProvider.notifier)
                                .formatTime(), //Tiempo en String
                      style: mandarinaTextStyle(
                        color: MandarinaAppTheme.whiteBisColor,
                        fontSize: 100,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //const SizedBox(height: 30,),
                  const Spacer(flex: 1), // Espaciador flexible
                  // Play/Stop Button
                  _playButton(
                    isSport: isSport,
                    pomoNotifier: pomoNotifier,
                    pomoState: pomoState,
                    sportNotifier: sportNotifier,
                    sportState: sportState,
                  ),

                  // Espacio rigido controlado para el texto explicativo
                  const SizedBox(height: 6),
                  //const Spacer(flex: 2,),

                  //Leyenda instructiva para parar el cronometro
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSport
                        ? (sportState.isTimerRunning ? 1.0 : 0.0)
                        : (pomoState.isRunning ? 1.0 : 0.0),
                    child: Text(
                      "Mantén presionado 1s para abortar.",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: MandarinaAppTheme.whiteColor.withValues(
                          alpha: 0.8,
                        ),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _playButton({
    required bool isSport,
    required PomoNotifier pomoNotifier,
    required PomoState pomoState,
    required SportNotifier sportNotifier,
    required SportState sportState,
  }) {
    final bool isRunning = isSport
        ? sportState.isTimerRunning
        : pomoState.isRunning;
    final double progress = isSport
        ? sportState.holdingProgress
        : pomoState.holdingProgress;

    return GestureDetector(
      onTap: () => isSport ? sportNotifier.runTimer() : pomoNotifier.runTimer(),
      onTapDown: (_) => isSport
          ? sportNotifier.startCancelCountdown()
          : pomoNotifier.startCancelCountdown(),
      onTapUp: (_) => isSport
          ? sportNotifier.stopCancelCountdown()
          : pomoNotifier.stopCancelCoundown(),
      onTapCancel: () => isSport
          ? sportNotifier.stopCancelCountdown()
          : pomoNotifier.stopCancelCoundown(),
      child: Container(
        width: 100, //280,
        height: 100, //60,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MandarinaAppTheme.whiteBisColor,
          //borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 100 * progress,
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.accentColor.withValues(alpha: 0.7),
                ),
              ),
            ),
            Center(
              child: Icon(
                isRunning ? Icons.close : Icons.play_arrow_rounded,
                color: MandarinaAppTheme.primaryOrangeColor,
                size: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cronometer({
    required bool isSport,
    required PomoState pomoState,
    required PomoNotifier pomoNotifier,
    required SportState sportState,
    required SportNotifier sportNotifier,
  }) {
    final String currentTaskTitle = pomoState.currentTask.title;
    final bool isStudyOrWork =
        currentTaskTitle == 'Estudio' || currentTaskTitle == 'Trabajo';
    final bool isRest = currentTaskTitle == 'Descanso';

    final double sliderMin = isSport
        ? 0.0
        : (pomoState.isRunning
              ? 0.0
              : (isStudyOrWork ? 1200 : (isRest ? 300 : 300)));

    final double sliderMax = isSport
        ? (sportState.isWorkInterval
                  ? sportState.workSeconds
                  : sportState.breakSeconds)
              .toDouble()
        : (pomoState.isRunning
              ? pomoState.initialFocusedTime
              : (isStudyOrWork ? 3600 : (isRest ? 1800 : 7200)));

    final double initialValue = isSport
        ? sportState.remainingSeconds.clamp(0, sliderMax.toInt()).toDouble()
        : (pomoState.isRunning
              ? pomoState.focusedTime.clamp(0.0, pomoState.initialFocusedTime)
              : pomoState.focusedTime.clamp(sliderMin, sliderMax));

    final String normalizedTaskTitle = pomoState.currentTask.title
        .trim()
        .toLowerCase();
    String lottieAsset = 'assets/lotties/mandarina_loading.json';

    if (normalizedTaskTitle == 'estudio' ||
        normalizedTaskTitle == 'estudiar' ||
        normalizedTaskTitle == 'estudiando') {
      lottieAsset = 'assets/lotties/studying.json';
    } else if (normalizedTaskTitle == 'trabajo' ||
        normalizedTaskTitle == 'trabajar' ||
        normalizedTaskTitle == 'trabajando') {
      lottieAsset = 'assets/lotties/freelancer_working.json';
    } else if (normalizedTaskTitle == 'deporte') {
      lottieAsset = isSport
          ? (sportState.isWorkInterval
                ? 'assets/lotties/gym_boy1.json'
                : 'assets/lotties/leisure_girl1.json')
          : 'assets/lotties/gym_boy1.json';
    } else if (normalizedTaskTitle == 'descanso' ||
        normalizedTaskTitle == 'descansar' ||
        normalizedTaskTitle == 'descansando') {
      lottieAsset = 'assets/lotties/leisure_girl1.json';
    } else if (normalizedTaskTitle == 'ocio') {
      lottieAsset = 'assets/lotties/leisure_girl1.json';
    }

    return SizedBox(
      //Timer
      width: 280,
      height: 280,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MandarinaAppTheme.whiteBisColor,
            ),
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
            ),
          ),
          SleekCircularSlider(
            initialValue: initialValue,
            min: sliderMin,
            max: sliderMax <= sliderMin ? sliderMin + 1 : sliderMax + 1,
            appearance: CircularSliderAppearance(
              spinnerMode: false,
              animationEnabled:
                  !pomoState.isRunning && !sportState.isTimerRunning,
              customWidths: CustomSliderWidths(
                trackWidth: 6,
                handlerSize: 16,
                progressBarWidth: 14,
                shadowWidth: 0,
              ),
              customColors: CustomSliderColors(
                trackColor: MandarinaAppTheme.whiteBisColor.withValues(
                  alpha: 0.2,
                ),
                progressBarColor: MandarinaAppTheme.secondaryColor,
                dotColor: MandarinaAppTheme.whiteBisColor,
                hideShadow: true,
              ),
              size: 280,
              angleRange: 360,
              startAngle: 270,
            ),
            onChange: isSport
                ? null
                : (newValue) {
                    double x = 0;
                    if (!pomoState.timerIsRunning) {
                      if (isStudyOrWork || isRest) {
                        x = (newValue / 300).roundToDouble() * 300;
                      } else {
                        x = (newValue / 60).roundToDouble() * 60;
                      }
                      x = x.clamp(sliderMin, sliderMax);
                    } else {
                      x = newValue;
                    }
                    pomoNotifier.setTime(x);
                  },
            innerWidget: (double newValue) {
              final bool isRunning = isSport
                  ? sportState.isTimerRunning
                  : pomoState.isRunning;

              return Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    lottieAsset,
                    repeat: true,
                    animate: isRunning,
                  ),
                ),
              );
            },
          ),
          if (isSport || pomoState.isRunning)
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 280,
                height: 280,
                color: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Consumer(
      builder: (context, ref, _) {
        final isSport = ref.watch(
          pomoProvider.select((s) => s.currentTask.title == 'Deporte'),
        );
        final sportRoutine = ref.watch(
          pomoProvider.select((s) => s.sportRoutine),
        );
        final bool showSportRoutine = isSport && sportRoutine != null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Circunferencia 1: Modo / Tag (Reactivo únicamente a cambios en la tarea actual)
              _circleStat(
                onTap: () {
                  TagSelectorBottomSheet.show(context);
                },
                child: Consumer(
                  builder: (context, ref, _) {
                    final currentTask = ref.watch(
                      pomoProvider.select((s) => s.currentTask),
                    );
                    final isSportMode = currentTask.title == 'Deporte';
                    if (isSportMode) {
                      final isWorkInterval = ref.watch(
                        sportProvider.select((s) => s.isWorkInterval),
                      );
                      return _statItem(
                        icon: isWorkInterval
                            ? Icons.directions_run_rounded
                            : Icons.airline_seat_recline_extra_rounded,
                        value: isWorkInterval ? 'Deporte' : 'Descanso',
                      );
                    }
                    return _statItem(
                      icon: currentTask.icon,
                      value: currentTask.title,
                    );
                  },
                ),
              ),
              // Circunferencia 2: Sesiones / Series (Reactivo únicamente al conteo de sesiones completadas y totales)
              _circleStat(
                onTap: () {
                  TagSelectorBottomSheet.show(context);
                },
                child: Consumer(
                  builder: (context, ref, _) {
                    final isSportTask = ref.watch(
                      pomoProvider.select(
                        (s) => s.currentTask.title == 'Deporte',
                      ),
                    );
                    if (isSportTask) {
                      final sportSeriesCompletadas = ref.watch(
                        sportProvider.select((s) => s.seriesCompletadas),
                      );
                      final sportSeriesTotales = ref.watch(
                        sportProvider.select((s) => s.seriesTotales),
                      );
                      return _statItem(
                        icon: Icons.loop_rounded,
                        value: '$sportSeriesCompletadas/$sportSeriesTotales',
                      );
                    } else {
                      final sesionesCompletadas = ref.watch(
                        pomoProvider.select((s) => s.sesionesCompletadas),
                      );
                      final sesionesTotales = ref.watch(
                        pomoProvider.select((s) => s.sesionesTotales),
                      );
                      return _statItem(
                        icon: Icons.cached_rounded,
                        value: '$sesionesCompletadas/$sesionesTotales',
                      );
                    }
                  },
                ),
              ),
              // Circunferencia 3: HIIT Routine (Solo si es deporte y hay rutina configurada)
              if (showSportRoutine)
                _circleStat(
                  onTap: () {
                    TagSelectorBottomSheet.show(context);
                  },
                  child: _statItem(
                    icon: Icons.flash_on_rounded,
                    value: sportRoutine.split(' ').first,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleStat({required Widget child, VoidCallback? onTap}) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MandarinaAppTheme.whiteBisColor.withValues(alpha: 0.12),
        border: Border.all(
          color: MandarinaAppTheme.whiteBisColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(45),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Padding(padding: const EdgeInsets.all(6.0), child: child),
          ),
        ),
      ),
    );
  }

  Widget _statItem({required IconData icon, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: MandarinaAppTheme.whiteBisColor.withValues(alpha: 0.75),
        ),
        /*
        const SizedBox(height: 3),
        Text(
          label,
          style: mandarinaTextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: MandarinaAppTheme.whiteBisColor.withValues(alpha: 0.75),
          ),
        ),
        */
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: mandarinaTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: MandarinaAppTheme.whiteBisColor,
            ),
          ),
        ),
      ],
    );
  }
}
