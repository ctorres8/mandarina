import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/locale_notifier.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/pomonotifiers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/workflow_notifier.dart';
import 'package:mandarina/presentation/viewmodel/state/workflow_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/sport_notifier.dart';
import 'package:mandarina/presentation/viewmodel/state/sport_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/profile_notifier.dart';
import 'package:mandarina/presentation/viewmodel/state/profile_state.dart';

import 'package:mandarina/core/services/export_service.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/keep_screen_on_notifier.dart';

final pomoProvider = NotifierProvider<PomoNotifier, PomoState>(
  PomoNotifier.new,
);
final dynamicCircleSizeProvider = StateProvider<double>(
  (ref) => 60.0,
); // Provider para controlar la animación del círculo
final workflowProvider = NotifierProvider<WorkflowNotifier, WorkflowState>(
  WorkflowNotifier.new,
);
final sportProvider = NotifierProvider<SportNotifier, SportState>(
  SportNotifier.new,
);
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
final keepScreenOnProvider = NotifierProvider<KeepScreenOnNotifier, bool>(
  KeepScreenOnNotifier.new,
);

final exportServiceProvider = Provider((ref) => ExportService());

