
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Folder> _folders = [];
  List<TodoTask> _tasks = [];
  Note? _lastDeletedNote;

  List<Note> get notes => _notes.where((note) => !note.isArchived).toList();
  List<Note> get archivedNotes => _notes.where((note) => note.isArchived).toList();
  List<Folder> get folders => _folders;
  List<TodoTask> get tasks => _tasks;
  List<Note> get uncategorizedNotes => notes.where((note) => note.folderId == null).toList();

  NoteProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final notesString = prefs.getString('notes') ?? '[]';
    _notes = (jsonDecode(notesString) as List).map((data) => Note.fromJson(data)).toList();

    final foldersString = prefs.getString('folders') ?? '[]';
    _folders = (jsonDecode(foldersString) as List).map((data) => Folder.fromJson(data)).toList();

    final tasksString = prefs.getString('tasks') ?? '[]';
    _tasks = (jsonDecode(tasksString) as List).map((data) => TodoTask.fromJson(data)).toList();

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(_notes.map((n) => n.toJson()).toList()));
    await prefs.setString('folders', jsonEncode(_folders.map((f) => f.toJson()).toList()));
    await prefs.setString('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }

  List<Note> getNotesForFolder(String folderId) {
    return notes.where((note) => note.folderId == folderId).toList();
  }

  Future<void> saveNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    await _saveData();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _lastDeletedNote = _notes[index];
      _notes.removeAt(index);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedNote != null) {
      await saveNote(_lastDeletedNote!);
      _lastDeletedNote = null;
    }
  }

  Future<void> toggleArchiveStatus(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isArchived = !_notes[index].isArchived;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> createFolder(String name, Color color) async {
    final newFolder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    );
    _folders.add(newFolder);
    await _saveData();
    notifyListeners();
  }

  Future<void> moveNoteToFolder(String noteId, String folderId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index].folderId = folderId;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> addTask(String content) async {
    final newTask = TodoTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
    );
    _tasks.add(newTask);
    await _saveData();
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveData();
    notifyListeners();
  }
}
