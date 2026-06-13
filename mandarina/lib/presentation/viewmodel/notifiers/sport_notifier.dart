import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/presentation/viewmodel/state/sport_state.dart';

class SportNotifier extends Notifier<SportState> {
  Timer? _timer;
  Timer? _holdingProgressTimer;
  bool _justCancelled = false;

  @override
  SportState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _holdingProgressTimer?.cancel();
    });
    return SportState();
  }

  void configureRoutine({
    required int workSeconds,
    required int breakSeconds,
    required int seriesTotales,
  }) {
    if (state.isTimerRunning) return;

    state = state.copyWith(
      workSeconds: workSeconds,
      breakSeconds: breakSeconds,
      remainingSeconds: workSeconds,
      isWorkInterval: true,
      seriesTotales: seriesTotales,
      seriesCompletadas: 0,
      holdingProgress: 0.0,
      isTimerRunning: false,
    );
  }

  void toggleTimer() {
    if (state.isTimerRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void runTimer() {
    if (_justCancelled) {
      _justCancelled = false;
      return;
    }
    if (state.isTimerRunning) return;
    startTimer();
  }

  void startTimer() {
    if (state.isTimerRunning) return;

    state = state.copyWith(isTimerRunning: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (state.remainingSeconds > 1) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      state = state.copyWith(remainingSeconds: 0);
      _transitionInterval();
    }
  }

  void _transitionInterval() {
    if (state.isWorkInterval) {
      // Fin del intervalo de trabajo -> Transición automática a descanso
      state = state.copyWith(
        isWorkInterval: false,
        remainingSeconds: state.breakSeconds,
      );
    } else {
      // Fin del intervalo de descanso -> Siguiente round de trabajo o finalizar
      final nextSeries = state.seriesCompletadas + 1;
      if (nextSeries >= state.seriesTotales) {
        // Rutina terminada!
        _timer?.cancel();
        _timer = null;
        state = state.copyWith(
          seriesCompletadas: state.seriesTotales,
          isTimerRunning: false,
          remainingSeconds: 0,
          isWorkInterval: false,
        );
      } else {
        // Siguiente ronda
        state = state.copyWith(
          seriesCompletadas: nextSeries,
          isWorkInterval: true,
          remainingSeconds: state.workSeconds,
        );
      }
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isTimerRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _holdingProgressTimer?.cancel();
    _holdingProgressTimer = null;
    state = state.copyWith(
      remainingSeconds: state.workSeconds,
      isWorkInterval: true,
      isTimerRunning: false,
      seriesCompletadas: 0,
      holdingProgress: 0.0,
    );
  }

  void startCancelCountdown() {
    _holdingProgressTimer?.cancel();
    _justCancelled = false;
    state = state.copyWith(holdingProgress: 0.0);

    const int tickIntervalMs = 30;
    double nextProgress = 0.0;

    _holdingProgressTimer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer) {
      nextProgress += tickIntervalMs / 1000.0;
      if (nextProgress >= 1.0) {
        timer.cancel();
        _justCancelled = true;
        state = state.copyWith(holdingProgress: 0.0);
        resetTimer();
      } else {
        state = state.copyWith(holdingProgress: nextProgress);
      }
    });
  }

  void stopCancelCountdown() {
    _holdingProgressTimer?.cancel();
    state = state.copyWith(holdingProgress: 0.0);
  }
}
