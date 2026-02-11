# Smart Form Guard 🛡️

[![Pub Package](https://img.shields.io/pub/v/flutter_form_guard.svg)](https://pub.dev/packages/flutter_form_guard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lints)
[![Platform: Android](https://img.shields.io/badge/Android-supported-blue)](https://pub.dev/packages/flutter_form_guard)
[![Platform: iOS](https://img.shields.io/badge/iOS-supported-blue)](https://pub.dev/packages/flutter_form_guard)
[![Platform: Web](https://img.shields.io/badge/Web-supported-blue)](https://pub.dev/packages/flutter_form_guard)

A robust, **"smart"** form management package for Flutter that handles **validation**, **auto-saving** (draft restoration), and **analytics** out of the box.

`SmartFormGuard` decouples your form logic from the UI, ensuring your forms are responsive, persistent, and insightful. It is designed to be **architecture-agnostic**, working seamlessly with Provider, Riverpod, Bloc, or vanilla `setState`.

---

## 🚀 Features

- 🧠 **Smart State Management**: Decoupled form logic using `FormController`.
- 💾 **Auto-Save & Restore**: Automatically saves drafts locally and restores them on app restart. Never lose user input again!
- 📊 **Analytics**: Tracks submission attempts and identifies which fields cause the most errors (great for UX improvements).
- 🛡️ **GuardField**: A smart wrapper around `TextFormField` that auto-registers with the controller.
- 🧩 **Custom Storage**: Swap out the default `SharedPreferences` for Hive, SecureStorage, or your own backend.
- ✨ **Complex Validators**: Built-in support for numeric, phone, range, match (confirm password), and more.

---

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_form_guard: ^1.2.0
```

Then run:

```bash
flutter pub get
```

---

## 🛠️ Usage

### 1. Wrap your form with `SmartFormGuard`

The `SmartFormGuard` widget injects a `FormController` into the widget tree. This controller manages the state of all descendant `GuardField` widgets.

```dart
import 'package:flutter_form_guard/flutter_form_guard.dart';

SmartFormGuard(
  formId: 'login_form', // Unique ID for auto-save persistence
  child: Column(
    children: [
      // ... fields go here
    ],
  ),
)
```

### 2. Add `GuardField` widgets

Use `GuardField` instead of `TextFormField`. It automatically hooks into the controller, handling validation and state updates.

```dart
GuardField.email(
  name: 'email', 
  label: 'Email Address'
),

GuardField.password(
  name: 'password', 
  label: 'Password'
),
```

### 3. Validate and Submit

Access the controller to validate the form and retrieve data.

```dart
ElevatedButton(
  onPressed: () {
    // Get the controller from context
    final controller = SmartFormGuard.of(context);
    
    if (controller.validate()) {
      // ✅ Form is valid
      final email = controller.getField('email')?.value;
      final password = controller.getField('password')?.value;
      
      print("Logging in with $email");
      
      // Reset after success if needed
      // controller.reset(); 
    } else {
      // ❌ Form is invalid
      // Errors are automatically displayed on the fields
      
      // Check analytics for debugging UX
      print(controller.analytics); 
    }
  },
  child: Text('Login'),
)
```

---

## 📚 Core Concepts

### FormController
The brain of the operation. It maintains the state of fields (`value`, `error`, `touched`), handles validation logic, and manages auto-save timers. You typically don't instantiate this directly; `SmartFormGuard` creates it for you.

### SmartFormGuard
The dependency injector. It holds the `FormController` and provides it to descendants via `InheritedWidget`. It also manages the lifecycle of the controller (disposing it when the widget is removed).

### GuardField
The worker. It wraps a standard `TextFormField` and handles the two-way binding with the `FormController`. It listens for changes to update the UI and reports user input back to the controller.

---

## ✅ Validation

`flutter_form_guard` comes with a suite of built-in validators in the `Validators` class. You can compose them using lists.

### Built-in Validators

| Validator | Description | Usage |
| :--- | :--- | :--- |
| `required` | Ensures the field is not empty. | `Validators.required()` |
| `email` | Validates email format. | `Validators.email()` |
| `minLength` | Enforces minimum character count. | `Validators.minLength(8)` |
| `numeric` | Ensures input is a number. | `Validators.numeric()` |
| `range` | Checks if a number is within range. | `Validators.range(18, 100)` |
| `phone` | Basic phone number validation. | `Validators.phone()` |
| `match` | Checks if value matches another value. | `Validators.match(() => otherValue)` |

### Custom Validators

You can write your own validators easily. A validator is simply a function that takes a `dynamic value` and returns a `String?` error message (or `null` if valid).

```dart
String? myCustomValidator(dynamic value) {
  if (value.toString().contains('forbidden')) {
    return 'This word is not allowed';
  }
  return null;
}

// Usage
GuardField.text(
  name: 'username',
  validator: myCustomValidator,
)
```

---

## 💾 Auto-Save & Restoration

One of the most powerful features of `SmartFormGuard` is its ability to automatically save form state.

- **How it works**: When a field changes, a debounce timer starts. If no further changes occur within 500ms, the entire form state is saved to storage using the `formId` as the key.
- **Restoration**: When `SmartFormGuard` initializes, it checks storage for existing data matching the `formId`. If found, it pre-populates the fields.
- **Configuration**:
  - `autoSave`: Set to `false` to disable auto-saving.
  - `autoRestore`: Set to `false` to disable auto-restoration.

```dart
SmartFormGuard(
  formId: 'my_form',
  autoSave: true, // Default
  autoRestore: true, // Default
  child: ...
)
```

---

## 🧩 Custom Storage

By default, `SmartFormGuard` uses `SharedPreferences` via the `shared_preferences` package. However, you can use **any** storage backend (Hive, FlutterSecureStorage, SQLite, or a remote API) by implementing the `FormStorage` interface.

```dart
import 'package:flutter_form_guard/flutter_form_guard.dart';

class MyHiveStorage implements FormStorage {
  final Box box;
  MyHiveStorage(this.box);

  @override
  Future<void> saveForm(String formId, Map<String, dynamic> data) async {
    await box.put(formId, data);
  }

  @override
  Future<Map<String, dynamic>?> getForm(String formId) async {
    final data = box.get(formId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  @override
  Future<void> clearForm(String formId) async {
    await box.delete(formId);
  }
}

// Usage
SmartFormGuard(
  formId: 'secure_form',
  storage: MyHiveStorage(myBox), // Inject your custom storage
  child: ...
)
```

---

## 🧪 Testing

Testing forms is often painful. `SmartFormGuard` makes it easier by exposing the `FormController`.

### Unit Testing Logic

You can test validation logic without rendering UI:

```dart
test('Login form validation', () {
  final storage = MockStorage(); // Simple map-based mock
  final controller = FormController(formId: 'test', storage: storage);
  
  controller.registerField('email', validator: Validators.email());
  
  controller.updateField('email', 'invalid-email');
  expect(controller.validate(), false);
  
  controller.updateField('email', 'valid@example.com');
  expect(controller.validate(), true);
});
```

### Integration Testing

In widget tests, you can interact with `GuardField` just like any other widget:

```dart
testWidgets('Form shows error on invalid submit', (tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.text('Login')); // Submit empty form
  await tester.pump();
  
  expect(find.text('Required'), findsOneWidget); // Expect error message
});
```

---

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guide](CONTRIBUTING.md) to learn how to propose bugfixes and new features.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
