import 'package:flutter/material.dart';

/// Stub for DocumentsScreen — S09.
/// Full implementation in F2.3: list of documents with open/download actions.
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key, required this.suffix});

  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('DocumentsScreen — S09\nsuffix: $suffix'),
      ),
    );
  }
}
