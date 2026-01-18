
import 'package:flutter/material.dart';
import 'package:myapp/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, child) {
          final prompt1Controller = TextEditingController(text: settings.prompt1);
          final prompt2Controller = TextEditingController(text: settings.prompt2);
          final prompt3Controller = TextEditingController(text: settings.prompt3);
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildThemeSetting(context, settings),
              const SizedBox(height: 24),
              _buildPromptSetting(context, settings, prompt1Controller, 'Preset Prompt 1', settings.setPrompt1),
              const SizedBox(height: 16),
              _buildPromptSetting(context, settings, prompt2Controller, 'Preset Prompt 2', settings.setPrompt2),
              const SizedBox(height: 16),
              _buildPromptSetting(context, settings, prompt3Controller, 'Preset Prompt 3', settings.setPrompt3),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context, AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme', style: Theme.of(context).textTheme.titleLarge),
        RadioListTile<ThemeMode>(
          title: const Text('Light Mode'),
          value: ThemeMode.light,
          groupValue: settings.themeMode,
          onChanged: (value) => settings.setTheme(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark Mode'),
          value: ThemeMode.dark,
          groupValue: settings.themeMode,
          onChanged: (value) => settings.setTheme(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          value: ThemeMode.system,
          groupValue: settings.themeMode,
          onChanged: (value) => settings.setTheme(value!),
        ),
      ],
    );
  }

  Widget _buildPromptSetting(BuildContext context, AppSettings settings, TextEditingController controller, String label, Function(String) onSave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your custom AI prompt here...',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12.0),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label saved!')),
              );
              FocusScope.of(context).unfocus(); // Dismiss keyboard
            },
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
