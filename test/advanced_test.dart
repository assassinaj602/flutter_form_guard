import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_guard/flutter_form_guard.dart';

// Advanced Mock Storage with controllable delay
class AdvancedMockStorage implements FormStorage {
  Map<String, dynamic> data = {};
  Duration delay = Duration.zero;

  @override
  Future<void> saveForm(String formId, Map<String, dynamic> data) async {
    await Future.delayed(delay);
    this.data = Map.from(data);
  }

  @override
  Future<Map<String, dynamic>?> getForm(String formId) async {
    await Future.delayed(delay);
    return data.isNotEmpty ? Map.from(data) : null;
  }

  @override
  Future<void> clearForm(String formId) async {
    await Future.delayed(delay);
    data.clear();
  }
}

void main() {
  group('Advanced FormController Tests', () {
    late AdvancedMockStorage storage;
    late FormController controller;

    setUp(() {
      storage = AdvancedMockStorage();
      storage.data = {};
      storage.delay = Duration.zero;

      // Note: In real app, SmartFormGuard handles lifecycle.
      // Here we test controller directly.
    });

    test('Restore Logic: Pre-populates fields before registration', () async {
      storage.data = {'username': 'restored_user'};

      controller = FormController(formId: 'test_restore', storage: storage);

      // Wait for restore to complete via exposed future for testing
      await controller.restoreFuture;

      // Now register the field
      controller.registerField('username', validator: Validators.required());

      // Expect value to be the restored one, NOT null
      expect(controller.getField('username')?.value, 'restored_user');
    });

    test('Restore Logic: Updates already registered fields', () async {
      storage.delay = const Duration(milliseconds: 50);
      storage.data = {'email': 'delayed@test.com'};

      controller = FormController(formId: 'test_delayed', storage: storage);

      // Register IMMEDIATELY (before restore completes)
      controller.registerField('email', validator: Validators.email());
      expect(controller.getField('email')?.value, null);

      // Wait for restore via future
      await controller.restoreFuture;

      // Should be updated
      expect(controller.getField('email')?.value, 'delayed@test.com');
    });

    test('Analytics: Tracks failures correctly', () {
      controller = FormController(formId: 'analytics_test', storage: storage);
      controller.registerField('age', validator: Validators.numeric());

      // First failure
      controller.updateField('age', 'abc');
      expect(controller.analytics.mostFailedField, 'age');
      expect(controller.analytics.fieldFailureCounts['age'], 1);

      // Second failure
      controller.updateField('age', 'xyz');
      expect(controller.analytics.fieldFailureCounts['age'], 2);

      // Success
      controller.updateField('age', '25');
      expect(controller.analytics.fieldFailureCounts['age'], 2);
    });

    test('Validation: Validation handles types gracefully', () {
      controller = FormController(formId: 'type_test', storage: storage);
      controller.registerField('count', validator: Validators.numeric());

      // Pass integer directly
      controller.updateField('count', 42);
      expect(controller.getField('count')?.isValid, true);

      // Pass double
      controller.updateField('count', 42.5);
      expect(controller.getField('count')?.isValid, true);

      // Pass null
      controller.registerField('required', validator: Validators.required());
      controller.updateField('required', null);
      expect(controller.getField('required')?.isValid, false);
    });
  });
}
