// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesNotifierHash() => r'1fd266e2e370c644ca759eec09a2d152871721ca';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MessagesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ShipmentMessage>> {
  late final String suffix;
  late final String instanceUrl;

  FutureOr<List<ShipmentMessage>> build(
    String suffix,
    String instanceUrl,
  );
}

/// Manages the list of messages for [suffix] / [instanceUrl].
/// Supports silent background refresh (poll) and optimistic appends on send.
///
/// Copied from [MessagesNotifier].
@ProviderFor(MessagesNotifier)
const messagesNotifierProvider = MessagesNotifierFamily();

/// Manages the list of messages for [suffix] / [instanceUrl].
/// Supports silent background refresh (poll) and optimistic appends on send.
///
/// Copied from [MessagesNotifier].
class MessagesNotifierFamily extends Family<AsyncValue<List<ShipmentMessage>>> {
  /// Manages the list of messages for [suffix] / [instanceUrl].
  /// Supports silent background refresh (poll) and optimistic appends on send.
  ///
  /// Copied from [MessagesNotifier].
  const MessagesNotifierFamily();

  /// Manages the list of messages for [suffix] / [instanceUrl].
  /// Supports silent background refresh (poll) and optimistic appends on send.
  ///
  /// Copied from [MessagesNotifier].
  MessagesNotifierProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return MessagesNotifierProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  MessagesNotifierProvider getProviderOverride(
    covariant MessagesNotifierProvider provider,
  ) {
    return call(
      provider.suffix,
      provider.instanceUrl,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesNotifierProvider';
}

/// Manages the list of messages for [suffix] / [instanceUrl].
/// Supports silent background refresh (poll) and optimistic appends on send.
///
/// Copied from [MessagesNotifier].
class MessagesNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MessagesNotifier, List<ShipmentMessage>> {
  /// Manages the list of messages for [suffix] / [instanceUrl].
  /// Supports silent background refresh (poll) and optimistic appends on send.
  ///
  /// Copied from [MessagesNotifier].
  MessagesNotifierProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          () => MessagesNotifier()
            ..suffix = suffix
            ..instanceUrl = instanceUrl,
          from: messagesNotifierProvider,
          name: r'messagesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesNotifierHash,
          dependencies: MessagesNotifierFamily._dependencies,
          allTransitiveDependencies:
              MessagesNotifierFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  MessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suffix,
    required this.instanceUrl,
  }) : super.internal();

  final String suffix;
  final String instanceUrl;

  @override
  FutureOr<List<ShipmentMessage>> runNotifierBuild(
    covariant MessagesNotifier notifier,
  ) {
    return notifier.build(
      suffix,
      instanceUrl,
    );
  }

  @override
  Override overrideWith(MessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesNotifierProvider._internal(
        () => create()
          ..suffix = suffix
          ..instanceUrl = instanceUrl,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        suffix: suffix,
        instanceUrl: instanceUrl,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MessagesNotifier,
      List<ShipmentMessage>> createElement() {
    return _MessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesNotifierProvider &&
        other.suffix == suffix &&
        other.instanceUrl == instanceUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, suffix.hashCode);
    hash = _SystemHash.combine(hash, instanceUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ShipmentMessage>> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _MessagesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MessagesNotifier,
        List<ShipmentMessage>> with MessagesNotifierRef {
  _MessagesNotifierProviderElement(super.provider);

  @override
  String get suffix => (origin as MessagesNotifierProvider).suffix;
  @override
  String get instanceUrl => (origin as MessagesNotifierProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
