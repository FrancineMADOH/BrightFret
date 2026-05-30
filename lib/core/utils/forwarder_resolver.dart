import 'dart:convert';

import 'package:flutter/services.dart';

/// A single forwarder registry entry parsed from forwarders.json.
class ForwarderEntry {
  const ForwarderEntry({required this.name, required this.url});

  /// Human-readable forwarder name, e.g. "Kamgho Transit".
  final String name;

  /// Odoo instance base URL, e.g. "https://odoo.kamgho-transit.cm".
  final String url;
}

/// Resolves a tracking-code prefix (e.g. "KMG") to the matching Odoo instance URL.
/// Call [load] once at app startup (SplashScreen F1.1) before any [resolve] call.
abstract class ForwarderResolver {
  static final Map<String, ForwarderEntry> _registry = {};
  static bool _loaded = false;

  /// Whether [load] has completed successfully.
  static bool get isLoaded => _loaded;

  /// Reads `assets/data/forwarders.json`, parses it, and populates the registry.
  /// Throws [StateError] if the asset is missing, malformed, or has invalid entries.
  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/forwarders.json');
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw StateError('forwarders.json root must be a JSON object');
    }

    final forwarders = decoded['forwarders'];
    if (forwarders is! Map<String, dynamic>) {
      throw StateError('forwarders.json missing "forwarders" object');
    }

    _registry.clear();
    for (final entry in forwarders.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw StateError('Forwarder entry "${entry.key}" must be a JSON object');
      }
      final name = value['name'] as String?;
      final url = value['url'] as String?;
      if (name == null || url == null) {
        throw StateError('Forwarder "${entry.key}" missing required "name" or "url"');
      }
      _registry[entry.key.toUpperCase()] = ForwarderEntry(name: name, url: url);
    }

    _loaded = true;
  }

  /// Returns the [ForwarderEntry] for [prefix], or null if not registered.
  /// [prefix] is case-insensitive — "kmg" and "KMG" both resolve correctly.
  static ForwarderEntry? resolve(String prefix) {
    return _registry[prefix.toUpperCase()];
  }

  /// Convenience wrapper — returns the instance URL for [prefix], or null.
  static String? resolveUrl(String prefix) => resolve(prefix)?.url;
}
