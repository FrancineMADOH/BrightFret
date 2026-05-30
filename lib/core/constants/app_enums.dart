/// Status of a freight shipment, mapped to semantic colours in [AppColors].
enum ShipmentStatus { active, delivered, warning, error, archived }

/// Transport mode for a shipment (air or sea).
enum TransportType { air, sea }

/// Visual state of a step inside [BfTimelineStep].
enum TimelineStepState { past, current, future }
