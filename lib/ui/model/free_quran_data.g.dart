// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_quran_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FreeQuranDataAdapter extends TypeAdapter<FreeQuranData> {
  @override
  final int typeId = 0;

  @override
  FreeQuranData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FreeQuranData(
      nodes: (fields[0] as List?)?.cast<FreeQuranNode>(),
    );
  }

  @override
  void write(BinaryWriter writer, FreeQuranData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.nodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeQuranDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FreeQuranNodeAdapter extends TypeAdapter<FreeQuranNode> {
  @override
  final int typeId = 1;

  @override
  FreeQuranNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FreeQuranNode(
      id: fields[0] as String?,
      databaseId: fields[1] as int?,
      date: fields[2] as DateTime?,
      title: fields[3] as String?,
      listenQuran: fields[4] as ListenQuran?,
    );
  }

  @override
  void write(BinaryWriter writer, FreeQuranNode obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.databaseId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.listenQuran);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeQuranNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListenQuranAdapter extends TypeAdapter<ListenQuran> {
  @override
  final int typeId = 2;

  @override
  ListenQuran read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListenQuran(
      listenQuranDescription: fields[0] as String?,
      quranAudio: fields[1] as QuranAudio?,
    );
  }

  @override
  void write(BinaryWriter writer, ListenQuran obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.listenQuranDescription)
      ..writeByte(1)
      ..write(obj.quranAudio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListenQuranAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuranAudioAdapter extends TypeAdapter<QuranAudio> {
  @override
  final int typeId = 3;

  @override
  QuranAudio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranAudio(
      node: fields[0] as MediaNode?,
    );
  }

  @override
  void write(BinaryWriter writer, QuranAudio obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.node);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranAudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
