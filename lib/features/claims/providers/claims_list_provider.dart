import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/dio_provider.dart';
import '../models/claim_detail.dart';
import '../services/claim_service.dart';

part 'claims_list_provider.g.dart';

/// Fetches all claims for [suffix] / [instanceUrl], newest first.
@riverpod
Future<List<ClaimDetail>> claimsList(
  Ref ref,
  String suffix,
  String instanceUrl,
) async {
  final dio = ref.read(dioForInstanceProvider(instanceUrl));
  return ClaimService(dio).getClaims(suffix: suffix);
}
