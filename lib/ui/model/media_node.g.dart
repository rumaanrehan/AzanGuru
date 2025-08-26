// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaNodeAdapter extends TypeAdapter<MediaNode> {
  @override
  final int typeId = 4;

  @override
  MediaNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaNode(
      mediaItemId: fields[0] as int?,
      mediaItemUrl: fields[1] as String?,
      title: fields[2] as String?,
      isSelected: fields[3] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaNode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.mediaItemId)
      ..writeByte(1)
      ..write(obj.mediaItemUrl)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
