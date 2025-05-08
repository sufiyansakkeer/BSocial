// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostHiveModelAdapter extends TypeAdapter<PostHiveModel> {
  @override
  final int typeId = 2;

  @override
  PostHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostHiveModel(
      postId: fields[0] as String,
      uid: fields[1] as String,
      username: fields[2] as String,
      description: fields[3] as String,
      postUrl: fields[4] as String,
      profImage: fields[5] as String,
      datePublished: fields[6] as DateTime,
      likes: (fields[7] as List).cast<String>(),
      lastUpdated: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PostHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.postId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.postUrl)
      ..writeByte(5)
      ..write(obj.profImage)
      ..writeByte(6)
      ..write(obj.datePublished)
      ..writeByte(7)
      ..write(obj.likes)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
