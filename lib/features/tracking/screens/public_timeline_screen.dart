import 'package:flutter/material.dart';

/// Stub for PublicTimelineScreen — S06.
/// Full implementation in F1.7: transit timeline, forwarder branding, save/unlock CTA.
class PublicTimelineScreen extends StatelessWidget {
  const PublicTimelineScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;

  /// Odoo base URL for the forwarder. Resolved from forwarders.json in F1.2.
  final String instanceUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('PublicTimelineScreen — S06\nsuffix: $suffix')),
    );
  }
}
