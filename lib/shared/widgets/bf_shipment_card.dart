import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/constants/app_text_styles.dart';
import 'bf_status_badge.dart';

/// Card displaying a shipment summary: code, transport icon, status badge,
/// and a localised relative "last updated" timestamp.
class BfShipmentCard extends StatelessWidget {
  const BfShipmentCard({
    super.key,
    required this.trackingCode,
    required this.transportType,
    required this.status,
    required this.lastUpdated,
    this.onTap,
  });

  final String trackingCode;
  final TransportType transportType;
  final ShipmentStatus status;
  final DateTime lastUpdated;
  final VoidCallback? onTap;

  String get _transportIcon =>
      transportType == TransportType.air ? '✈️' : '🚢';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 8),
              _timestamp(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Text(_transportIcon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trackingCode,
              style: AppTextStyles.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          BfStatusBadge(status: status),
        ],
      );

  Widget _timestamp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(
      l10n.updatedAt(_relativeTime(lastUpdated, l10n)),
      style: AppTextStyles.caption.copyWith(color: AppColors.statusArchived),
    );
  }

  static String _relativeTime(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
