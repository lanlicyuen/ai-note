
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/models.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/screens/archived_notes_screen.dart';
import 'package:myapp/screens/folder_screen.dart';
import 'package:myapp/screens/note_editor_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _hoveredFolderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AiNote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchivedNotesScreen()));
            },
            tooltip: 'Archived Notes',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, 'Folders', () => _showAddFolderDialog(context)),
              const SizedBox(height: 16),
              _buildFolderGrid(context, noteProvider.folders),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Uncategorized Notes', null),
              const SizedBox(height: 16),
              _buildUncategorizedNotesGrid(context, noteProvider.uncategorizedNotes),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteEditorScreen()));
        },
        tooltip: 'New Note',
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: darkTextColor),
            onPressed: onAdd,
          ),
      ],
    );
  }

  Widget _buildFolderGrid(BuildContext context, List<Folder> folders) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: folders.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final folder = folders[index];
        return DragTarget<Note>(
          onWillAccept: (note) => note?.folderId != folder.id,
          onAccept: (note) {
            noteProvider.moveNoteToFolder(note.id, folder.id);
            setState(() => _hoveredFolderId = null);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Moved "${note.title}" to "${folder.name}"'),
              backgroundColor: folder.color,
            ));
          },
          onMove: (details) => setState(() => _hoveredFolderId = folder.id),
          onLeave: (data) => setState(() => _hoveredFolderId = null),
          builder: (context, candidateData, rejectedData) {
            final isHovered = _hoveredFolderId == folder.id;
            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FolderScreen(folder: folder)));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: folder.color,
                  borderRadius: BorderRadius.circular(20),
                  border: isHovered ? Border.all(color: accentColor, width: 3) : null,
                  boxShadow: [
                    BoxShadow(
                      color: folder.color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    folder.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.primaries[0];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Folder Name')),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Colors.primaries.length,
                  itemBuilder: (context, index) {
                    final color = Colors.primaries[index];
                    return GestureDetector(
                      onTap: () => selectedColor = color,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: selectedColor == color ? accentColor : Colors.transparent, width: 3),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Provider.of<NoteProvider>(context, listen: false).createFolder(nameController.text, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUncategorizedNotesGrid(BuildContext context, List<Note> notes) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (notes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No uncategorized notes. Great job!", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return MasonryGridView.count(
      crossAxisCount: 2,
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) {
        final note = notes[index];
        return _buildNoteItem(note, noteProvider);
      },
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  void _showMoveToFolderDialog(Note note, NoteProvider noteProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to Folder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: noteProvider.folders.length,
              itemBuilder: (context, index) {
                final folder = noteProvider.folders[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: folder.color),
                  title: Text(folder.name),
                  onTap: () {
                    noteProvider.moveNoteToFolder(note.id, folder.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Moved "${note.title}" to "${folder.name}"'),
                      backgroundColor: folder.color,
                    ));
                  },
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        );
      },
    );
  }

  Dismissible _buildNoteItem(Note note, NoteProvider noteProvider) {
    return Dismissible(
      key: ValueKey(note.id),
      background: _buildDismissibleBackground(true),
      secondaryBackground: _buildDismissibleBackground(false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showMoveToFolderDialog(note, noteProvider);
          return false; // Prevents the item from being dismissed
        } else {
          return true; // Allows dismissal for the delete action
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteNoteWithUndo(note, noteProvider);
        }
      },
      child: Draggable<Note>(
        data: note,
        feedback: Material(
          elevation: 4.0,
          child: Card(
            color: creamyWhite.withOpacity(0.8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(note.title, style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
          ),
        ),
        childWhenDragging: Card(color: Colors.grey.shade200),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  const SizedBox(height: 4),
                  Text(note.content, maxLines: 5, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground(bool isPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue : Colors.red,
        borderRadius: BorderRadius.circular(4), // Match card's default border radius
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.5), // Approximate margin for card
      alignment: isPrimary ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.folder, color: Colors.white),
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
