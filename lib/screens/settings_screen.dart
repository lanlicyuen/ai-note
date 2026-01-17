
import 'package:flutter/material.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';

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
