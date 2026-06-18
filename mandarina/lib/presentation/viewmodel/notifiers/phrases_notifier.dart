import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhrasesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [
      'Enfócate en el ahora',
      'Paso a paso',
      'Tu tiempo es valioso',
      'Confía en el proceso',
    ];
  }

  void addPhrase(String phrase) {
    final trimmed = phrase.trim();
    if (trimmed.isEmpty) return;
    if (state.length >= 10) return;
    // Evitar duplicados para asegurar mejor experiencia
    if (state.contains(trimmed)) return;
    state = [...state, trimmed];
  }

  void removePhrase(int index) {
    if (index < 0 || index >= state.length) return;
    state = [
      ...state.sublist(0, index),
      ...state.sublist(index + 1),
    ];
  }

  String getRandomPhrase() {
    if (state.isEmpty) return '';
    final random = Random();
    return state[random.nextInt(state.length)];
  }
}

final phrasesProvider = NotifierProvider<PhrasesNotifier, List<String>>(PhrasesNotifier.new);

/// Provider derivado que selecciona una frase aleatoria.
/// Al usar [ref.watch(phrasesProvider)], solo cambia si se altera la lista de frases.
/// Al ser [autoDispose], se recalcula cuando la pantalla vuelve a cargarse.
final randomPhraseProvider = Provider.autoDispose<String>((ref) {
  final phrases = ref.watch(phrasesProvider);
  if (phrases.isEmpty) return '';
  final random = Random();
  return phrases[random.nextInt(phrases.length)];
});
