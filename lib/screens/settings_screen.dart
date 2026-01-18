
import 'package:flutter/material.dart';
import 'package:myapp/providers/app_settings.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Future to track the loading of settings
  late Future<void> _loadSettingsFuture;

  // Controllers for the TextFields to manage their state
  late TextEditingController _apiKeyController;
  late TextEditingController _apiEndpointController;
  late TextEditingController _apiDeploymentNameController;
  late TextEditingController _prompt1Controller;
  late TextEditingController _prompt2Controller;
  late TextEditingController _prompt3Controller;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);

    // Initialize controllers with current settings values
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _apiEndpointController = TextEditingController(text: settings.apiEndpoint);
    _apiDeploymentNameController = TextEditingController(text: settings.apiDeploymentName);
    _prompt1Controller = TextEditingController(text: settings.prompt1);
    _prompt2Controller = TextEditingController(text: settings.prompt2);
    _prompt3Controller = TextEditingController(text: settings.prompt3);

    // Create a future that completes when settings are loaded from SharedPreferences
    _loadSettingsFuture = settings.loadSettings();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed
    _apiKeyController.dispose();
    _apiEndpointController.dispose();
    _apiDeploymentNameController.dispose();
    _prompt1Controller.dispose();
    _prompt2Controller.dispose();
    _prompt3Controller.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    settings.setApiConfig(
      apiKey: _apiKeyController.text,
      apiEndpoint: _apiEndpointController.text,
      apiDeploymentName: _apiDeploymentNameController.text,
    );
    settings.setPresetPrompts(
      prompt1: _prompt1Controller.text,
      prompt2: _prompt2Controller.text,
      prompt3: _prompt3Controller.text,
    );
    // Show a confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings Saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings, // Save the current text field values
            tooltip: 'Save Settings',
          ),
        ],
      ),
      // Use FutureBuilder to handle the asynchronous loading of settings
      body: FutureBuilder(
        future: _loadSettingsFuture,
        builder: (context, snapshot) {
          // While waiting for the future to complete, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If an error occurred during loading, display an error message
          if (snapshot.hasError) {
            return Center(child: Text('Error loading settings: ${snapshot.error}'));
          }

          // Once data is loaded successfully, build the main UI
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'AI Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your API Key',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiEndpointController,
                  decoration: const InputDecoration(
                    labelText: 'API Endpoint',
                    border: OutlineInputBorder(),
                    hintText: 'https://yourapi.openai.azure.com',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiDeploymentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Deployment Name',
                    border: OutlineInputBorder(),
                    hintText: 'Your deployment/model name',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'AI Preset Prompts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _prompt1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Preset Prompt 1',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Summarize this note',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _prompt2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Preset Prompt 2',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Extract action items',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _prompt3Controller,
                  decoration: const InputDecoration(
                    labelText: 'Preset Prompt 3',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Correct grammar and spelling',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
