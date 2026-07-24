import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';


class PomoNotifier extends Notifier<PomoState> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime? _targetEndTime;
  Timer? _timer;
  Timer? _cancelTimer;
  Timer? _holdingProgressTimer;
  bool _justCancelled = false;

  @override
  PomoState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
      _cancelTimer?.cancel();
      _holdingProgressTimer?.cancel();
      _audioPlayer.dispose();
    });

    // Precargar la fuente de audio configurada
    preloadTimerSound();

    return PomoState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppResumed();
    }
  }

  void _checkAppResumed() {
    if (!state.isRunning || _targetEndTime == null) return;
    final now = DateTime.now();
    final remainingSeconds = _targetEndTime!.difference(now).inSeconds;

    if (remainingSeconds <= 0) {
      _onTimerFinished();
    } else {
      state = state.copyWith(focusedTime: remainingSeconds.toDouble());
    }
  }

  Future<void> _configureAudioContextAndVolume([double? volume]) async {
    final profile = ref.read(profileProvider).profile;
    final timerVolume = volume ?? profile?.timerVolume ?? 0.8;
    try {
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
        ),
      );
      await _audioPlayer.setVolume(timerVolume);
    } catch (_) {}
  }

  Future<void> playTimerEndSound() async {
    final profile = ref.read(profileProvider).profile;
    final timerSound = profile?.timerSound ?? 'bell_sound';
    final timerVolume = profile?.timerVolume ?? 0.8;
    try {
      await _configureAudioContextAndVolume(timerVolume);
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$timerSound.mp3'));
    } catch (_) {}
  }

  Future<void> preloadTimerSound([String? soundName, double? volume]) async {
    final profile = ref.read(profileProvider).profile;
    final timerSound = soundName ?? profile?.timerSound ?? 'bell_sound';
    final timerVolume = volume ?? profile?.timerVolume ?? 0.8;
    try {
      await _configureAudioContextAndVolume(timerVolume);
      await _audioPlayer.setSource(AssetSource('audio/$timerSound.mp3'));
    } catch (_) {}
  }

  Future<void> playPreviewSound([String? soundName, double? volume]) async {
    final profile = ref.read(profileProvider).profile;
    final targetSound = soundName ?? profile?.timerSound ?? 'bell_sound';
    final targetVolume = volume ?? profile?.timerVolume ?? 0.8;
    try {
      await _configureAudioContextAndVolume(targetVolume);
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$targetSound.mp3'));
    } catch (_) {}
  }

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

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    final durationSeconds = state.focusedTime.toInt();
    _targetEndTime = DateTime.now().add(Duration(seconds: durationSeconds));

    state = state.copyWith(
      isRunning: true,
      initialFocusedTime: state.focusedTime,
    );

    _timer?.cancel();
    _timer = Timer.periodic(
      oneSecond,
      (Timer timer) {
        _tick();
      },
    );
  }

  void _tick() {
    if (_targetEndTime == null) return;
    final now = DateTime.now();
    final remainingSeconds = _targetEndTime!.difference(now).inSeconds;

    if (remainingSeconds <= 0) {
      _onTimerFinished();
    } else {
      state = state.copyWith(focusedTime: remainingSeconds.toDouble());
    }
  }

  void _onTimerFinished() {
    _stopTimer();
    incrementSesionesCompletadas();
    resetTimer();
    playTimerEndSound();
  }

  void _stopTimer() {
    _timer?.cancel();
    _targetEndTime = null;
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _stopTimer();
    state = state.copyWith(
      focusedTime: 1500.0,
      initialFocusedTime: 1500.0,
    );
  }

  void startCancelCountdown(){
    _holdingProgressTimer?.cancel();
    _justCancelled = false;

    state = state.copyWith(holdingProgress: 0.0);

    const int tickIntervalMs = 30;
    double nextProgress = 0.0;

    _holdingProgressTimer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer){
      nextProgress += tickIntervalMs / 1000.0;
      if(nextProgress>= 1.0){
        timer.cancel();
        _justCancelled = true;
        state = state.copyWith(holdingProgress: 0.0);
        resetTimer();
      }
      else{
        state = state.copyWith(holdingProgress: nextProgress);
      }
    });
  }

  void stopCancelCoundown(){
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
    if (state.isRunning) return;

    final isStudyOrWork = state.currentTask.title == 'Estudio' || state.currentTask.title == 'Trabajo';
    final isRest = state.currentTask.title == 'Descanso';

    if (isStudyOrWork) {
      const int step = 300;
      double roundedSeconds = (seconds / step).roundToDouble() * step;
      if (roundedSeconds < 1200) roundedSeconds = 1200;
      if (roundedSeconds > 3600) roundedSeconds = 3600;
      state = state.copyWith(focusedTime: roundedSeconds, initialFocusedTime: roundedSeconds);
    } else if (isRest) {
      const int step = 300;
      double roundedSeconds = (seconds / step).roundToDouble() * step;
      if (roundedSeconds < 300) roundedSeconds = 300;
      if (roundedSeconds > 1800) roundedSeconds = 1800;
      state = state.copyWith(focusedTime: roundedSeconds, initialFocusedTime: roundedSeconds);
    } else {
      const int step = 300;
      double roundedSeconds = (seconds / step).roundToDouble() * step;
      if (roundedSeconds < 300) roundedSeconds = 300;
      if (roundedSeconds > 7200) roundedSeconds = 7200;
      state = state.copyWith(focusedTime: roundedSeconds, initialFocusedTime: roundedSeconds);
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