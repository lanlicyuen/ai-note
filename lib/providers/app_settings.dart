
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // AI settings
  String _apiKey = '';
  String _customPrompt = 'Please polish the following text and return it in Markdown format.';

  String get apiKey => _apiKey;
  String get customPrompt => _customPrompt;

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeIndex = _prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    // Load AI settings
    _apiKey = _prefs.getString('apiKey') ?? ''; // Default to empty for security
    _customPrompt = _prefs.getString('customPrompt') ?? 'Please polish the following text and return it in Markdown format.';

    notifyListeners();
  }

  // --- Theme Methods ---
  Future<void> updateThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    await _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // --- AI Setting Methods ---
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
