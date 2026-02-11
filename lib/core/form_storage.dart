import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FormStorage {
  Future<void> saveForm(String formId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getForm(String formId);
  Future<void> clearForm(String formId);
}

class SharedPrefsFormStorage implements FormStorage {
  @override
  Future<void> saveForm(String formId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('smart_form_$formId', jsonEncode(data));
  }

  @override
  Future<Map<String, dynamic>?> getForm(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('smart_form_$formId');
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearForm(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('smart_form_$formId');
  }
}
