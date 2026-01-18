
import 'package:flutter/material.dart';

class Note {
  String id;
  String title;
  String content;
  DateTime lastModified;
  String? folderId;
  bool isArchived;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    required this.lastModified,
    this.folderId,
    this.isArchived = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        lastModified: DateTime.parse(json['lastModified']),
        folderId: json['folderId'],
        isArchived: json['isArchived'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'lastModified': lastModified.toIso8601String(),
        'folderId': folderId,
        'isArchived': isArchived,
      };
}

class Folder {
  String id;
  String name;
  Color color;

  Folder({required this.id, required this.name, required this.color});

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.value,
      };
}

class TodoTask {
  String id;
  String content;
  bool isCompleted;

  TodoTask({
    required this.id,
    required this.content,
    this.isCompleted = false,
  });

  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
        id: json['id'],
        content: json['content'],
        isCompleted: json['isCompleted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isCompleted': isCompleted,
      };
}
