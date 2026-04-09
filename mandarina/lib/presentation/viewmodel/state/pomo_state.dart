import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mandarina/domain/activities.dart';


class PomoState {
  final Task currentTask;
  final Activity activity;
  final double focusedTime;
  final bool isRunning;

  // Constructor con valores por defecto
  PomoState({
    Task? currentTask,
    this.activity=Activity.work,
    this.focusedTime=1500.0, // 25 minutos en segundos
    this.isRunning=false,
  }) : currentTask = currentTask ?? taskList.first;

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
    bool? isRunning
  }){
    return PomoState(
      currentTask: currentTask ?? this.currentTask,
      activity: activity ?? this.activity,
      focusedTime: focusedTime ?? this.focusedTime,
      isRunning: isRunning ?? this.isRunning,
    );
  }

}