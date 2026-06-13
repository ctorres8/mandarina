import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/pomonotifiers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/workflow_notifier.dart';
import 'package:mandarina/presentation/viewmodel/state/workflow_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/sport_notifier.dart';
import 'package:mandarina/presentation/viewmodel/state/sport_state.dart';

final pomoProvider = NotifierProvider<PomoNotifier,PomoState>(PomoNotifier.new);
final dynamicCircleSizeProvider = StateProvider<double>((ref) => 60.0); // Provider para controlar la animación del círculo
final workflowProvider = NotifierProvider<WorkflowNotifier, WorkflowState>(WorkflowNotifier.new);
final sportProvider = NotifierProvider<SportNotifier, SportState>(SportNotifier.new);