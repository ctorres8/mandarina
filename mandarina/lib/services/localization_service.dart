import 'package:flutter/material.dart';

class MandarinaTexts {
  static const Map<String, Map<String, String>> _localizedValues = {
    'cambiar_idioma': {
      'es': 'Cambiar Idioma',
      'en': 'Change Language',
    },
    'ajustes_generales': {
      'es': 'AJUSTES GENERALES',
      'en': 'GENERAL SETTINGS',
    },
    'seleccionar_idioma': {
      'es': 'Seleccionar Idioma',
      'en': 'Select Language',
    },
  };

  static String getText(Locale locale, String key) {
    final languageCode = locale.languageCode;
    if (_localizedValues.containsKey(key)) {
      return _localizedValues[key]?[languageCode] ?? _localizedValues[key]?['es'] ?? key;
    }
    return key;
  }
}
