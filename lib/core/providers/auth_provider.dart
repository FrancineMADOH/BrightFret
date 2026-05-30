import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/token_storage.dart';

part 'auth_provider.g.dart';

/// Returns true if a valid (non-expired) token exists for [suffix].
/// Reads from the Hive tokens box via [TokenStorage].
@riverpod
bool hasValidToken(Ref ref, String suffix) {
  return ref.watch(tokenStorageProvider).hasValidTokenForSuffix(suffix);
}
