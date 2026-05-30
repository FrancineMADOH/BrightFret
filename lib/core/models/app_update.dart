import 'package:hive_flutter/hive_flutter.dart';

part 'app_update.g.dart';

/// An in-app delta notification for a status change on a saved shipment.
/// Stored in the [updatesBox]; entries older than 30 days are purged at startup.
@HiveType(typeId: 4)
class AppUpdate extends HiveObject {
  AppUpdate({
    required this.trackingCode,
    required this.message,
    required this.detectedAt,
    this.isRead = false,
  });

  @HiveField(0)
  String trackingCode;

  @HiveField(1)
  String message;

  @HiveField(2)
  DateTime detectedAt;

  @HiveField(3)
  bool isRead;
}
