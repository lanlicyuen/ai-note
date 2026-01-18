
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:provider/provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _statusText; // To show 'Saving...' or 'Generating...'

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    // We save the note when the user leaves the screen.
    _saveNote();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_statusText != null) return; // Don't save if another operation is in progress

    if (!mounted) return;
    setState(() => _statusText = 'Saving...');

    final title = _titleController.text;
    final content = _contentController.text;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (title.isEmpty && content.isEmpty) {
      if (widget.note != null) {
        noteProvider.deleteNote(widget.note!.id);
      }
      if(mounted) setState(() => _statusText = null);
      return; // Don't save empty notes
    }

    final noteToSave = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      lastModified: DateTime.now(),
      folderId: widget.note?.folderId,
    );

    await noteProvider.saveNote(noteToSave);

    if (!mounted) return;
    setState(() => _statusText = null);
  }

  Future<void> _runAiPrompt(String presetPrompt) async {
    if (!mounted) return;
    setState(() => _statusText = 'Generating...');

    final settings = Provider.of<AppSettings>(context, listen: false);
    final currentContent = _contentController.text;
    final fullPrompt = '$presetPrompt\n\n---\n\n$currentContent';

    if (settings.apiKey.isEmpty ||
        settings.apiEndpoint.isEmpty ||
        settings.apiDeploymentName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API settings are not configured. Please check Settings.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _statusText = null);
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${settings.apiEndpoint}/openai/deployments/${settings.apiDeploymentName}/chat/completions?api-version=2023-07-01-preview'),
        headers: {
          'Content-Type': 'application/json',
          'api-key': settings.apiKey,
        },
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': fullPrompt}
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final generatedText =
            responseBody['choices'][0]['message']['content'].trim();
        _contentController.text = generatedText;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calling AI service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _statusText = null);
      }
    }
  }

  void _showAiBottomSheet() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Generate with AI',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildPromptTile(
                  context, 'Summarize', Icons.summarize, settings.prompt1),
              _buildPromptTile(
                  context, 'Extract Tasks', Icons.checklist, settings.prompt2),
              _buildPromptTile(
                  context, 'Fix Grammar', Icons.spellcheck, settings.prompt3),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromptTile(BuildContext context, String title, IconData icon, String prompt) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        prompt,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pop(context);
        _runAiPrompt(prompt);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_statusText ?? (widget.note == null ? 'New Note' : 'Edit Note')),
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
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none, // Keeps the clean UI
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start writing your note...',
                  border: InputBorder.none, // Keeps the clean UI
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAiBottomSheet,
        tooltip: 'Generate with AI',
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
