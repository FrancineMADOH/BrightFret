import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';

// ── QR URL parsing ────────────────────────────────────────────────────────────

final _qrUrlPattern = RegExp(
  r'^(https?://[^/\s]+)/api/track/([A-Za-z0-9]{6})$',
);

({String instanceUrl, String suffix})? _parseQrUrl(String raw) {
  final match = _qrUrlPattern.firstMatch(raw.trim());
  if (match == null) return null;
  return (instanceUrl: match.group(1)!, suffix: match.group(2)!);
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// S05 — QR code scanner: live camera with viewfinder overlay, torch toggle,
/// and gallery image analysis.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final MobileScannerController _controller;
  bool _torchOn = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;
    _handleRawValue(rawValue);
  }

  Future<void> _handleRawValue(String rawValue) async {
    final result = _parseQrUrl(rawValue);
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notABrightFretQr),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    setState(() => _processing = true);
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    context.goNamed(
      AppRoute.publicTimeline.name,
      pathParameters: {'suffix': result.suffix},
      queryParameters: {'instance': result.instanceUrl},
    );
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    BarcodeCapture? capture;
    try {
      capture = await _controller.analyzeImage(image.path);
    } catch (_) {
      capture = null;
    }

    if (!mounted) return;
    final rawValue = capture?.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notABrightFretQr),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _handleRawValue(rawValue);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(l10n),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (ctx, error, _) => _buildError(ctx, error, l10n),
          ),
          const _ScanOverlay(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(l10n),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) => AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoute.home.path),
        ),
        title: Text(l10n.scanQrCode),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Torche',
            onPressed: _toggleTorch,
          ),
        ],
      );

  Widget _buildBottomActions(AppLocalizations l10n) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.scanFromGallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.push(AppRoute.trackInput.path),
                child: Text(
                  l10n.enterManually,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildError(
    BuildContext context,
    MobileScannerException error,
    AppLocalizations l10n,
  ) {
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      return _PermissionDeniedView(l10n: l10n);
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            l10n.errorNetworkTitle,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ScanOverlayPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  static const double _viewfinderRatio = 0.7;
  static const double _cornerRadius = 12.0;
  static const double _cornerLength = 28.0;
  static const double _cornerThickness = 3.0;
  static const double _verticalOffset = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final viewfinderSize = size.width * _viewfinderRatio;
    final left = (size.width - viewfinderSize) / 2;
    final top = (size.height - viewfinderSize) / 2 - _verticalOffset;
    final rect = Rect.fromLTWH(left, top, viewfinderSize, viewfinderSize);

    final overlayPaint = Paint()..color = Colors.black.withAlpha(160);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius)),
          ),
      ),
      overlayPaint,
    );

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = _cornerThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawCorners(canvas, rect, cornerPaint);
  }

  void _drawCorners(Canvas canvas, Rect r, Paint paint) {
    const c = _cornerLength;
    canvas.drawLine(Offset(r.left, r.top + c), Offset(r.left, r.top), paint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + c, r.top), paint);
    canvas.drawLine(Offset(r.right - c, r.top), Offset(r.right, r.top), paint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + c), paint);
    canvas.drawLine(Offset(r.left, r.bottom - c), Offset(r.left, r.bottom), paint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + c, r.bottom), paint);
    canvas.drawLine(Offset(r.right - c, r.bottom), Offset(r.right, r.bottom), paint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - c), paint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) => false;
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 72,
                color: Colors.white54,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.cameraDeniedTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.cameraDeniedBody,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.push(AppRoute.trackInput.path),
                child: Text(l10n.enterManually),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
