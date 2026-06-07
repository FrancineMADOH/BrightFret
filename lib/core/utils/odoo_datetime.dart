final _hasTimezone = RegExp(r'[Zz]|[+-]\d{2}:?\d{2}$');
final _hasTime = RegExp(r'[T ]\d{2}:\d{2}');

/// Parses an Odoo API datetime string into a correct local [DateTime].
///
/// Odoo stores and returns datetimes in UTC but serialises them with
/// `.isoformat()` on a naive (tzinfo-less) value — e.g. `"2026-06-07T09:24:39"`,
/// with no `Z`/offset suffix. [DateTime.parse] would otherwise interpret that
/// string as local time, shifting it by the device's UTC offset (e.g. "2h ago"
/// for a message sent seconds ago on a UTC+2 device). We mark it UTC explicitly
/// before converting to local time.
///
/// Odoo `Date` fields (e.g. `open_date`, `close_date`) serialise as date-only
/// strings — `"2026-06-07"`, no time component. Appending `Z` to those produces
/// an invalid ISO string (`DateTime.tryParse` returns null), so we only append
/// it when a time component is actually present.
DateTime? parseOdooDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_hasTime.hasMatch(value)) return DateTime.tryParse(value);
  final iso = _hasTimezone.hasMatch(value) ? value : '${value}Z';
  return DateTime.tryParse(iso)?.toLocal();
}
