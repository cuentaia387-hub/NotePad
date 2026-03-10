import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Definición manual del TypeAdapter de Hive para evitar dependencias
// de generación de código como build_runner en el proyecto final.
class Note {
  final String id;
  String title;
  String content;
  int colorValue;
  bool isPinned;
  bool isArchived;
  final DateTime createdAt;
  DateTime modifiedAt;
  List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.modifiedAt,
    this.tags = const [],
  });

  Color get color => Color(colorValue);
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      colorValue: fields[3] as int,
      isPinned: fields[4] as bool,
      isArchived: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      modifiedAt: fields[7] as DateTime,
      tags: (fields[8] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.isPinned)
      ..writeByte(5)
      ..write(obj.isArchived)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.modifiedAt)
      ..writeByte(8)
      ..write(obj.tags);
  }
}
