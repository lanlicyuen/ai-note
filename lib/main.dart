
import 'package:flutter/material.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AiNoteApp());
}

class AiNoteApp extends StatelessWidget {
  const AiNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
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
