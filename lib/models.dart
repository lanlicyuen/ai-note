
import 'package:flutter/material.dart';

class Folder {
  String id;
  String name;
  Color color;
  DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });
}

class Note {
  String id;
  String title;
  String content;
  String? folderId;
  DateTime lastModified;
  bool isArchived;

  Note({
    required this.id,
    this.title = 'Untitled Note',
    required this.content,
    this.folderId,
    required this.lastModified,
    this.isArchived = false,
  });
}
