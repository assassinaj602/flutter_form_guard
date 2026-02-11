/// A collection of reusable validators for form fields.
///
/// Use [Validators.compose] to combine multiple validators.
class Validators {
  static String? Function(dynamic) required({String message = "Required"}) {
    return (value) =>
        (value == null || (value is String && value.isEmpty)) ? message : null;
  }

  static String? Function(dynamic) email({String message = "Invalid email"}) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return (value) {
      if (value == null || value is! String || value.isEmpty) {
        return null;
      }
      if (!emailRegex.hasMatch(value)) return message;
      return null;
    };
  }

  static String? Function(dynamic) minLength(int length, {String? message}) {
    return (value) {
      if (value == null || value is! String) return null;

      if (value.length < length) {
        return (message ?? "Must be at least $length characters");
      }
      return null;
    };
  }

  static String? Function(dynamic) passwordStrong({
    String message = "Password too weak",
  }) {
    // Example: 8 chars, 1 number
    final hasNumber = RegExp(r'[0-9]');
    // final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]'); // basic set
    return (value) {
      if (value == null || value is! String || value.length < 8) {
        return "Must be at least 8 characters";
      }
      if (!hasNumber.hasMatch(value)) return "Must contain a number";
      // if (!hasSpecial.hasMatch(value)) return "Must contain a special character";
      return null;
    };
  }

  static String? Function(dynamic) numeric({
    String message = "Must be a number",
  }) {
    return (value) {
      if (value == null || value.toString().isEmpty) {
        return null; // Optional unless required
      }
      if (num.tryParse(value.toString()) == null) return message;
      return null;
    };
  }

  static String? Function(dynamic) phone({
    String message = "Invalid phone number",
  }) {
    // Basic international format or 10-digit
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return (value) {
      if (value == null || value.toString().isEmpty) return null;
      if (!phoneRegex.hasMatch(
        value.toString().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
      )) {
        return message;
      }
      return null;
    };
  }

  static String? Function(dynamic) match(
    String Function() otherValueGetter, {
    String message = "Values do not match",
  }) {
    return (value) {
      if (value == null) return null;
      final other = otherValueGetter();
      if (value.toString() != other) return message;
      return null;
    };
  }

  static String? Function(dynamic) range(num min, num max, {String? message}) {
    return (value) {
      if (value == null || value.toString().isEmpty) return null;
      final n = num.tryParse(value.toString());
      if (n == null) return "Invalid number";

      if (n < min || n > max) {
        return (message ?? "Must be between $min and $max");
      }
      return null;
    };
  }

  static String? Function(dynamic) compose(
    List<String? Function(dynamic)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
