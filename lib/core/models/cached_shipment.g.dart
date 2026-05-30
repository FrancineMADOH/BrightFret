// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_shipment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedShipmentAdapter extends TypeAdapter<CachedShipment> {
  @override
  final int typeId = 0;

  @override
  CachedShipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedShipment(
      suffix: fields[0] as String,
      instanceUrl: fields[1] as String,
      trackingCode: fields[2] as String,
      status: fields[3] as String,
      transportType: fields[4] as String,
      cachedAt: fields[5] as DateTime,
      eventsJson: fields[6] as String,
      origin: fields[7] as String?,
      destination: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedShipment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.suffix)
      ..writeByte(1)
      ..write(obj.instanceUrl)
      ..writeByte(2)
      ..write(obj.trackingCode)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.transportType)
      ..writeByte(5)
      ..write(obj.cachedAt)
      ..writeByte(6)
      ..write(obj.eventsJson)
      ..writeByte(7)
      ..write(obj.origin)
      ..writeByte(8)
      ..write(obj.destination);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedShipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
