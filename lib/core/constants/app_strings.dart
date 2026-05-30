/// ARB key constants for type-safe access to localised strings.
/// Usage: `AppLocalizations.of(context)!.trackYourShipment`
/// Widgets use these as references; replace raw string literals in F0.6.
abstract class AppStrings {
  // App
  static const String appName = 'appName';

  // Common actions
  static const String cancel = 'cancel';
  static const String confirm = 'confirm';
  static const String retry = 'retry';
  static const String close = 'close';
  static const String save = 'save';
  static const String loading = 'loading';
  static const String viewAll = 'viewAll';

  // Home / tracking
  static const String trackYourShipment = 'trackYourShipment';
  static const String enterTrackingCode = 'enterTrackingCode';
  static const String scanQrCode = 'scanQrCode';
  static const String myShipments = 'myShipments';
  static const String recentShipments = 'recentShipments';
  static const String saveShipment = 'saveShipment';
  static const String unlockDetails = 'unlockDetails';
  static const String followFirstShipment = 'followFirstShipment';

  // Shipment status labels
  static const String statusActive = 'statusActive';
  static const String statusDelivered = 'statusDelivered';
  static const String statusWarning = 'statusWarning';
  static const String statusError = 'statusError';
  static const String statusArchived = 'statusArchived';

  // Transport types
  static const String transportAir = 'transportAir';
  static const String transportSea = 'transportSea';

  // Auth
  static const String phoneVerification = 'phoneVerification';
  static const String enterPhoneLastDigits = 'enterPhoneLastDigits';
  static const String verificationError = 'verificationError';
  static const String tooManyAttempts = 'tooManyAttempts';

  // Offline banners
  static const String offlineDataBanner = 'offlineDataBanner';
  static const String offlineDocumentsUnavailable = 'offlineDocumentsUnavailable';
  static const String offlineMessagingUnavailable = 'offlineMessagingUnavailable';

  // Error screens
  static const String errorUnknownForwarderTitle = 'errorUnknownForwarderTitle';
  static const String errorUnknownForwarderBody = 'errorUnknownForwarderBody';
  static const String errorNotFoundTitle = 'errorNotFoundTitle';
  static const String errorNotFoundBody = 'errorNotFoundBody';
  static const String errorNetworkTitle = 'errorNetworkTitle';
  static const String errorNetworkBody = 'errorNetworkBody';

  // Claim
  static const String claimLost = 'claimLost';
  static const String claimDamaged = 'claimDamaged';
  static const String claimDelay = 'claimDelay';
  static const String claimSubmit = 'claimSubmit';

  // Bottom navigation tabs
  static const String tabHome = 'tabHome';
  static const String tabUpdates = 'tabUpdates';
  static const String tabSettings = 'tabSettings';

  // Relative time (used by BfShipmentCard)
  static const String justNow = 'justNow';
  static const String minutesAgo = 'minutesAgo';
  static const String hoursAgo = 'hoursAgo';
  static const String daysAgo = 'daysAgo';
  static const String updatedAt = 'updatedAt';
}
