
import 'package:flutter/material.dart';
import 'package:myapp/models.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  final List<Folder> _folders = [];

  Note? _lastRemovedNote;
  int? _lastRemovedNoteIndex;

  List<Note> get notes => _notes.where((note) => !note.isArchived).toList();
  List<Folder> get folders => _folders;
  List<Note> get archivedNotes => _notes.where((note) => note.isArchived).toList();

  List<Note> get uncategorizedNotes =>
      notes.where((note) => note.folderId == null).toList();

  NoteProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _folders.addAll([
      Folder(id: 'f1', name: 'Journal', color: Colors.pink.shade100, createdAt: DateTime.now()),
      Folder(id: 'f2', name: 'Work Ideas', color: Colors.blue.shade100, createdAt: DateTime.now()),
      Folder(id: 'f3', name: 'Recipes', color: Colors.green.shade100, createdAt: DateTime.now()),
    ]);

    _notes.addAll([
      Note(id: 'n1', title: 'My First Note', content: 'This is the content of my first note!', lastModified: DateTime.now().subtract(const Duration(days: 1)), folderId: 'f1'),
      Note(id: 'n2', title: 'Meeting Thoughts', content: 'Brainstorming session about the new project.', lastModified: DateTime.now(), folderId: 'f2'),
      Note(id: 'n3', title: 'Grocery List', content: '* Milk\n* Bread\n* Eggs', lastModified: DateTime.now().subtract(const Duration(hours: 2))),
      Note(id: 'n4', title: 'Archived Idea', content: 'This is an old idea.', lastModified: DateTime.now().subtract(const Duration(days: 10)), isArchived: true),
    ]);
    notifyListeners();
  }

  void saveNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    notifyListeners();
  }
  
  void createFolder(String name, Color color) {
    final newFolder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    _folders.add(newFolder);
    notifyListeners();
  }

  void moveNoteToFolder(String noteId, String folderId) {
    final note = _notes.firstWhere((n) => n.id == noteId);
    note.folderId = folderId;
    notifyListeners();
  }

  List<Note> getNotesForFolder(String folderId) {
    return notes.where((note) => note.folderId == folderId).toList();
  }

  void toggleArchiveStatus(String noteId) {
    final note = _notes.firstWhere((n) => n.id == noteId);
    note.isArchived = !note.isArchived;
    notifyListeners();
  }

  void deleteNote(String noteId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _lastRemovedNote = _notes[index];
      _lastRemovedNoteIndex = index;
      _notes.removeAt(index);
      notifyListeners();
    }
  }

  void undoDelete() {
    if (_lastRemovedNote != null && _lastRemovedNoteIndex != null) {
      _notes.insert(_lastRemovedNoteIndex!, _lastRemovedNote!);
      _lastRemovedNote = null;
      _lastRemovedNoteIndex = null;
      notifyListeners();
    }
  }
}
