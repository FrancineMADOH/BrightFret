import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../http/dio_client.dart';
import '../models/auth_token.dart';
import 'hive_service.dart';

part 'token_storage.g.dart';

/// Regex to extract the shipment suffix from API paths.
/// Matches /api/track/{suffix} and /api/shipment/{suffix}[/...].
final _suffixPattern = RegExp(r'/api/(?:track|shipment)/([A-Za-z0-9]+)');

/// Hive-backed implementation of [TokenReader].
/// Reads, writes, and deletes auth tokens from the [HiveService.tokens] box.
/// Token expiry is always checked at read time.
class TokenStorage implements TokenReader {
  /// [TokenReader.getToken] — extracts suffix from [options.path], looks up
  /// the token in Hive, and returns it only if non-null and not expired.
  @override
  String? getToken(RequestOptions options) {
    final match = _suffixPattern.firstMatch(options.path);
    if (match == null) return null;

    final suffix = match.group(1)!;
    final key = '${options.baseUrl}:$suffix';
    final token = HiveService.tokens.get(key);

    if (token == null || token.isExpired) return null;
    return token.token;
  }

  /// Persists [token] to the tokens box.
  /// Key format: '{instanceUrl}:{suffix}'.
  Future<void> saveToken(AuthToken token) async {
    final key = '${token.instanceUrl}:${token.suffix}';
    await HiveService.tokens.put(key, token);
  }

  /// Removes the token for [instanceUrl] + [suffix].
  Future<void> deleteToken(String instanceUrl, String suffix) async {
    await HiveService.tokens.delete('$instanceUrl:$suffix');
  }

  /// Returns true if a valid (non-expired) token exists for [suffix]
  /// under any instanceUrl. Used by the router auth guard.
  bool hasValidTokenForSuffix(String suffix) {
    final box = HiveService.tokens;
    for (final key in box.keys) {
      if (key.toString().endsWith(':$suffix')) {
        final token = box.get(key);
        if (token != null && !token.isExpired) return true;
      }
    }
    return false;
  }
}

/// App-wide singleton [TokenStorage].
/// Services inject this as the [TokenReader] when calling [DioClient.forInstance].
@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => TokenStorage();
