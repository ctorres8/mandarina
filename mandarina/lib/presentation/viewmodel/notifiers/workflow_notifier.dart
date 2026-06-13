import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/presentation/viewmodel/state/workflow_state.dart';

class WorkflowNotifier extends Notifier<WorkflowState> {
  Timer? _timer;
  DateTime? _lastTickTime;

  Timer? _holdingProgressTimer;

  @override
  WorkflowState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _holdingProgressTimer?.cancel();
    });
    return const WorkflowState();
  }

  void toggleTimer() {
    if (state.status == WorkflowTimerStatus.running) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (state.status == WorkflowTimerStatus.running) return;

    _lastTickTime = DateTime.now();
    state = state.copyWith(status: WorkflowTimerStatus.running);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (state.status != WorkflowTimerStatus.running) {
        timer.cancel();
        return;
      }
      final now = DateTime.now();
      final delta = now.difference(_lastTickTime!);
      _lastTickTime = now;
      state = state.copyWith(
        elapsedDuration: state.elapsedDuration + delta,
      );
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(status: WorkflowTimerStatus.paused);
  }

  WorkflowTask? addCheckpoint() {
    if (state.status != WorkflowTimerStatus.running) return null;

    final currentElapsedSeconds = state.elapsedDuration.inSeconds;
    final sumOfPrevious = state.tasks.fold<int>(0, (sum, t) => sum + t.durationInSeconds);
    final taskDuration = currentElapsedSeconds - sumOfPrevious;
    final actualDuration = taskDuration < 0 ? 0 : taskDuration;

    final newTask = WorkflowTask(
      id: '${DateTime.now().millisecondsSinceEpoch}_${state.tasks.length}',
      name: 'Tarea ${state.tasks.length + 1}',
      durationInSeconds: actualDuration,
    );

    state = state.copyWith(
      tasks: [...state.tasks, newTask],
    );

    return newTask;
  }

  void startHold(VoidCallback onComplete) {
    _holdingProgressTimer?.cancel();
    state = state.copyWith(holdingProgress: 0.0, longPressTriggered: false);

    const int tickIntervalMs = 30;
    // We want the progress bar to complete in exactly 1.0 seconds (1000ms).
    // In each tick of 30ms, the progress increases by 30 / 1000 = 0.03.
    _holdingProgressTimer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer) {
      final nextProgress = state.holdingProgress + (tickIntervalMs / 1000.0);
      if (nextProgress >= 1.0) {
        timer.cancel();
        state = state.copyWith(
          holdingProgress: 0.0,
          status: WorkflowTimerStatus.stopped,
          longPressTriggered: true,
        );
        pauseTimer();
        onComplete();
      } else {
        state = state.copyWith(holdingProgress: nextProgress);
      }
    });
  }

  void cancelHold() {
    _holdingProgressTimer?.cancel();
    state = state.copyWith(holdingProgress: 0.0);
  }

  void clearLongPressTriggered() {
    _holdingProgressTimer?.cancel();
    state = state.copyWith(holdingProgress: 0.0, longPressTriggered: false);
  }

  void updateTaskName(String id, String newName) {
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == id ? t.copyWith(name: newName) : t).toList(),
    );
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _holdingProgressTimer?.cancel();
    _holdingProgressTimer = null;
    state = const WorkflowState();
  }
}
