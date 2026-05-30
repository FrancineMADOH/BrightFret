import 'package:hive_flutter/hive_flutter.dart';

part 'auth_token.g.dart';

/// 24-hour bearer token stored after phone verification (F2.1).
/// Keyed by '{instanceUrl}:{suffix}' in the [tokensBox].
@HiveType(typeId: 2)
class AuthToken extends HiveObject {
  AuthToken({
    required this.token,
    required this.suffix,
    required this.instanceUrl,
    required this.expiresAt,
  });

  @HiveField(0)
  String token;

  @HiveField(1)
  String suffix;

  @HiveField(2)
  String instanceUrl;

  @HiveField(3)
  DateTime expiresAt;

  /// Returns true if the token has passed its expiry time.
  /// Always checked at read time — never trust a cached result.
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
