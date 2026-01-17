
import 'package:flutter/material.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // It's good practice to have a single AppSettings instance
  // that can be initialized once and used throughout the app.
  final appSettings = AppSettings();
  // The AppSettings constructor calls _loadSettings, which is async.
  // We don't necessarily need to wait for it here, as the Consumer
  // will rebuild when the settings are loaded.

  runApp(AiNoteApp(appSettings: appSettings));
}

class AiNoteApp extends StatelessWidget {
  const AiNoteApp({super.key, required this.appSettings});

  final AppSettings appSettings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appSettings),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'AiNote',
            theme: lightTheme, // Your light theme
            darkTheme: darkTheme, // Your new dark theme
            themeMode: settings.themeMode, // Controlled by the provider
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
