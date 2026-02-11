import 'package:flutter/material.dart';
import 'package:flutter_form_guard/flutter_form_guard.dart';

// Mock implementation of a custom storage (e.g. Hive or SecureStorage)
class InMemoryMockStorage implements FormStorage {
  static final Map<String, Map<String, dynamic>> _db = {};

  @override
  Future<void> saveForm(String formId, Map<String, dynamic> data) async {
    // Simulate network/disk delay
    await Future.delayed(const Duration(milliseconds: 300));
    _db[formId] = Map.from(data);
    debugPrint("Saved to MockStorage: $data");
  }

  @override
  Future<Map<String, dynamic>?> getForm(String formId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final data = _db[formId];
    debugPrint("Restored from MockStorage: $data");
    return data;
  }

  @override
  Future<void> clearForm(String formId) async {
    _db.remove(formId);
  }
}

class CustomStorageFormScreen extends StatelessWidget {
  const CustomStorageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Storage (Mock Hive)')),

      body: SmartFormGuard(
        formId: 'custom_storage_v1',
        storage: InMemoryMockStorage(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "This form uses an in-memory mock storage (simulating Hive/API). Changes are logged to console.",
              ),
              const SizedBox(height: 20),
              GuardField.text(
                name: 'notes',
                label: 'Secret Notes',
                validators: [Validators.required()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
