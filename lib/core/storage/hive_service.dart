import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_update.dart';
import '../models/auth_token.dart';
import '../models/cached_forwarder_info.dart';
import '../models/cached_shipment.dart';
import '../models/saved_shipment.dart';

/// Initialises Hive, registers adapters, and opens all 6 typed boxes.
/// Call [init] once in [main] before [runApp].
abstract class HiveService {
  // ── Box name constants ────────────────────────────────────────────────────
  static const String shipmentsBox = 'shipments';
  static const String forwarderInfoBox = 'forwarder_info';
  static const String myShipmentsBox = 'my_shipments';
  static const String tokensBox = 'tokens';
  static const String updatesBox = 'updates';
  static const String prefsBox = 'prefs';

  static const Duration _updateMaxAge = Duration(days: 30);

  // ── Typed box accessors ───────────────────────────────────────────────────

  /// Cached public shipment timelines. Key: '{instanceUrl}:{suffix}'.
  static Box<CachedShipment> get shipments =>
      Hive.box<CachedShipment>(shipmentsBox);

  /// Forwarder branding cache (7-day TTL). Key: instanceUrl.
  static Box<CachedForwarderInfo> get forwarderInfo =>
      Hive.box<CachedForwarderInfo>(forwarderInfoBox);

  /// User's saved shipments list. Key: full tracking code.
  static Box<SavedShipment> get myShipments =>
      Hive.box<SavedShipment>(myShipmentsBox);

  /// Auth tokens (24h TTL). Key: '{instanceUrl}:{suffix}'.
  static Box<AuthToken> get tokens => Hive.box<AuthToken>(tokensBox);

  /// In-app update notifications. Purged after 30 days.
  static Box<AppUpdate> get updates => Hive.box<AppUpdate>(updatesBox);

  /// User preferences (language, onboarding_done, search history).
  static Box<dynamic> get prefs => Hive.box<dynamic>(prefsBox);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initialises Hive, registers all adapters, opens all boxes, and purges
  /// stale update entries. Must be awaited before [runApp].
  static Future<void> init() async {
    await Hive.initFlutter();

    _registerAdapters();

    await Future.wait([
      Hive.openBox<CachedShipment>(shipmentsBox),
      Hive.openBox<CachedForwarderInfo>(forwarderInfoBox),
      Hive.openBox<SavedShipment>(myShipmentsBox),
      Hive.openBox<AuthToken>(tokensBox),
      Hive.openBox<AppUpdate>(updatesBox),
      Hive.openBox<dynamic>(prefsBox),
    ]);

    await purgeOldUpdates();
  }

  // Guards prevent double-registration after Hive.deleteFromDisk() + reinit.
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CachedShipmentAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SavedShipmentAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AuthTokenAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CachedForwarderInfoAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AppUpdateAdapter());
  }

  /// Wipes all Hive storage and re-initialises from scratch.
  /// Used by SplashScreen's "Réinitialiser l'app" error recovery flow.
  static Future<void> deleteAllData() async {
    await Hive.deleteFromDisk();
    await init();
  }

  /// Deletes [AppUpdate] entries older than 30 days.
  /// Called automatically by [init]; can also be called manually.
  static Future<void> purgeOldUpdates() async {
    final box = updates;
    final cutoff = DateTime.now().subtract(_updateMaxAge);
    final staleKeys = box.keys
        .where((k) {
          final entry = box.get(k);
          return entry != null && entry.detectedAt.isBefore(cutoff);
        })
        .toList();
    if (staleKeys.isNotEmpty) {
      await box.deleteAll(staleKeys);
    }
  }
}
