import '../../../core/utils/odoo_datetime.dart';

/// One attachment carried by a [ShipmentMessage].
/// URL is absolute when [instanceUrl] is prepended (done by the screen layer).
class MessageAttachment {
  const MessageAttachment({
    required this.id,
    required this.name,
    required this.mimetype,
    required this.url,
  });

  final int id;
  final String name;
  final String mimetype;

  /// Relative URL from Odoo: `/web/content/{id}?access_token=...`
  /// Prepend [instanceUrl] before passing to Image.network or opening a browser.
  final String url;

  bool get isImage => mimetype.startsWith('image/');

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        mimetype: json['mimetype'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
}

/// A single chatter message exchanged between client and forwarder.
class ShipmentMessage {
  const ShipmentMessage({
    required this.id,
    required this.body,
    required this.author,
    required this.isFromClient,
    required this.createdAt,
    this.attachments = const [],
  });

  final int id;
  final String body;
  final String author;

  /// True when the message was sent by the client (right-aligned bubble).
  final bool isFromClient;
  final DateTime createdAt;
  final List<MessageAttachment> attachments;

  factory ShipmentMessage.fromJson(Map<String, dynamic> json) {
    final rawAtts = json['attachments'] as List<dynamic>? ?? [];
    return ShipmentMessage(
      id: json['id'] as int? ?? 0,
      body: _stripHtml(json['body'] as String? ?? ''),
      author: json['author'] as String? ?? '',
      isFromClient: json['is_from_client'] as bool? ?? false,
      createdAt:
          parseOdooDateTime(json['datetime'] as String?) ?? DateTime.now(),
      attachments: rawAtts
          .map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Strips HTML tags from Odoo chatter message bodies (e.g. `<b>ref</b>`).
  static String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
}
