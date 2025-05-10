// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatRoomHiveModelAdapter extends TypeAdapter<ChatRoomHiveModel> {
  @override
  final int typeId = 3;

  @override
  ChatRoomHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatRoomHiveModel(
      roomId: fields[0] as String,
      participants: (fields[1] as List).cast<String>(),
      lastMessageTime: fields[2] as DateTime,
      lastMessage: fields[3] as String,
      lastMessageSenderId: fields[4] as String,
      lastUpdated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatRoomHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.participants)
      ..writeByte(2)
      ..write(obj.lastMessageTime)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.lastMessageSenderId)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
