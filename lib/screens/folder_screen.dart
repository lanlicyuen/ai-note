
import 'package:flutter/material.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/screens/note_editor_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

class FolderScreen extends StatefulWidget {
  final Folder folder;
  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.getNotesForFolder(widget.folder.id);
          if (notes.isEmpty) {
            return const Center(child: Text('This folder is empty.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteListItem(note, noteProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(
                        note: Note(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          content: '',
                          lastModified: DateTime.now(),
                          folderId: widget.folder.id,
                        ),
                      )));
        },
        tooltip: 'New Note in Folder',
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildNoteListItem(Note note, NoteProvider noteProvider) {
    return Dismissible(
      key: ValueKey(note.id),
      background: _buildDismissibleBackground(isPrimary: true),
      secondaryBackground: _buildDismissibleBackground(isPrimary: false),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteNoteWithUndo(note, noteProvider);
        } else {
          _archiveNote(note, noteProvider);
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
  }

  Container _buildDismissibleBackground({required bool isPrimary}) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue.shade300 : Colors.red.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isPrimary ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isPrimary ? Icons.archive_rounded : Icons.delete_forever_rounded, color: Colors.white),
          const SizedBox(height: 4),
          Text(isPrimary ? 'Archive' : 'Delete', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _deleteNoteWithUndo(Note note, NoteProvider noteProvider) {
    noteProvider.deleteNote(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${note.title}"'),
        action: SnackBarAction(label: 'UNDO', onPressed: () => noteProvider.undoDelete()),
        backgroundColor: darkTextColor,
      ),
    );
  }

  void _archiveNote(Note note, NoteProvider noteProvider) {
    noteProvider.toggleArchiveStatus(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archived "${note.title}"'), backgroundColor: Colors.blue.shade700),
    );
  }
}

