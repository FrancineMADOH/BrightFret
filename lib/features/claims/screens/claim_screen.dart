import 'package:flutter/material.dart';

/// Stub for ClaimScreen — S18.
/// Full implementation in F4.1/F4.2: claim submission form + status view.
class ClaimScreen extends StatelessWidget {
  const ClaimScreen({super.key, required this.suffix});

  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('ClaimScreen — S18\nsuffix: $suffix'),
      ),
    );
  }
}
