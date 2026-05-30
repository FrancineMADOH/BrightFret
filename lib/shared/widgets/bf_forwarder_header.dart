import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

/// Displays the forwarder's logo and name at the top of shipment screens.
/// Falls back to the BrightFret asset logo if [logoUrl] is null or fails to load.
class BfForwarderHeader extends StatelessWidget {
  const BfForwarderHeader({
    super.key,
    required this.forwarderName,
    this.logoUrl,
  });

  final String forwarderName;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: logoUrl != null ? _networkLogo() : _assetLogo(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            forwarderName,
            style: AppTextStyles.heading2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _networkLogo() => CachedNetworkImage(
        imageUrl: logoUrl!,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _assetLogo(),
      );

  Widget _assetLogo() => Image.asset(
        'assets/images/logo_brightfret.png',
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
}
