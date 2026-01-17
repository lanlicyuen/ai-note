
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _apiKey = '';
  String _customPrompt = 'Please polish the following text and return it in Markdown format.';

  String get apiKey => _apiKey;
  String get customPrompt => _customPrompt;

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString('apiKey') ?? 'sk-83b0f224c3e844ad843beecbd64e3adb';
    _customPrompt = _prefs.getString('customPrompt') ?? 'Please polish the following text and return it in Markdown format.';
    notifyListeners();
  }

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
