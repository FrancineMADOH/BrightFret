import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/cargo_summary.dart';

/// Cargo detail screen — pushed via [Navigator.push] from S08.
/// Shows freight lines with quantity, weight/volume, unit price and total.
/// Client-facing data from freight.shipment.line, not the accounting invoice.
class CargoSummaryScreen extends StatelessWidget {
  const CargoSummaryScreen({
    super.key,
    required this.cargo,
    required this.trackingCode,
    required this.forwarderName,
  });

  final CargoSummary cargo;
  final String trackingCode;
  final String forwarderName;

  String _buildShareText(AppLocalizations l10n, String numLocale) {
    final fmt = NumberFormat('#,##0.###', numLocale);
    final fmtAmt = NumberFormat('#,##0', numLocale);
    final buf = StringBuffer();
    buf.writeln(l10n.cargoShareTitle(trackingCode));
    buf.writeln('$forwarderName\n');
    for (final line in cargo.lines) {
      final unit = line.isByWeight ? 'kg' : 'm³';
      buf.writeln('• ${line.name}');
      buf.writeln(
          '  ${fmt.format(line.totalMeasure)} $unit × ${fmtAmt.format(line.price)} ${cargo.currency}/$unit = ${fmtAmt.format(line.totalPrice)} ${cargo.currency}');
    }
    buf.writeln('');
    if (cargo.totalWeight > 0) {
      buf.writeln(l10n.cargoShareTotalWeight('${fmt.format(cargo.totalWeight)} kg'));
    }
    if (cargo.totalVolume > 0) {
      buf.writeln(l10n.cargoShareTotalVolume('${fmt.format(cargo.totalVolume)} m³'));
    }
    buf.writeln(l10n.cargoShareGrandTotal(
        '${fmtAmt.format(cargo.totalGoodsAmount)} ${cargo.currency}'));
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numLocale = Localizations.localeOf(context).languageCode == 'fr'
        ? 'fr_FR'
        : 'en_US';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cargoScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.shareDocument,
            onPressed: () => Share.share(_buildShareText(l10n, numLocale)),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _CargoCard(
          cargo: cargo,
          trackingCode: trackingCode,
          forwarderName: forwarderName,
          l10n: l10n,
          numLocale: numLocale,
        ),
      ),
    );
  }
}

// ── Card container ────────────────────────────────────────────────────────────

class _CargoCard extends StatelessWidget {
  const _CargoCard({
    required this.cargo,
    required this.trackingCode,
    required this.forwarderName,
    required this.l10n,
    required this.numLocale,
  });

  final CargoSummary cargo;
  final String trackingCode;
  final String forwarderName;
  final AppLocalizations l10n;
  final String numLocale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
              trackingCode: trackingCode,
              currency: cargo.currency,
              l10n: l10n),
          Divider(color: Colors.grey[300], height: 1),
          _CargoTable(cargo: cargo, l10n: l10n, numLocale: numLocale),
          Divider(color: Colors.grey[300], height: 1),
          _TotalsSection(cargo: cargo, l10n: l10n, numLocale: numLocale),
          _CardFooter(forwarderName: forwarderName, l10n: l10n),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.trackingCode,
    required this.currency,
    required this.l10n,
  });

  final String trackingCode;
  final String currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 40, color: primary),
          const SizedBox(height: 8),
          Text(
            trackingCode,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            l10n.cargoSubtitle(currency),
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Cargo table ───────────────────────────────────────────────────────────────

class _CargoTable extends StatelessWidget {
  const _CargoTable({
    required this.cargo,
    required this.l10n,
    required this.numLocale,
  });

  final CargoSummary cargo;
  final AppLocalizations l10n;
  final String numLocale;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.caption.copyWith(
      color: Colors.grey[600],
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 4, child: Text(l10n.cargoColGoods, style: labelStyle)),
              Expanded(flex: 2, child: Text(l10n.cargoColWeightVol, style: labelStyle, textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text(l10n.cargoColUnitPrice, style: labelStyle, textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text(l10n.cargoColTotal, style: labelStyle, textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 8),
          ...cargo.lines.map((line) => _CargoRow(line: line, numLocale: numLocale)),
        ],
      ),
    );
  }
}

class _CargoRow extends StatelessWidget {
  const _CargoRow({required this.line, required this.numLocale});

  final CargoLine line;
  final String numLocale;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.###', numLocale);
    final fmtAmt = NumberFormat('#,##0', numLocale);
    final unit = line.isByWeight ? 'kg' : 'm³';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              line.name.isNotEmpty ? line.name : '—',
              style: AppTextStyles.caption,
              softWrap: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${fmt.format(line.totalMeasure)} $unit',
              style: AppTextStyles.caption,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${fmtAmt.format(line.price)}/$unit',
              style: AppTextStyles.caption,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fmtAmt.format(line.totalPrice),
              style: AppTextStyles.caption,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Totals ────────────────────────────────────────────────────────────────────

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({
    required this.cargo,
    required this.l10n,
    required this.numLocale,
  });

  final CargoSummary cargo;
  final AppLocalizations l10n;
  final String numLocale;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.###', numLocale);
    final fmtAmt = NumberFormat('#,##0', numLocale);
    final c = cargo.currency;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          if (cargo.totalWeight > 0)
            _TotalRow(
              label: l10n.cargoTotalWeight,
              value: '${fmt.format(cargo.totalWeight)} kg',
            ),
          if (cargo.totalVolume > 0)
            _TotalRow(
              label: l10n.cargoTotalVolume,
              value: '${fmt.format(cargo.totalVolume)} m³',
            ),
          Divider(color: Colors.grey[200], height: 16),
          _TotalRow(
            label: l10n.cargoGrandTotal,
            value: '${fmtAmt.format(cargo.totalGoodsAmount)} $c',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.label
        : AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.forwarderName, required this.l10n});

  final String forwarderName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Text(
        '$forwarderName — ${l10n.cargoTagline}',
        style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
        textAlign: TextAlign.center,
      ),
    );
  }
}
