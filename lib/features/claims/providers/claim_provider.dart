import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/dio_provider.dart';
import '../services/claim_service.dart';

part 'claim_provider.g.dart';

/// Manages claim submission for [suffix] / [instanceUrl].
/// State: `null` = not submitted · `String` = Odoo reference on success.
/// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
@riverpod
class ClaimNotifier extends _$ClaimNotifier {
  @override
  Future<String?> build(String suffix, String instanceUrl) async => null;

  /// Submits a claim and stores the Odoo reference on success.
  Future<void> submit({
    required String claimType,
    required String description,
    required double claimedAmount,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioForInstanceProvider(instanceUrl));
      return ClaimService(dio).submitClaim(
        suffix: suffix,
        claimType: claimType,
        description: description,
        claimedAmount: claimedAmount,
      );
    });
  }
}
