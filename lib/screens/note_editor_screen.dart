
// import 'package:firebase_ai/firebase_ai.dart'; // Temporarily disabled
import 'package:flutter/material.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isAiPolishing = false;
  bool _isMarkdownPreview = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? 'Untitled Note');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNoteAndExit() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final note = widget.note ??
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: '',
          lastModified: DateTime.now(),
        );

    note.title = _titleController.text.trim().isEmpty ? 'Untitled Note' : _titleController.text.trim();
    note.content = _contentController.text;
    note.lastModified = DateTime.now();

    noteProvider.saveNote(note);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note Saved!'), backgroundColor: accentColor),
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /* // Temporarily disable AI feature due to build issues
  Future<void> _polishText() async {
    if (!mounted) return;
    setState(() => _isAiPolishing = true);

    final settings = Provider.of<AppSettings>(context, listen: false);
    String polishedText = '';

    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash', // A fast and capable model
        systemInstruction: Content.text(settings.customPrompt),
      );

      final response = await model.generateContent([
        Content.text(_contentController.text),
      ]);

      polishedText = response.text ?? 'AI model returned no text.';

    } catch (e) {
      polishedText = 'Error polishing text: $e';
    } finally {
      if (mounted) {
        _contentController.text = polishedText;
        setState(() => _isAiPolishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(polishedText.startsWith('Error') ? polishedText : 'Text polished by AI!')),
        );
      }
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final hasUnsavedChanges = (_contentController.text.isNotEmpty && widget.note == null) || 
            (widget.note != null && (_contentController.text != widget.note!.content || _titleController.text != widget.note!.title));

        if (hasUnsavedChanges) {
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('Do you want to save your changes before leaving?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Discard')),
                ElevatedButton(
                  onPressed: () {
                    _saveNoteAndExit();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
          return result ?? false; // if dialog is dismissed, don't pop
        }
        return true; // No changes, so allow pop
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // We handle the back button manually
          title: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Note Title',
              border: InputBorder.none,
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            IconButton(
              icon: Icon(_isMarkdownPreview ? Icons.edit_note_rounded : Icons.visibility_rounded),
              onPressed: () => setState(() => _isMarkdownPreview = !_isMarkdownPreview),
              tooltip: 'Toggle Markdown Preview',
            ),
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _saveNoteAndExit,
              tooltip: 'Save Note',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isAiPolishing
              ? const Center(child: CircularProgressIndicator(color: accentColor))
              : _isMarkdownPreview
                  ? MarkdownBody(data: _contentController.text)
                  : TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Start writing your note here...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                    ),
        ),
        /* // Temporarily disable AI feature due to build issues
        floatingActionButton: FloatingActionButton(
          onPressed: _polishText,
          tooltip: 'AI Polish',
          child: const Icon(Icons.auto_awesome_rounded, size: 28),
        ),
        */
      ),
    );
  }
}
