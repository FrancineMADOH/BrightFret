import 'package:flutter/material.dart';

/// Stub for PhoneVerifyScreen — S07.
/// Full implementation in F2.1: 4-digit PIN entry, 24h token stored in Hive.
class PhoneVerifyScreen extends StatelessWidget {
  const PhoneVerifyScreen({super.key, required this.suffix});

  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('PhoneVerifyScreen — S07\nsuffix: $suffix'),
      ),
    );
  }
}
