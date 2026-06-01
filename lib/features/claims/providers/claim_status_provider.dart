import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/dio_provider.dart';
import '../models/claim_detail.dart';
import '../services/claim_service.dart';

part 'claim_status_provider.g.dart';

/// Fetches the latest claim for [suffix] / [instanceUrl].
/// Throws [NotFoundException] when no claim exists for this shipment.
@riverpod
Future<ClaimDetail> claimStatus(
  Ref ref,
  String suffix,
  String instanceUrl,
) async {
  final dio = ref.read(dioForInstanceProvider(instanceUrl));
  return ClaimService(dio).getClaim(suffix: suffix);
}
