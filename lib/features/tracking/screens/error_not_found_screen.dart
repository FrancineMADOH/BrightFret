import 'package:flutter/material.dart';

/// Stub for ErrorNotFoundScreen — S16.
/// Full implementation in F1.8: shown on 404 from the tracking API.
/// Also used as the go_router errorBuilder fallback for unknown routes.
class ErrorNotFoundScreen extends StatelessWidget {
  const ErrorNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('ErrorNotFoundScreen — S16')),
    );
  }
}
