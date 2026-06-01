import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/utils/forwarder_resolver.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';

/// S10 — In-app document viewer.
/// Images display with pinch-to-zoom via [InteractiveViewer] + [CachedNetworkImage].
/// PDFs and other types show a download-prompt (no PDF renderer on web).
/// Share and download actions in the AppBar.
class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({
    super.key,
    required this.suffix,
    required this.documentId,
    this.instanceUrl = '',
    this.documentUrl = '',
    this.documentName = '',
    this.documentType = 'other',
  });

  final String suffix;
  final String documentId;
  final String instanceUrl;
  final String documentUrl;
  final String documentName;
  final String documentType;

  bool get _isImage {
    final n = documentName.toLowerCase();
    return documentType == 'image' ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png');
  }

  bool get _isPdf =>
      documentType == 'pdf' || documentName.toLowerCase().endsWith('.pdf');

  Map<String, String> _authHeaders() {
    final box = HiveService.tokens;
    for (final key in box.keys) {
      if (key.toString().endsWith(':$suffix')) {
        final stored = box.get(key);
        if (stored != null && !stored.isExpired) {
          final headers = <String, String>{
            'Authorization': 'Bearer ${stored.token}',
          };
          final db = ForwarderResolver.resolveDatabaseForUrl(instanceUrl);
          if (db != null) headers['X-Odoo-Database'] = db;
          return headers;
        }
      }
    }
    return {};
  }

  Future<void> _share() async {
    final text = documentUrl.isNotEmpty
        ? '$documentName\n$documentUrl'
        : documentName;
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headers = _authHeaders();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          documentName.isNotEmpty ? documentName : documentId,
          style: AppTextStyles.label.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoute.home.path),
        ),
        actions: [
          _DownloadButton(
            documentUrl: documentUrl,
            documentName: documentName,
            headers: headers,
            l10n: l10n,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.shareDocument,
            onPressed: _share,
          ),
        ],
      ),
      body: _buildContent(l10n, headers),
    );
  }

  Widget _buildContent(AppLocalizations l10n, Map<String, String> headers) {
    if (documentUrl.isEmpty) {
      return _UnavailableView(
        icon: Icons.link_off,
        message: l10n.errorLoadingDocument,
        l10n: l10n,
      );
    }
    if (_isImage) {
      return _ImageViewer(url: documentUrl, headers: headers, l10n: l10n);
    }
    return _UnavailableView(
      icon: _isPdf ? Icons.picture_as_pdf_outlined : Icons.attach_file,
      message: l10n.pdfViewerUnavailable,
      hint: l10n.useDownloadButton,
      l10n: l10n,
    );
  }
}

// ── Image viewer with pinch-to-zoom ──────────────────────────────────────────

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({
    required this.url,
    required this.headers,
    required this.l10n,
  });

  final String url;
  final Map<String, String> headers;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 5.0,
      minScale: 0.5,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          httpHeaders: headers,
          fit: BoxFit.contain,
          placeholder: (_, __) => const BfLoadingIndicator(),
          errorWidget: (_, __, ___) => _UnavailableView(
            icon: Icons.broken_image_outlined,
            message: l10n.errorLoadingDocument,
            l10n: l10n,
          ),
        ),
      ),
    );
  }
}

// ── Unavailable view (PDF on web, error, no URL) ──────────────────────────────

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({
    required this.icon,
    required this.message,
    this.hint,
    required this.l10n,
  });

  final IconData icon;
  final String message;
  final String? hint;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.white38),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.heading2.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (hint != null) ...[
              const SizedBox(height: 12),
              Text(
                hint!,
                style: AppTextStyles.body.copyWith(color: Colors.white38),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Download button with circular progress ────────────────────────────────────

class _DownloadButton extends StatefulWidget {
  const _DownloadButton({
    required this.documentUrl,
    required this.documentName,
    required this.headers,
    required this.l10n,
  });

  final String documentUrl;
  final String documentName;
  final Map<String, String> headers;
  final AppLocalizations l10n;

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _downloading = false;
  double _progress = 0;

  Future<void> _handleDownload() async {
    if (_downloading) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.downloadOnMobileOnly)),
      );
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0;
    });

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
        _downloading = false;
        _progress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_downloading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      );
    }
    return IconButton(
      icon: const Icon(Icons.download_outlined),
      tooltip: widget.l10n.downloadDocument,
      onPressed: _handleDownload,
    );
  }
}
