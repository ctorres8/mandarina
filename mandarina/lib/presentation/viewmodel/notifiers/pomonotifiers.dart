import 'dart:async';

//import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';


class PomoNotifier extends Notifier<PomoState>{
  @override
  PomoState build() {
    // TODO: implement build
    ref.onDispose(() {
      _timer?.cancel();
      _cancelTimer?.cancel();
      _holdingProgressTimer?.cancel();
    }); // Limpio el timer al cerrar el notifier (o la app)
    return PomoState();
  }

  Timer? _timer;
  Timer? _cancelTimer;
  Timer? _holdingProgressTimer;
  bool _justCancelled = false;

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

  void runTimer(){
    if(_justCancelled){
      _justCancelled = false;
      return;
    }

    if(state.isRunning) return;

    _startTimer();
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
          incrementSesionesCompletadas(); // Incrementa sesiones completadas al finalizar con éxito
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

  void startCancelCountdown(){
    //_cancelTimer?.cancel(); // Cancelo cualquier instancia huerfana previa
    _holdingProgressTimer?.cancel();
    _justCancelled = false;

    /*
    _cancelTimer = Timer(const Duration(seconds: 1),(){
      _justCancelled = true;
      _holdingProgressTimer?.cancel();
      resetTimer();
    }); // Luego de 1 segundo reinicia el cronómetro
    */
    state = state.copyWith(holdingProgress: 0.0);

    const int tickIntervalMs = 30;
    double nextProgress = 0.0;

    _holdingProgressTimer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer){
      nextProgress += tickIntervalMs / 1000.0;
      if(nextProgress>= 1.0){
        timer.cancel();
        _justCancelled = true;
        state = state.copyWith(holdingProgress: 0.0); //limpio la barra de carga
        resetTimer(); //reseteo el timer
      }
      else{
        state = state.copyWith(holdingProgress: nextProgress);
      }
    });
  }

  void stopCancelCoundown(){
    // Se ejecuta si se levanta el dedo antes de cumplir el tiempo de cancelación (1 segundo)
    /*
    if(_cancelTimer != null && _cancelTimer!.isActive){
      _cancelTimer!.cancel();
    }
    */
    if(_holdingProgressTimer != null && _holdingProgressTimer!.isActive)
    {
      _holdingProgressTimer!.cancel();
    }
    state = state.copyWith(holdingProgress: 0.0);
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

  void incrementSesionesCompletadas() {
    state = state.copyWith(sesionesCompletadas: state.sesionesCompletadas + 1);
  }

  void setTime(double seconds) {
    if (state.isRunning) return; // No permitir cambios si está corriendo

    final isStudyOrWork = state.currentTask.title == 'Estudio' || state.currentTask.title == 'Trabajo';
    final isRest = state.currentTask.title == 'Descanso';

    if (isStudyOrWork) {
      // Rango permitido estrictamente 20-60 minutos con saltos fijos de 5 minutos (300 segundos)
      const int step = 300;
      double roundedSeconds = (seconds / step).roundToDouble() * step;
      if (roundedSeconds < 1200) roundedSeconds = 1200; // Mínimo 20 minutos
      if (roundedSeconds > 3600) roundedSeconds = 3600; // Máximo 60 minutos
      state = state.copyWith(focusedTime: roundedSeconds);
    } else if (isRest) {
      // Rango permitido para descanso 5-30 minutos con saltos fijos de 5 minutos
      const int step = 300;
      double roundedSeconds = (seconds / step).roundToDouble() * step;
      if (roundedSeconds < 300) roundedSeconds = 300; // Mínimo 5 minutos
      if (roundedSeconds > 1800) roundedSeconds = 1800; // Máximo 30 minutos
      state = state.copyWith(focusedTime: roundedSeconds);
    } else {
      // Deporte u otros
      const int step = 300;
      double roundedSeconds = (seconds / step).roundToDouble() * step;
      if (roundedSeconds < 300) roundedSeconds = 300;
      if (roundedSeconds > 7200) roundedSeconds = 7200;
      state = state.copyWith(focusedTime: roundedSeconds);
    }
  }



  void setTimerOnOff (bool stateTimer)
  {
    state=state.copyWith(isRunning: stateTimer);
  }

  void setSessionsCount(int count) {
    state = state.copyWith(
      sessionsCount: count,
      sesionesTotales: count,
      sesionesCompletadas: 0,
    );
  }

  void setSportRoutine(String? routine) {
    state = state.copyWith(sportRoutine: routine);
  }
}