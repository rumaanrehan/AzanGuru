// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_classes_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveClassesDataAdapter extends TypeAdapter<LiveClassesData> {
  @override
  final int typeId = 5;

  @override
  LiveClassesData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveClassesData(
      id: fields[0] as String?,
      generalOptionsFields: fields[1] as GeneralOptionsFields?,
    );
  }

  @override
  void write(BinaryWriter writer, LiveClassesData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.generalOptionsFields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveClassesDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeneralOptionsFieldsAdapter extends TypeAdapter<GeneralOptionsFields> {
  @override
  final int typeId = 6;

  @override
  GeneralOptionsFields read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeneralOptionsFields(
      liveClassesLink: fields[0] as LiveClassesLink?,
      liveClassInfo: fields[1] as String?,
      liveClassesAvailability: (fields[2] as List?)?.cast<String>(),
      askToLiveTeacher: fields[3] as String?,
      liveClassInfoSection: (fields[4] as List?)?.cast<LiveClassInfoSection>(),
    );
  }

  @override
  void write(BinaryWriter writer, GeneralOptionsFields obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.liveClassesLink)
      ..writeByte(1)
      ..write(obj.liveClassInfo)
      ..writeByte(2)
      ..write(obj.liveClassesAvailability)
      ..writeByte(3)
      ..write(obj.askToLiveTeacher)
      ..writeByte(4)
      ..write(obj.liveClassInfoSection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralOptionsFieldsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LiveClassInfoSectionAdapter extends TypeAdapter<LiveClassInfoSection> {
  @override
  final int typeId = 7;

  @override
  LiveClassInfoSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveClassInfoSection(
      availableForNonSubscribers: fields[0] as bool?,
      whichDay: (fields[1] as List?)?.cast<String>(),
      addMoreRanges: (fields[2] as List?)?.cast<AddMoreRange>(),
    );
  }

  @override
  void write(BinaryWriter writer, LiveClassInfoSection obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.availableForNonSubscribers)
      ..writeByte(1)
      ..write(obj.whichDay)
      ..writeByte(2)
      ..write(obj.addMoreRanges);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveClassInfoSectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddMoreRangeAdapter extends TypeAdapter<AddMoreRange> {
  @override
  final int typeId = 8;

  @override
  AddMoreRange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddMoreRange(
      endTime: fields[0] as String?,
      startTime: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AddMoreRange obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.endTime)
      ..writeByte(1)
      ..write(obj.startTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddMoreRangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LiveClassesLinkAdapter extends TypeAdapter<LiveClassesLink> {
  @override
  final int typeId = 9;

  @override
  LiveClassesLink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveClassesLink(
      title: fields[0] as String?,
      url: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LiveClassesLink obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveClassesLinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
