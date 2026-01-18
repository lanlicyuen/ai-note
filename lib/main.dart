
import 'package:flutter/material.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:myapp/providers/note_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appSettings = AppSettings();

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
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
