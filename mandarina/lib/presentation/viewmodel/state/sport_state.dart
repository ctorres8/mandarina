class SportState {
  final int workSeconds;
  final int breakSeconds;
  final int remainingSeconds;
  final bool isWorkInterval;
  final bool isTimerRunning;
  final double holdingProgress;
  final int seriesTotales;
  final int seriesCompletadas;

  SportState({
    this.workSeconds = 40,
    this.breakSeconds = 20,
    this.remainingSeconds = 40,
    this.isWorkInterval = true,
    this.isTimerRunning = false,
    this.holdingProgress = 0.0,
    this.seriesTotales = 4,
    this.seriesCompletadas = 0,
  });

  SportState copyWith({
    int? workSeconds,
    int? breakSeconds,
    int? remainingSeconds,
    bool? isWorkInterval,
    bool? isTimerRunning,
    double? holdingProgress,
    int? seriesTotales,
    int? seriesCompletadas,
  }) {
    return SportState(
      workSeconds: workSeconds ?? this.workSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isWorkInterval: isWorkInterval ?? this.isWorkInterval,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      holdingProgress: holdingProgress ?? this.holdingProgress,
      seriesTotales: seriesTotales ?? this.seriesTotales,
      seriesCompletadas: seriesCompletadas ?? this.seriesCompletadas,
    );
  }
}
