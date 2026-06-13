enum WorkflowTimerStatus {
  running,
  paused,
  stopped,
}

class WorkflowTask {
  final String id;
  final String name;
  final int durationInSeconds;

  const WorkflowTask({
    required this.id,
    required this.name,
    required this.durationInSeconds,
  });

  WorkflowTask copyWith({
    String? id,
    String? name,
    int? durationInSeconds,
  }) {
    return WorkflowTask(
      id: id ?? this.id,
      name: name ?? this.name,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
    );
  }
}

class WorkflowState {
  final WorkflowTimerStatus status;
  final Duration elapsedDuration;
  final List<WorkflowTask> tasks;
  final double holdingProgress;
  final bool longPressTriggered;

  const WorkflowState({
    this.status = WorkflowTimerStatus.stopped,
    this.elapsedDuration = Duration.zero,
    this.tasks = const [],
    this.holdingProgress = 0.0,
    this.longPressTriggered = false,
  });

  bool get isRunning => status == WorkflowTimerStatus.running;

  WorkflowState copyWith({
    WorkflowTimerStatus? status,
    Duration? elapsedDuration,
    List<WorkflowTask>? tasks,
    double? holdingProgress,
    bool? longPressTriggered,
  }) {
    return WorkflowState(
      status: status ?? this.status,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      tasks: tasks ?? this.tasks,
      holdingProgress: holdingProgress ?? this.holdingProgress,
      longPressTriggered: longPressTriggered ?? this.longPressTriggered,
    );
  }
}
