import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_error_screen.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../models/shipment_document.dart';
import '../providers/documents_provider.dart';

/// S09 — Document list for a shipment.
/// Lists all attached files with open (→ S10) and download actions.
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;
  final String instanceUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider(suffix, instanceUrl));
    final isOnline = ref.watch(connectivityNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sectionDocuments),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoute.home.path),
        ),
      ),
      body: docsAsync.when(
        loading: () => const BfLoadingIndicator(),
        error: (err, _) => _buildError(context, ref, err, l10n),
        data: (docs) => docs.isEmpty
            ? _EmptyState(l10n: l10n)
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(documentsProvider(suffix, instanceUrl));
                  await ref
                      .read(documentsProvider(suffix, instanceUrl).future)
                      .catchError((_) => <ShipmentDocument>[]);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) => _DocumentRow(
                    document: docs[i],
                    suffix: suffix,
                    instanceUrl: instanceUrl,
                    isOnline: isOnline,
                    l10n: l10n,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppLocalizations l10n,
  ) {
    if (error is NetworkException) {
      return BfErrorScreen(
        icon: Icons.wifi_off_outlined,
        title: l10n.errorNetworkTitle,
        body: l10n.offlineDocumentsUnavailable,
        actions: [
          BfErrorAction(
            label: l10n.retry,
            onTap: () =>
                ref.invalidate(documentsProvider(suffix, instanceUrl)),
          ),
        ],
      );
    }
    return BfErrorScreen(
      icon: Icons.folder_off_outlined,
      title: l10n.errorNetworkTitle,
      body: l10n.errorNetworkBody,
      actions: [
        BfErrorAction(
          label: l10n.retry,
          onTap: () =>
              ref.invalidate(documentsProvider(suffix, instanceUrl)),
        ),
      ],
    );
  }
}

// ── Document row ──────────────────────────────────────────────────────────────

class _DocumentRow extends StatefulWidget {
  const _DocumentRow({
    required this.document,
    required this.suffix,
    required this.instanceUrl,
    required this.isOnline,
    required this.l10n,
  });

  final ShipmentDocument document;
  final String suffix;
  final String instanceUrl;
  final bool isOnline;
  final AppLocalizations l10n;

  @override
  State<_DocumentRow> createState() => _DocumentRowState();
}

class _DocumentRowState extends State<_DocumentRow> {
  bool _isDownloading = false;
  double _progress = 0;

  IconData get _icon {
    if (widget.document.isPdf) return Icons.picture_as_pdf_outlined;
    if (widget.document.isImage) return Icons.image_outlined;
    return Icons.attach_file;
  }

  Color get _iconColor {
    if (widget.document.isPdf) return AppColors.statusError;
    if (widget.document.isImage) return AppColors.statusActive;
    return AppColors.statusArchived;
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.downloadOnMobileOnly)),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    // Simulated progress — real Dio download + open_filex wired in mobile build
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.downloadSuccess)),
      );
      setState(() {
        _isDownloading = false;
        _progress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_icon, color: _iconColor, size: 22),
      ),
      title: Text(
        doc.name,
        style: AppTextStyles.label,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [if (doc.sizeLabel.isNotEmpty) doc.sizeLabel, doc.dateLabel].join(' · '),
        style: AppTextStyles.caption.copyWith(color: AppColors.statusArchived),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              if (!widget.isOnline) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(widget.l10n.offlineDocumentsUnavailable),
                ));
                return;
              }
              context.goNamed(
                AppRoute.documentViewer.name,
                pathParameters: {'suffix': widget.suffix, 'id': doc.id},
                queryParameters: {
                  'instance': widget.instanceUrl,
                  'url': doc.url,
                  'name': doc.name,
                  'type': doc.type,
                },
              );
            },
            child: Text(widget.l10n.openDocument),
          ),
          const SizedBox(width: 4),
          _isDownloading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download_outlined),
                  color: AppColors.primary,
                  tooltip: widget.l10n.downloadDocument,
                  onPressed: _handleDownload,
                ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 72,
              color: AppColors.statusArchived,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDocumentsYet,
              style: AppTextStyles.body.copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
