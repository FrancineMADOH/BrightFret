import 'package:flutter/material.dart';

/// Stub for DocumentViewerScreen — S10.
/// Full implementation in F2.4: in-app PDF/image viewer with zoom and share.
class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({
    super.key,
    required this.suffix,
    required this.documentId,
  });

  final String suffix;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('DocumentViewerScreen — S10\n$suffix / $documentId'),
      ),
    );
  }
}
