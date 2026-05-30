import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/hive_service.dart';

part 'locale_provider.g.dart';

/// Supported language codes. Only these values are accepted by [LocaleState.setLocale].
const _supportedCodes = {'fr', 'en'};
const _prefsKey = 'language';

/// App locale state, persisted in Hive `prefs` box.
/// Defaults to French if no saved language is found or the stored value is unsupported.
@Riverpod(keepAlive: true)
class LocaleState extends _$LocaleState {
  @override
  Locale build() {
    final saved = HiveService.prefs.get(_prefsKey, defaultValue: 'fr') as String;
    final code = _supportedCodes.contains(saved) ? saved : 'fr';
    return Locale(code);
  }

  /// Updates the app locale to [langCode] and persists the choice to Hive.
  /// Silently ignores unsupported language codes.
  Future<void> setLocale(String langCode) async {
    if (!_supportedCodes.contains(langCode)) return;
    await HiveService.prefs.put(_prefsKey, langCode);
    state = Locale(langCode);
  }
}
