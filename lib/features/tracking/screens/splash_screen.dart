import 'package:flutter/material.dart';

/// Stub for SplashScreen — S01.
/// Full implementation in F1.1: initialises Hive, loads forwarders.json,
/// then routes to /onboarding or /home.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF002868),
      body: Center(
        child: Text(
          'SplashScreen — S01',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
