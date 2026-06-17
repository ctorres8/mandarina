import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mandarina/domain/activities.dart';


class PomoState {
  final Task currentTask;
  final Activity activity;
  final double focusedTime;
  final double initialFocusedTime;
  final bool isRunning;
  final double holdingProgress;
  final int sessionsCount;
  final String? sportRoutine;
  final int sesionesCompletadas;
  final int sesionesTotales;

  // Constructor con valores por defecto
  PomoState({
    Task? currentTask,
    this.activity=Activity.work,
    this.focusedTime=1500.0, // 25 minutos en segundos
    double? initialFocusedTime,
    this.isRunning=false,
    this.holdingProgress = 0.0,
    this.sessionsCount = 4,
    this.sportRoutine,
    this.sesionesCompletadas = 0,
    this.sesionesTotales = 4,
  }) : currentTask = currentTask ?? taskList.first,
       initialFocusedTime = initialFocusedTime ?? focusedTime;

  //getters
  bool get timerIsRunning => isRunning;
  IconData get actualActivityIcon => currentTask.icon;
  String get actualTaskName => currentTask.title;
  double get countTimer => focusedTime;

  //CopyWith
  PomoState copyWith({
    Task? currentTask,
    Activity? activity,
    double? focusedTime,
    double? initialFocusedTime,
    bool? isRunning,
    double? holdingProgress,
    int? sessionsCount,
    String? sportRoutine,
    int? sesionesCompletadas,
    int? sesionesTotales,
  }){
    return PomoState(
      currentTask: currentTask ?? this.currentTask,
      activity: activity ?? this.activity,
      focusedTime: focusedTime ?? this.focusedTime,
      initialFocusedTime: initialFocusedTime ?? this.initialFocusedTime,
      isRunning: isRunning ?? this.isRunning,
      holdingProgress: holdingProgress ?? this.holdingProgress,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      sportRoutine: sportRoutine ?? this.sportRoutine,
      sesionesCompletadas: sesionesCompletadas ?? this.sesionesCompletadas,
      sesionesTotales: sesionesTotales ?? this.sesionesTotales,
    );
  }

}