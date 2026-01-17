
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  void _saveNote() {
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
  }

  Future<void> _polishText() async {
    setState(() => _isAiPolishing = true);
    final settings = Provider.of<AppSettings>(context, listen: false);
    final apiService = ApiService();

    final polishedText = await apiService.polishText(
      text: _contentController.text,
      apiKey: settings.apiKey,
      customPrompt: settings.customPrompt,
    );
    
    if (mounted) {
       _contentController.text = polishedText;
       setState(() => _isAiPolishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            // Check if there are unsaved changes
            if ((_contentController.text.isNotEmpty && widget.note == null) || 
                (widget.note != null && (_contentController.text != widget.note!.content || _titleController.text != widget.note!.title))) {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Unsaved Changes'),
                content: const Text('Do you want to save your changes before leaving?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Discard')),
                  ElevatedButton(onPressed: () {
                     _saveNote();
                     Navigator.of(ctx).pop(true);
                  }, child: const Text('Save')),
                ],
              )).then((saved) {
                if (saved == true || saved == null) { // saved or dialog dismissed
                   Navigator.of(context).pop();
                }
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Note Title',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
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
            onPressed: _saveNote,
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
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _polishText,
        tooltip: 'AI Polish',
        child: const Icon(Icons.auto_awesome_rounded, size: 28),
      ),
    );
  }
}

class ApiService {
  static const String _baseUrl = "https://api.deepseek.com/v1/chat/completions";

  Future<String> polishText({
    required String text,
    required String apiKey,
    required String customPrompt,
  }) async {
    if (apiKey.isEmpty) {
      return 'Error: API Key is not set in Settings.';
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-coder',
          'messages': [
            {'role': 'system', 'content': customPrompt},
            {'role': 'user', 'content': text},
          ],
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['choices'][0]['message']['content'];
      } else {
        final errorBody = jsonDecode(response.body);
        return 'Error ${response.statusCode}: ${errorBody['error']?['message'] ?? 'Failed to polish text.'}';
      }
    } catch (e) {
      return 'Error: Failed to connect to the AI service. $e';
    }
  }
}
