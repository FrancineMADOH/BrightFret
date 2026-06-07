import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Maps the app's resolved document type ('image'/'pdf'/'other') to a MIME type
/// hint for [OpenFilex.open] — Odoo attachment names (e.g. `image0`) often lack
/// an extension, so the OS can't infer the right viewer without this hint.
String? _mimeTypeFor(String documentType) {
  switch (documentType) {
    case 'image':
      return 'image/*';
    case 'pdf':
      return 'application/pdf';
    default:
      return null;
  }
}

/// Downloads [url] to the app's cache directory under [fileName] and opens it
/// with the system viewer via [OpenFilex] — the share/save sheet from there
/// lets the user export a copy to their Downloads/Documents folder.
Future<void> downloadAndOpenDocument({
  required Dio dio,
  required String url,
  required String fileName,
  required String documentType,
  required void Function(double progress) onProgress,
}) async {
  final dir = await getTemporaryDirectory();
  final safeName = fileName.isNotEmpty ? fileName : 'document';
  final savePath = '${dir.path}/$safeName';
  await dio.download(
    url,
    savePath,
    onReceiveProgress: (received, total) {
      if (total > 0) onProgress(received / total);
    },
  );
  await OpenFilex.open(savePath, type: _mimeTypeFor(documentType));
}
