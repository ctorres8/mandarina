import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/pomonotifiers.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';
import 'package:mandarina/presentation/widgets/bottomSheet.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class HomeScreen extends ConsumerStatefulWidget{
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

    return Scaffold(
      backgroundColor: MandarinaAppTheme.primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MandarinaAppTheme.whiteColor),
        title: Image.asset('assets/images/logo_blanco.png',scale:18,),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 70,),
              _taskIcon(),
              const SizedBox(height: 30,),
              _cronometer(pomoState,pomoNotifier),
              const SizedBox(height: 30,),
              Text(
                ref.watch(pomoProvider.notifier).formatTime(), //Tiempo en String
                style: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.whiteColor,
                  fontSize: 108,
                  fontWeight: FontWeight.w500
                )
              ),
              const SizedBox(height: 30,),
              ElevatedButton(
                onPressed: () => pomoNotifier.toggleTimer(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pomoState.isRunning? MandarinaAppTheme.accentColor : MandarinaAppTheme.secondaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: Size(260, 60)
                ),
                child: Text(
                  pomoState.isRunning? "STOP!":"START!",
                  style: GoogleFonts.quicksand(
                    fontSize: 35, 
                    fontWeight: FontWeight.w700,
                    color: pomoState.isRunning? MandarinaAppTheme.whiteColor : MandarinaAppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

Widget _taskIcon() {

  return Container(
    height: 60,
    width: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        width: 2,
        color: MandarinaAppTheme.secondaryColor,
      ),
      color: MandarinaAppTheme.secondaryColor,
    ),
    child: IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => PomoSettingsSheet(),
        );
      },
      icon: Icon(ref.read(pomoProvider).actualActivityIcon, color: MandarinaAppTheme.accentColor),
    ),
  );
}


  Widget _cronometer(PomoState pomoState, PomoNotifier pomoNotifier){
    //int currentValuePomo = 25;
    //final PomoState pomoState = ref.watch(pomoProvider);
    //final PomoNotifier pomoNotifier = ref.read(pomoProvider.notifier);
    return SizedBox( //Timer
      width: 280, height: 280,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: 270, height: 270,
            decoration: const BoxDecoration(shape: BoxShape.circle,color: Color.fromRGBO(251, 226, 187,0.95)),
          ),
          Container(
            width: 235, height: 235,      
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withOpacity(0.02)),
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
                trackWidth: 12,
                handlerSize: 15,
                progressBarWidth: 15,
                shadowWidth: 0,
              ),
              customColors: CustomSliderColors(
                trackColor: MandarinaAppTheme.secondaryColor,
                progressBarColor: MandarinaAppTheme.accentColor,
                hideShadow: true,
              ),
              size: 280,
              angleRange: 360,
              startAngle: 270,
            ),
            onChange: (newValue) {
              double x=0;
              //if(!isRunning){ 
              if(!pomoState.timerIsRunning){ 
                //x = (newValue ~/300).toDouble()*300;
                x = (newValue ~/60).toDouble()*60;
              }
              else{
                x=newValue;
              }

              pomoNotifier.setTime(x);
                          
              //_timer.cancel();
            },
            innerWidget: (double newValue){
              return Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.asset('assets/lotties/studying5.json'),
                )
              );
            },
          ),
          //if(isRunning)GestureDetector(
          if(pomoState.isRunning)
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 280, height: 280,
                color: Colors.transparent,
              ),
            )
        ],
      ),
    );
  }
}


