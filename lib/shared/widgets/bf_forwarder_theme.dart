import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../features/tracking/providers/forwarder_info_provider.dart';

/// Wraps [child] in a local [Theme] tinted with the forwarder's primary colour.
///
/// Reads [forwarderInfoProvider] for [instanceUrl]. If the forwarder exposes a
/// valid `app_primary_color` hex value, all Material 3 components inside this
/// widget use that colour as their seed. The global app theme is never modified.
///
/// Falls back silently to [AppColors.primary] when:
/// - [instanceUrl] is empty
/// - the provider has no data yet
/// - `primaryColor` is null, empty, or not a valid 6-digit hex
class BfForwarderTheme extends ConsumerWidget {
  const BfForwarderTheme({
    super.key,
    required this.instanceUrl,
    required this.child,
  });

  final String instanceUrl;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (instanceUrl.isEmpty) return child;

    final forwarder =
        ref.watch(forwarderInfoProvider(instanceUrl)).valueOrNull;
    final overrideColor = _parseHex(forwarder?.primaryColor);

    if (overrideColor == null) return child;

    return Theme(
      data: _buildTheme(context, overrideColor),
      child: child,
    );
  }

  /// Derives a [ThemeData] from [primary], preserving the existing text theme.
  static ThemeData _buildTheme(BuildContext context, Color primary) {
    final base = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: base.brightness,
    );
    return base.copyWith(
      colorScheme: scheme,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Parses a CSS hex colour string (e.g. `#2E7D32` or `2E7D32`) into a [Color].
  /// Returns `null` for null, empty, or malformed values.
  static Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.startsWith('#') ? hex.substring(1) : hex;
    if (clean.length != 6) return null;
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return null;
    final color = Color(0xFF000000 | value);
    // Skip the override if it matches the default to avoid pointless rebuilds.
    return color == AppColors.primary ? null : color;
  }
}
