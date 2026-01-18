
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _prompt1 = 'Act as a professional editor. Fix any grammar, spelling, and punctuation mistakes. Improve the clarity, flow, and overall quality of the text. Rewrite sentences if necessary, but stay true to the original meaning.';
  String _prompt2 = 'Summarize the following text into three key bullet points.';
  String _prompt3 = 'Translate the following text into conversational English.';

  ThemeMode get themeMode => _themeMode;
  String get prompt1 => _prompt1;
  String get prompt2 => _prompt2;
  String get prompt3 => _prompt3;

  AppSettings() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 2; // Default to system
    _themeMode = ThemeMode.values[themeIndex];
    
    _prompt1 = prefs.getString('prompt_1') ?? _prompt1;
    _prompt2 = prefs.getString('prompt_2') ?? _prompt2;
    _prompt3 = prefs.getString('prompt_3') ?? _prompt3;

    notifyListeners();
  }

  void setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', themeMode.index);
  }

  void setPrompt1(String newPrompt) async {
    if (_prompt1 == newPrompt) return;
    _prompt1 = newPrompt;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prompt_1', newPrompt);
  }
  
  void setPrompt2(String newPrompt) async {
    if (_prompt2 == newPrompt) return;
    _prompt2 = newPrompt;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prompt_2', newPrompt);
  }

  void setPrompt3(String newPrompt) async {
    if (_prompt3 == newPrompt) return;
    _prompt3 = newPrompt;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prompt_3', newPrompt);
  }
}
