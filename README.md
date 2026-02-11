<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->


# Smart Form Guard 🛡️

[![Pub Package](https://img.shields.io/pub/v/flutter_form_guard.svg)](https://pub.dev/packages/flutter_form_guard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lints)

A robust, "smart" form management package for Flutter that handles **validation**, **auto-saving** (draft restoration), and **analytics** out of the box.

Designed to be state-management agnostic, `SmartFormGuard` works seamlessly with any architecture (Provider, Riverpod, Bloc, or vanilla `setState`).

## 🚀 Features

- 🧠 **Smart State Management**: Decoupled form logic using `FormController`.
- 💾 **Auto-Save & Restore**: Automatically saves drafts locally and restores them on app restart. never lose user input again!
- 📊 **Analytics**: Tracks submission attempts and identifies which fields cause the most errors (great for UX improvements).
- 🛡️ **GuardField**: A smart wrapper around `TextFormField` that auto-registers with the controller.
- 🧩 **Custom Storage**: Swap out the default `SharedPreferences` for Hive, SecureStorage, or your own backend.
- ✨ **Complex Validators**: Built-in support for numeric, phone, range, match (confirm password), and more.

## 📱 Platform Support

| Platform | Support |
| :--- | :---: |
| **Android** | ✅ |
| **iOS** | ✅ |
| **Web** | ✅ |
| **Windows** | ✅ |
| **macOS** | ✅ |
| **Linux** | ✅ |

*Note: The default storage uses `shared_preferences`, which supports all these platforms. If you use a custom storage provider, ensure it also supports your target platforms.*

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_form_guard:
    git:
      url: https://github.com/yourusername/flutter_form_guard.git
      # path: ^1.0.0 (once published on pub.dev)
```

## 🛠️ Usage

### 1. Wrap your form

Wrap your form widget (Column, ListView, etc.) with `SmartFormGuard`. This provides the `FormController` to all descendant fields.

```dart
SmartFormGuard(
  formId: 'login_form', // Unique ID for auto-save persistence
  child: Column(
    children: [
      // ... fields go here
    ],
  ),
)
```

### 2. Add Fields

Use `GuardField` instead of `TextFormField`. It automatically hooks into the controller.

```dart
GuardField.email(name: 'email', label: 'Email Address'),

GuardField.password(
  name: 'password', 
  label: 'Password',
),

// or generic text
GuardField.text(
  name: 'username',
  label: 'Username',
  validators: [Validators.required(), Validators.minLength(3)],
)
```

### 3. Validate & Submit

Access the controller via `SmartFormGuard.of(context)` to validate and submit.

```dart
ElevatedButton(
  onPressed: () {
    final controller = SmartFormGuard.of(context);
    if (controller.validate()) {
      // ✅ Form is valid
      final data = controller.getField('email')?.value;
      print("Logging in with $data");
      
      // Clear form after success if needed
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

## 🧩 Advanced Usage

### Custom Storage (Hive, SecureStorage, API)

You can persist form data anywhere by implementing the `FormStorage` interface.

```dart
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
  storage: MyHiveStorage(myBox),
  child: ...
)
```

### Complex Validators

```dart
// Range
GuardField.text(
  name: 'age',
  validators: [Validators.numeric(), Validators.range(18, 100)]
)

// Match (e.g. Confirm Password)
GuardField.password(
  name: 'confirm_password',
  validators: [
    Validators.match(
      () => SmartFormGuard.of(context).getField('password')?.value, 
      message: "Passwords do not match"
    )
  ]
)
```

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guide](CONTRIBUTING.md) to learn how to propose bugfixes and new features.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
