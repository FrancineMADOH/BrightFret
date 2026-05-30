import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/dio_provider.dart';
import '../models/shipment_document.dart';
import '../services/documents_service.dart';

part 'documents_provider.g.dart';

/// Fetches the document list for [suffix] from [instanceUrl].
/// Requires a valid bearer token — throws [UnauthorizedException] if expired.
@riverpod
Future<List<ShipmentDocument>> documents(
  Ref ref,
  String suffix,
  String instanceUrl,
) async {
  final dio = ref.read(dioForInstanceProvider(instanceUrl));
  return DocumentsService(dio).getDocuments(suffix, instanceUrl: instanceUrl);
}
