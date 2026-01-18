
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  // AI Configuration
  String _apiKey = '';
  String _apiEndpoint = '';
  String _apiDeploymentName = '';

  // Preset Prompts
  String _prompt1 = 'Summarize this note for me.';
  String _prompt2 = 'Extract the key action items from this note.';
  String _prompt3 = 'Correct any grammar and spelling mistakes in this note.';

  // Getters for AI Config
  String get apiKey => _apiKey;
  String get apiEndpoint => _apiEndpoint;
  String get apiDeploymentName => _apiDeploymentName;

  // Getters for Prompts
  String get prompt1 => _prompt1;
  String get prompt2 => _prompt2;
  String get prompt3 => _prompt3;

  AppSettings() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('apiKey') ?? '';
    _apiEndpoint = prefs.getString('apiEndpoint') ?? '';
    _apiDeploymentName = prefs.getString('apiDeploymentName') ?? '';

    _prompt1 = prefs.getString('prompt1') ?? _prompt1;
    _prompt2 = prefs.getString('prompt2') ?? _prompt2;
    _prompt3 = prefs.getString('prompt3') ?? _prompt3;
    
    notifyListeners();
  }

  Future<void> setApiConfig({
    required String apiKey,
    required String apiEndpoint,
    required String apiDeploymentName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = apiKey;
    _apiEndpoint = apiEndpoint;
    _apiDeploymentName = apiDeploymentName;

    await prefs.setString('apiKey', apiKey);
    await prefs.setString('apiEndpoint', apiEndpoint);
    await prefs.setString('apiDeploymentName', apiDeploymentName);

    notifyListeners();
  }

  Future<void> setPresetPrompts({
    required String prompt1,
    required String prompt2,
    required String prompt3,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _prompt1 = prompt1;
    _prompt2 = prompt2;
    _prompt3 = prompt3;

    await prefs.setString('prompt1', prompt1);
    await prefs.setString('prompt2', prompt2);
    await prefs.setString('prompt3', prompt3);

    notifyListeners();
  }
}
