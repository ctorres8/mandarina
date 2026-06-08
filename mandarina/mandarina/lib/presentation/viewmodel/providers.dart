import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/pomonotifiers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';

final pomoProvider = NotifierProvider<PomoNotifier,PomoState>(PomoNotifier.new);
final dynamicCircleSizeProvider = StateProvider<double>((ref) => 60.0); // Provider para controlar la animación del círculo