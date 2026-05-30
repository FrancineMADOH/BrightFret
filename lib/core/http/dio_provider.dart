import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/token_storage.dart';
import '../utils/forwarder_resolver.dart';
import 'dio_client.dart';

part 'dio_provider.g.dart';

/// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
/// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
/// directly, so the auth interceptor always has access to Hive tokens.
///
/// Usage in a service:
/// ```dart
/// final dio = ref.read(dioForInstanceProvider(instanceUrl));
/// ```
@Riverpod(keepAlive: true)
Dio dioForInstance(Ref ref, String instanceUrl) {
  return DioClient.forInstance(
    instanceUrl,
    tokenReader: ref.read(tokenStorageProvider),
    database: ForwarderResolver.resolveDatabaseForUrl(instanceUrl),
  );
}
