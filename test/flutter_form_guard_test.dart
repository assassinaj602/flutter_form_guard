import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_guard/flutter_form_guard.dart';

// Mock storage
class MockStorage implements FormStorage {
  Map<String, dynamic> data = {};

  @override
  Future<void> saveForm(String formId, Map<String, dynamic> data) async {
    this.data = data;
  }

  @override
  Future<Map<String, dynamic>?> getForm(String formId) async {
    return data;
  }

  @override
  Future<void> clearForm(String formId) async {
    data.clear();
  }
}

void main() {
  test('FormController registers and updates fields', () {
    final controller = FormController(formId: 'test', storage: MockStorage());

    controller.registerField('email', validator: Validators.email());
    expect(controller.getField('email')?.value, null);

    controller.updateField('email', 'test@example.com');
    expect(controller.getField('email')?.value, 'test@example.com');
    expect(controller.getField('email')?.isValid, true);

    controller.updateField('email', 'invalid');
    expect(controller.getField('email')?.isValid, false);
    expect(controller.getField('email')?.error, 'Invalid email');
  });

  group('Complex Validators', () {
    test('numeric validator', () {
      final validator = Validators.numeric();
      expect(validator('123'), null);
      expect(validator('abc'), 'Must be a number');
      expect(validator('12.5'), null);
    });

    test('phone validator', () {
      final validator = Validators.phone();
      expect(validator('+1234567890'), null);
      expect(validator('1234567890'), null);
      expect(validator('123'), 'Invalid phone number'); // too short
      expect(validator('abc'), 'Invalid phone number');
    });

    test('range validator', () {
      final validator = Validators.range(10, 20);
      expect(validator('15'), null);
      expect(validator('9'), 'Must be between 10 and 20');
      expect(validator('21'), 'Must be between 10 and 20');
    });

    test('match validator', () {
      String other = 'password123';
      final validator = Validators.match(() => other, message: 'Mismatch');
      expect(validator('password123'), null);
      expect(validator('password321'), 'Mismatch');
    });
  });
}
