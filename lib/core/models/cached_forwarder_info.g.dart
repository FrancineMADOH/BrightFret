// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_forwarder_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedForwarderInfoAdapter extends TypeAdapter<CachedForwarderInfo> {
  @override
  final int typeId = 3;

  @override
  CachedForwarderInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedForwarderInfo(
      instanceUrl: fields[0] as String,
      name: fields[1] as String,
      logoUrl: fields[2] as String?,
      primaryColor: fields[3] as String?,
      contactPhone: fields[4] as String?,
      canCreateClaims: fields[6] as bool?,
      cachedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedForwarderInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.instanceUrl)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logoUrl)
      ..writeByte(3)
      ..write(obj.primaryColor)
      ..writeByte(4)
      ..write(obj.contactPhone)
      ..writeByte(6)
      ..write(obj.canCreateClaims)
      ..writeByte(5)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedForwarderInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
