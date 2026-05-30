/// A successfully parsed BrightFret tracking code.
class ParsedTrackingCode {
  const ParsedTrackingCode({
    required this.prefix,
    required this.year,
    required this.suffix,
  });

  /// Forwarder prefix, e.g. `"KMG"`.
  final String prefix;

  /// 4-digit shipment year, e.g. `"2026"`.
  final String year;

  /// 6-char alphanumeric suffix used in API URLs, e.g. `"A7X9K2"`.
  final String suffix;

  /// Canonical form: `"$prefix-$year-$suffix"`, e.g. `"KMG-2026-A7X9K2"`.
  String get fullCode => '$prefix-$year-$suffix';
}

/// Parses and validates BrightFret tracking codes.
/// Format: `{PREFIX}-{YEAR}-{SUFFIX}` — e.g. `KMG-2026-A7X9K2`.
abstract class TrackingCodeParser {
  static final RegExp _pattern =
      RegExp(r'^([A-Z0-9]{2,5})-(\d{4})-([A-Z0-9]{6})$');

  /// Parses [raw] into a [ParsedTrackingCode], or returns `null` if invalid.
  /// Input is trimmed and uppercased before validation, so lowercase codes
  /// (e.g. `"kmg-2026-a7x9k2"`) are accepted and normalised.
  static ParsedTrackingCode? parse(String raw) {
    final normalised = raw.trim().toUpperCase();
    final match = _pattern.firstMatch(normalised);
    if (match == null) return null;
    return ParsedTrackingCode(
      prefix: match.group(1)!,
      year: match.group(2)!,
      suffix: match.group(3)!,
    );
  }
}
