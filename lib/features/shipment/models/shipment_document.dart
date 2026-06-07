import '../../../core/utils/odoo_datetime.dart';

/// A document attached to a shipment, returned by `GET /api/shipment/{suffix}/documents`.
/// Handles the actual Odoo response format: `id` (int), `mimetype`, relative `url`.
class ShipmentDocument {
  const ShipmentDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// `'pdf'` · `'image'` · `'other'` — derived from `mimetype` or `type` field.
  final String type;

  /// File size in bytes (0 if not provided by the API).
  final int size;

  /// Absolute URL to the document (auth header required).
  final String url;

  final DateTime createdAt;

  /// Parses an Odoo document entry.
  /// [baseUrl] is the forwarder instance URL, used to make relative URLs absolute.
  factory ShipmentDocument.fromJson(
    Map<String, dynamic> json, {
    String baseUrl = '',
  }) {
    final rawUrl = json['url'] as String? ?? '';
    final absoluteUrl =
        rawUrl.startsWith('http') ? rawUrl : '$baseUrl$rawUrl';

    final mimetype = json['mimetype'] as String? ?? '';
    final rawType = json['type'] as String? ?? '';
    final type = _resolveType(mimetype.isNotEmpty ? mimetype : rawType);

    final createdRaw = json['created_at'] as String?;

    return ShipmentDocument(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'document',
      type: type,
      size: (json['size'] as num?)?.toInt() ?? 0,
      url: absoluteUrl,
      createdAt: parseOdooDateTime(createdRaw) ?? DateTime.now(),
    );
  }

  static String _resolveType(String hint) {
    final h = hint.toLowerCase();
    if (h.startsWith('image/') || h == 'image') return 'image';
    if (h == 'application/pdf' || h == 'pdf') return 'pdf';
    return 'other';
  }

  bool get isPdf {
    final n = name.toLowerCase();
    return type == 'pdf' || n.endsWith('.pdf');
  }

  bool get isImage {
    final n = name.toLowerCase();
    return type == 'image' ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png');
  }

  /// Human-readable file size. Returns empty string if size is 0.
  String get sizeLabel {
    if (size == 0) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formatted creation date: `dd/mm/yyyy`.
  String get dateLabel {
    final d = createdAt.day.toString().padLeft(2, '0');
    final m = createdAt.month.toString().padLeft(2, '0');
    return '$d/$m/${createdAt.year}';
  }
}
