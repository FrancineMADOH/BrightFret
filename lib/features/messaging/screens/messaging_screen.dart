import 'package:flutter/material.dart';

/// Stub for MessagingScreen — S11.
/// Full implementation in F3.1: chat UI with 30s polling via Timer.periodic.
class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key, required this.suffix});

  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('MessagingScreen — S11\nsuffix: $suffix'),
      ),
    );
  }
}
