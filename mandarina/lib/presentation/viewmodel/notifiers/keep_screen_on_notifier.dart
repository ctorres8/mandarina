import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class KeepScreenOnNotifier extends Notifier<bool> {
  static const String _prefKey = 'keep_screen_on';

  @override
  bool build() {
    _loadInitialState();
    return false;
  }

  Future<void> _loadInitialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getBool(_prefKey) ?? false;
      state = savedValue;
      if (savedValue) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Ignore platform error fallback
    }
  }

  Future<void> setKeepScreenOn(bool enable) async {
    state = enable;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enable);

      if (enable) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {}
  }
}
