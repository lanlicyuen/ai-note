
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// --- THEME AND STYLING --- //

const Color pastelPink = Color(0xFFFDE4E4);
const Color creamyWhite = Color(0xFFFFF8F0);
const Color lightWarmGray = Color(0xFFEAEAEA);
const Color darkTextColor = Color(0xFF5D5D5D);
const Color accentColor = Color(0xFFF5A9A9);

final ThemeData appTheme = ThemeData(
  primaryColor: pastelPink,
  scaffoldBackgroundColor: creamyWhite,
  textTheme: GoogleFonts.latoTextTheme().apply(
    bodyColor: darkTextColor,
    displayColor: darkTextColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: creamyWhite,
    elevation: 0,
    iconTheme: const IconThemeData(color: darkTextColor),
    titleTextStyle: GoogleFonts.lato(
      color: darkTextColor,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    shadowColor: lightWarmGray.withOpacity(0.5),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: accentColor, width: 2),
    ),
    hintStyle: const TextStyle(color: lightWarmGray),
  ),
  iconTheme: const IconThemeData(color: accentColor),
);

// --- MODELS --- //

class Folder {
  String id;
  String name;
  Color color;
  DateTime createdAt;

  Folder({required this.id, required this.name, required this.color, required this.createdAt});
}

class Note {
  String id;
  String title;
  String content;
  String? folderId;
  DateTime lastModified;

  Note({
    required this.id,
    this.title = 'Untitled Note',
    required this.content,
    this.folderId,
    required this.lastModified,
  });
}


// --- SERVICES --- //

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

// --- STATE MANAGEMENT (PROVIDERS) --- //

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _apiKey = '';
  String _customPrompt = 'Please polish the following text and return it in Markdown format.';

  String get apiKey => _apiKey;
  String get customPrompt => _customPrompt;

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString('apiKey') ?? 'sk-83b0f224c3e844ad843beecbd64e3adb';
    _customPrompt = _prefs.getString('customPrompt') ?? 'Please polish the following text and return it in Markdown format.';
    notifyListeners();
  }

  Future<void> updateApiKey(String newKey) async {
    _apiKey = newKey;
    await _prefs.setString('apiKey', newKey);
    notifyListeners();
  }

  Future<void> updateCustomPrompt(String newPrompt) async {
    _customPrompt = newPrompt;
    await _prefs.setString('customPrompt', newPrompt);
    notifyListeners();
  }
}

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  final List<Folder> _folders = [];

  List<Note> get notes => _notes;
  List<Folder> get folders => _folders;
  List<Note> get recentNotes =>
      _notes.take(5).toList()..sort((a, b) => b.lastModified.compareTo(a.lastModified));

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

  List<Note> getNotesForFolder(String folderId) {
    return _notes.where((note) => note.folderId == folderId).toList();
  }
}

// --- MAIN APP --- //

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings._loadSettings();
  if (settings.apiKey.isEmpty) {
    await settings.updateApiKey('sk-83b0f224c3e844ad843beecbd64e3adb');
  } 

  runApp(AiNoteApp(settings: settings));
}

class AiNoteApp extends StatelessWidget {
  final AppSettings settings;
  const AiNoteApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        title: 'AiNote',
        theme: appTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// --- SCREENS --- //

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AiNote'),
        actions: [
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
              _buildSectionHeader(context, 'Recent Notes', null),
              const SizedBox(height: 16),
              _buildRecentNotesList(context, noteProvider.recentNotes),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen()));
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
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: accentColor),
            onPressed: onAdd,
            tooltip: 'Add Folder',
          ),
      ],
    );
  }

  Widget _buildFolderGrid(BuildContext context, List<Folder> folders) {
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
        return InkWell(
          onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => FolderScreen(folder: folder)));
          },
          borderRadius: BorderRadius.circular(20),
          child: Card(
            color: folder.color,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.folder_rounded, size: 40, color: Colors.white),
                  Text(
                    folder.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showAddFolderDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Folder'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Folder Name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: darkTextColor)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // For simplicity, assign a random pastel color
                  final color = Colors.primaries[DateTime.now().millisecond % Colors.primaries.length].shade100;
                  Provider.of<NoteProvider>(context, listen: false).createFolder(nameController.text, color);
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

  Widget _buildRecentNotesList(BuildContext context, List<Note> notes) {
    if (notes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No recent notes. Create one!", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      itemCount: notes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
            subtitle: Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
            },
          ),
        );
      },
    );
  }
}

class FolderScreen extends StatelessWidget {
  final Folder folder;
  const FolderScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.getNotesForFolder(folder.id);
          if (notes.isEmpty) {
            return const Center(child: Text('This folder is empty.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                 margin: const EdgeInsets.only(bottom: 12),
                 child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
                  },
                ),
              );
            },
          );
        },
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(
            note: Note(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: '',
              lastModified: DateTime.now(),
              folderId: folder.id,
            ),
          )));
        },
        tooltip: 'New Note in Folder',
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

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
              ? Markdown(data: _contentController.text, selectable: true,)
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _promptController = TextEditingController(text: settings.customPrompt);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    settings.updateApiKey(_apiKeyController.text.trim());
    settings.updateCustomPrompt(_promptController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings Saved!'), backgroundColor: accentColor),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('API Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Provide your DeepSeek API key below. This is stored securely on your device.'),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'DeepSeek API Key',
              hintText: 'Enter your API Key',
            ),
          ),
          const SizedBox(height: 24),
          Text('AI Prompt', style: Theme.of(context).textTheme.headlineSmall),
           const SizedBox(height: 8),
          const Text('Customize the instructions given to the AI when polishing your text.'),
          const SizedBox(height: 16),
          TextField(
            controller: _promptController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Custom System Prompt',
              hintText: 'e.g., "Polish this text..."',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
