import 'dart:async';

//import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';


class PomoNotifier extends Notifier<PomoState>{
  @override
  PomoState build() {
    // TODO: implement build
    ref.onDispose(()=> _timer?.cancel()); // Limpio el timer al cerrar el notifier (o la app)
    return PomoState();
  }

  Timer? _timer;

  /*
  void startStopTimer(){
    if(!state.timerIsRunning){
      startTimer();
    }
    else{
      _timer.cancel();
    }
  }
  */
  void toggleTimer(){
    if(state.isRunning){
      _stopTimer();
    }else{
      _startTimer();
    }
  }

  void _startTimer()
  {
    const oneSecond = Duration(seconds: 1);

    state = state.copyWith(isRunning: true); // pongo el estado como corriendo

    _timer=Timer.periodic(
      oneSecond, 
      (Timer timer){
        if(state.countTimer<=0){
          _stopTimer();
          resetTimer();
          //TODO: Hacer una notificación o sonido de "Terminado"
          //setTimerOnOff(false);
        }
        else{
          state=state.copyWith(focusedTime: state.focusedTime-1); // Decremento el tiempo de focus
        }
      }
    );
  }

  void _stopTimer(){
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer(){
    _stopTimer();
    state=state.copyWith(focusedTime:1500.0); //reseteo con 25 minutos
  }

  // Selecciono la tarea elegida
  void setTask(String nameTask){
    final selectedTask = taskList.firstWhere(
      (t) => t.title == nameTask,
      orElse: () => taskList.first
    );
    state = state.copyWith(currentTask: selectedTask);
  }


  String formatTime(){
    final minutes = (state.focusedTime~/60).toInt().toString().padLeft(2,'0');
    final seconds = (state.focusedTime % 60).toInt().toString().padLeft(2,'0');

    return '$minutes:$seconds';
  }

  void setTime(double seconds) {
    if (state.isRunning) return; // No permitir cambios si está corriendo

    // 1. Definimos el salto (5 minutos = 300 segundos)
    const int step = 300;

    // 2. Redondeamos al múltiplo de 300 más cercano
    // Ejemplo: si el slider manda 740 segundos, (740 / 300) = 2.46 -> round a 2 -> 2 * 300 = 600 seg (10 min)
    double roundedSeconds = (seconds / step).roundToDouble() * step;

    // 3. Validaciones de límites (opcional pero recomendado)
    if (roundedSeconds < 300) roundedSeconds = 300; // Mínimo 5 minutos
    if (roundedSeconds > 7200) roundedSeconds = 7200; // Máximo 120 minutos (2hs)

    state = state.copyWith(focusedTime: roundedSeconds);
  }



  void setTimerOnOff (bool stateTimer)
  {
    state=state.copyWith(isRunning: stateTimer);
  }
}