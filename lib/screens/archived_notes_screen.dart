
import 'package:flutter/material.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/screens/note_editor_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

class ArchivedNotesScreen extends StatelessWidget {
  const ArchivedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Notes'),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final archivedNotes = noteProvider.archivedNotes;
          if (archivedNotes.isEmpty) {
            return const Center(child: Text('No archived notes.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archivedNotes.length,
            itemBuilder: (context, index) {
              final note = archivedNotes[index];
              return Dismissible(
                key: ValueKey(note.id),
                background: Container(
                  color: Colors.green.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.unarchive_rounded, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    noteProvider.toggleArchiveStatus(note.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unarchived "${note.title}"'), backgroundColor: Colors.green.shade700),
                    );
                  } else {
                     noteProvider.deleteNote(note.id);
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Permanently deleted "${note.title}"'), backgroundColor: darkTextColor),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
