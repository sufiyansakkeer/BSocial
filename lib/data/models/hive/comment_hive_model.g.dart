// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommentHiveModelAdapter extends TypeAdapter<CommentHiveModel> {
  @override
  final int typeId = 5;

  @override
  CommentHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommentHiveModel(
      commentId: fields[0] as String,
      postId: fields[1] as String,
      uid: fields[2] as String,
      username: fields[3] as String,
      text: fields[4] as String,
      profilePic: fields[5] as String,
      datePublished: fields[6] as DateTime,
      lastUpdated: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CommentHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.commentId)
      ..writeByte(1)
      ..write(obj.postId)
      ..writeByte(2)
      ..write(obj.uid)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.profilePic)
      ..writeByte(6)
      ..write(obj.datePublished)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
