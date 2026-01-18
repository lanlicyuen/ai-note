import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _controller = TextEditingController();
  final _promptControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _controller.text = widget.note!.content;
    }
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _promptControllers.length; i++) {
      final prompt = prefs.getString('prompt_$i') ?? '';
      _promptControllers[i].text = prompt;
    }
  }

  Future<void> _savePrompts() async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _promptControllers.length; i++) {
      await prefs.setString('prompt_$i', _promptControllers[i].text);
    }
  }

  void _showPromptDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Prompts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return TextField(
                controller: _promptControllers[index],
                decoration: InputDecoration(
                  labelText: 'Prompt ${index + 1}',
                ),
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _savePrompts();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPromptDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) {
                return ElevatedButton(
                  onPressed: () {
                    _controller.text += _promptControllers[index].text;
                  },
                  child: Text('Prompt ${index + 1}'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
