// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHiveModelAdapter extends TypeAdapter<UserHiveModel> {
  @override
  final int typeId = 1;

  @override
  UserHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHiveModel(
      email: fields[0] as String,
      uid: fields[1] as String,
      photoUrl: fields[2] as String,
      userName: fields[3] as String,
      followers: (fields[4] as List).cast<String>(),
      following: (fields[5] as List).cast<String>(),
      lastUpdated: fields[7] as DateTime,
      status: fields[6] as String,
      bio: fields[8] as String,
      isMfaEnabled: fields[9] as bool,
      isEmailVerified: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.photoUrl)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.followers)
      ..writeByte(5)
      ..write(obj.following)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.bio)
      ..writeByte(9)
      ..write(obj.isMfaEnabled)
      ..writeByte(10)
      ..write(obj.isEmailVerified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
