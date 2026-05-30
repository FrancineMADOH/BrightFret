import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// Returns true if a valid (non-expired) token exists for [suffix].
/// Stub: always false. Will check the Hive `tokens` box in F0.5.
@riverpod
bool hasValidToken(Ref ref, String suffix) => false;
