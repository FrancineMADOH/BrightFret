/// A single chatter message exchanged between client and forwarder.
class ShipmentMessage {
  const ShipmentMessage({
    required this.id,
    required this.body,
    required this.author,
    required this.isFromClient,
    required this.createdAt,
  });

  final int id;
  final String body;
  final String author;

  /// True when the message was sent by the client (right-aligned bubble).
  final bool isFromClient;
  final DateTime createdAt;

  factory ShipmentMessage.fromJson(Map<String, dynamic> json) {
    return ShipmentMessage(
      id: json['id'] as int? ?? 0,
      body: _stripHtml(json['body'] as String? ?? ''),
      author: json['author'] as String? ?? '',
      isFromClient: json['is_from_client'] as bool? ?? false,
      createdAt: json['datetime'] != null
          ? DateTime.tryParse(json['datetime'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Strips HTML tags from Odoo chatter message bodies (e.g. `<b>ref</b>`).
  static String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
}
