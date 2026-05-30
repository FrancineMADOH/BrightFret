// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUpdateAdapter extends TypeAdapter<AppUpdate> {
  @override
  final int typeId = 4;

  @override
  AppUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUpdate(
      trackingCode: fields[0] as String,
      message: fields[1] as String,
      detectedAt: fields[2] as DateTime,
      isRead: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppUpdate obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.trackingCode)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.detectedAt)
      ..writeByte(3)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
