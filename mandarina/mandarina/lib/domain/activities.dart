import 'package:flutter/cupertino.dart';
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
  Task(1,"Trabajo",CupertinoIcons.briefcase_fill),
  Task(2,"Estudio",CupertinoIcons.book_fill),
  Task(3,"Descanso",CupertinoIcons.zzz),
  Task(4,"Deporte",CupertinoIcons.heart_fill),
  Task(5,"Ocio",CupertinoIcons.tree),
];