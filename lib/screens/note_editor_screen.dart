
import 'package:flutter/material.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:provider/provider.dart';

// Import Task model

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _saveNote();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final title = _titleController.text;
    final content = _contentController.text;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (title.isEmpty && content.isEmpty) {
      if (widget.note != null) {
        noteProvider.deleteNote(widget.note!.id);
      }
      return; // Don't save empty notes
    }

    final noteToSave = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      lastModified: DateTime.now(),
      folderId: widget.note?.folderId,
    );

    noteProvider.saveNote(noteToSave);
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSaving ? const Text('Saving...') : Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_rounded, size: 28),
            onPressed: () {
              _saveNote();
              Navigator.pop(context);
            },
            tooltip: 'Save & Close',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Title',
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Start writing your note...',
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
