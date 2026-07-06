import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialState {
  final bool showTutorial;
  final int currentStep;
  final bool isLoading;

  const TutorialState({
    required this.showTutorial,
    required this.currentStep,
    this.isLoading = false,
  });

  TutorialState copyWith({
    bool? showTutorial,
    int? currentStep,
    bool? isLoading,
  }) {
    return TutorialState(
      showTutorial: showTutorial ?? this.showTutorial,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TutorialNotifier extends Notifier<TutorialState> {
  @override
  TutorialState build() {
    return const TutorialState(
      showTutorial: false,
      currentStep: 1,
      isLoading: false,
    );
  }

  // Clave del prefijo local de persistencia
  String _prefKey(String uid) => 'hasCompletedTutorial_$uid';

  /// Verifica si el usuario necesita ver el tutorial.
  /// 1. Busca localmente en SharedPreferences para optimización instantánea.
  /// 2. Si no existe, realiza una consulta única a Firestore como respaldo.
  Future<void> checkTutorialStatus(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _prefKey(uid);
      
      // Intentar leer de SharedPreferences
      if (prefs.containsKey(key)) {
        final hasCompletedLocal = prefs.getBool(key) ?? false;
        if (hasCompletedLocal) {
          state = const TutorialState(showTutorial: false, currentStep: 1, isLoading: false);
          return;
        }
      }

      // Si no está registrado como completado localmente, verificar en Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['hasCompletedTutorial'] == true) {
          // Actualizar localmente y desactivar
          await prefs.setBool(key, true);
          state = const TutorialState(showTutorial: false, currentStep: 1, isLoading: false);
          return;
        }
      }

      // Si no existe el flag en ninguno, activar el tutorial en el paso 1
      state = const TutorialState(showTutorial: true, currentStep: 1, isLoading: false);
    } catch (e) {
      // En caso de error (ej. desconexión), por seguridad no bloqueamos la app
      state = const TutorialState(showTutorial: false, currentStep: 1, isLoading: false);
    }
  }

  /// Avanza al siguiente paso del tutorial
  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Completa con éxito el tutorial, actualizando tanto localmente como en Firestore.
  Future<void> completeTutorial(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _prefKey(uid);

      // 1. Guardar localmente
      await prefs.setBool(key, true);

      // 2. Guardar en Firestore de manera mezclada (para no borrar otros campos del perfil)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'hasCompletedTutorial': true}, SetOptions(merge: true));

      state = const TutorialState(showTutorial: false, currentStep: 1, isLoading: false);
    } catch (e) {
      // Incluso si falla Firestore (ej. offline), lo damos por completado localmente para no insistir
      state = const TutorialState(showTutorial: false, currentStep: 1, isLoading: false);
    }
  }
}

final tutorialProvider = NotifierProvider<TutorialNotifier, TutorialState>(
  TutorialNotifier.new,
);
