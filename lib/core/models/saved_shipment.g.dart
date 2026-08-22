// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_shipment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedShipmentAdapter extends TypeAdapter<SavedShipment> {
  @override
  final int typeId = 1;

  @override
  SavedShipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedShipment(
      trackingCode: fields[0] as String,
      suffix: fields[1] as String,
      instanceUrl: fields[2] as String,
      lastStatus: fields[3] as String,
      lastSeen: fields[4] as DateTime,
      isAuthenticated: fields[5] as bool,
      lastEventCount: fields[7] as int?,
    )..lastClaimStatus = fields[6] as String?;
  }

  @override
  void write(BinaryWriter writer, SavedShipment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.trackingCode)
      ..writeByte(1)
      ..write(obj.suffix)
      ..writeByte(2)
      ..write(obj.instanceUrl)
      ..writeByte(3)
      ..write(obj.lastStatus)
      ..writeByte(4)
      ..write(obj.lastSeen)
      ..writeByte(5)
      ..write(obj.isAuthenticated)
      ..writeByte(6)
      ..write(obj.lastClaimStatus)
      ..writeByte(7)
      ..write(obj.lastEventCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedShipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
