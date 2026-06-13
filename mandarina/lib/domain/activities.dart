import 'package:flutter/material.dart';

enum Activity {
  work,
  study,
  rest,
  leisure,
  gym
}

class Task {
  final int id;
  final String title;
  final IconData icon;

  Task(this.id, this.title, this.icon);
}

List<Task> taskList =[
  Task(1,"Trabajo",Icons.business_center_rounded),
  Task(2,"Estudio",Icons.school_rounded),
  Task(3,"Descanso",Icons.coffee_rounded),
  Task(4,"Deporte",Icons.directions_run_rounded),
  Task(5,"Ocio",Icons.bookmark_rounded),
];