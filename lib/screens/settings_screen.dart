
import 'package:flutter/material.dart';
import 'package:myapp/providers/app_settings.dart';
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
          final apiKeyController = TextEditingController(text: settings.apiKey);
          final promptController = TextEditingController(text: settings.customPrompt);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle(context, 'Theme'),
              _buildThemeSelector(context, settings),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'AI Settings'),
              _buildTextField(
                controller: apiKeyController,
                label: 'Gemini API Key',
                hint: 'Enter your API Key',
                onChanged: (value) => settings.updateApiKey(value),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: promptController,
                label: 'Custom Prompt',
                hint: 'Set your custom prompt for AI generation',
                maxLines: 3,
                onChanged: (value) => settings.updateCustomPrompt(value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, AppSettings settings) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light Mode'),
          value: ThemeMode.light,
          groupValue: settings.themeMode,
          onChanged: (value) => settings.updateThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark Mode'),
          value: ThemeMode.dark,
          groupValue: settings.themeMode,
          onChanged: (value) => settings.updateThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          value: ThemeMode.system,
          groupValue: settings.themeMode,
          onChanged: (value) => settings.updateThemeMode(value!),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
      ),
    );
  }
}
