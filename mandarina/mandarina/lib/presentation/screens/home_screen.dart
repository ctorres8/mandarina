import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/pomonotifiers.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';
import 'package:mandarina/presentation/widgets/tag_selector.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';
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
        drawer: DrawerMenu(),
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
                  const Spacer(flex: 2), // Espaciador flexible
                  //Cronometro General
                  _cronometer(pomoState, pomoNotifier),

                  const Spacer(flex: 1), // Espaciador flexible
                  const SizedBox(height: 20),

                  _statsRow(pomoState),

                  const Spacer(flex: 1), // Espaciador flexible
                  // Tiempo (texto) envuelto en un FittedBox para que no rompa el ancho total
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      ref
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
                  const Spacer(flex: 2), // Espaciador flexible
                  // Play/Stop Button
                  _playButton(pomoNotifier, pomoState),

                  const SizedBox(
                    height: 12,
                  ), // Espacio rigido controlado para el texto explicativo
                  //const Spacer(flex: 2,),

                  //Leyenda instructiva para parar el cronometro
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: pomoState.isRunning ? 1.0 : 0.0,
                    child: Text(
                      "Mantén presionado 1s para abortar el pomodoro.",
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

  GestureDetector _playButton(PomoNotifier pomoNotifier, PomoState pomoState) {
    return GestureDetector(
      onTap: () => pomoNotifier.runTimer(),
      onTapDown: (_) => pomoNotifier.startCancelCountdown(),
      onTapUp: (_) => pomoNotifier.stopCancelCoundown(),
      onTapCancel: () => pomoNotifier.stopCancelCoundown(),
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
                width: 280 * pomoState.holdingProgress,
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.accentColor.withValues(alpha: 0.7),
                ),
              ),
            ),
            Center(
              child: Icon(
                pomoState.isRunning
                    ? Icons.close
                    : Icons
                          .play_arrow_rounded, //FontAwesomeIcons.xmark : FontAwesomeIcons.play,
                color: MandarinaAppTheme.primaryOrangeColor,
                size: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskIcon() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: MandarinaAppTheme.secondaryColor),
        color: MandarinaAppTheme.secondaryColor,
      ),
      child: IconButton(
        onPressed: () {
          TagSelectorBottomSheet.show(context);
        },
        icon: Icon(
          ref.read(pomoProvider).actualActivityIcon,
          color: MandarinaAppTheme.accentColor,
        ),
      ),
    );
  }

  Widget _cronometer(PomoState pomoState, PomoNotifier pomoNotifier) {
    //int currentValuePomo = 25;
    //final PomoState pomoState = ref.watch(pomoProvider);
    //final PomoNotifier pomoNotifier = ref.read(pomoProvider.notifier);
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
              color: MandarinaAppTheme
                  .whiteBisColor, //Color.fromRGBO(251, 226, 187,0.95)
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
            //initialValue: value,
            initialValue: pomoState.focusedTime,
            min: 0,
            max: 7201,
            appearance: CircularSliderAppearance(
              spinnerMode: false,
              customWidths: CustomSliderWidths(
                trackWidth: 6,
                handlerSize: 16,
                progressBarWidth: 14,
                shadowWidth: 0,
              ),
              customColors: CustomSliderColors(
                trackColor: MandarinaAppTheme.whiteBisColor.withValues(
                  alpha: 0.2,
                ), //MandarinaAppTheme.accentColor,
                progressBarColor: MandarinaAppTheme
                    .secondaryColor, //MandarinaAppTheme.accentColor,
                dotColor: MandarinaAppTheme.whiteBisColor,
                hideShadow: true,
              ),
              size: 280,
              angleRange: 360,
              startAngle: 270,
            ),
            onChange: (newValue) {
              double x = 0;
              //if(!isRunning){
              if (!pomoState.timerIsRunning) {
                //x = (newValue ~/300).toDouble()*300;
                x = (newValue ~/ 60).toDouble() * 60;
              } else {
                x = newValue;
              }

              pomoNotifier.setTime(x);

              //_timer.cancel();
            },
            innerWidget: (double newValue) {
              return Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.asset('assets/lotties/studying5.json'),
                ),
              );
            },
          ),
          //if(isRunning)GestureDetector(
          if (pomoState.isRunning)
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

  Widget _statsRow(PomoState pomoState) {
    final bool isSport = pomoState.currentTask.title == 'Deporte';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Circunferencia 1: Modo / Tag
        _circleStat(
          onTap: () {
            TagSelectorBottomSheet.show(context);
          },
          child: _statItem(
            icon: pomoState.actualActivityIcon,
            value: pomoState.actualTaskName,
          ),
        ),
        //const SizedBox(width: 24),
        //const Spacer(flex: 2),
        // Circunferencia 2: Sesiones / Series
        _circleStat(
          onTap: () {
            TagSelectorBottomSheet.show(context);
          },
          child: _statItem(
            icon: isSport ? Icons.loop_rounded : Icons.cached_rounded,
            value: '${pomoState.sessionsCount}',
          ),
        ),
        if (isSport && pomoState.sportRoutine != null) ...[
          //const SizedBox(width: 24),
          //const Spacer(flex: 2),
          // Circunferencia 3: HIIT Routine
          _circleStat(
            onTap: () {
              TagSelectorBottomSheet.show(context);
            },
            child: _statItem(
              icon: Icons.flash_on_rounded,
              value: pomoState.sportRoutine!.split(' ').first,
            ),
          ),
        ],
      ],
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
