import 'package:flutter/material.dart';
import '../core/form_controller.dart';
import '../validators/validators.dart';
import 'smart_form_guard.dart';

/// A smart form field that automatically registers with [SmartFormGuard].
///
/// Use [GuardField.text], [GuardField.email], or [GuardField.password] for common use cases.
class GuardField extends StatefulWidget {
  /// Field name. Must be unique within the form.
  final String name;

  /// Label text displayed in the input decoration.
  final String? label;

  /// Hint text displayed in the input decoration.
  final String? hint;

  /// Whether to hide the text (e.g. for passwords).
  final bool obscureText;

  /// Keyboard type for the input.
  final TextInputType? keyboardType;

  /// List of validators to apply.
  final List<String? Function(dynamic)>? validators;

  /// Single custom validator.
  final String? Function(dynamic)? validator;

  const GuardField({
    super.key,
    required this.name,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validators,
    this.validator,
  });

  factory GuardField.text({
    required String name,
    String? label,
    String? hint,
    TextInputType? keyboardType,
    List<String? Function(dynamic)>? validators,
  }) {
    return GuardField(
      name: name,
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      validators: validators,
    );
  }

  factory GuardField.email({
    required String name,
    String? label = "Email",
    String? hint,
  }) {
    return GuardField(
      name: name,
      label: label,
      hint: hint,
      keyboardType: TextInputType.emailAddress,
      validators: [Validators.email()],
    );
  }

  factory GuardField.password({
    required String name,
    String? label = "Password",
    String? hint,
  }) {
    return GuardField(
      name: name,
      label: label,
      hint: hint,
      obscureText: true,
      validators: [Validators.required(), Validators.minLength(8)],
    );
  }

  @override
  State<GuardField> createState() => _GuardFieldState();
}

class _GuardFieldState extends State<GuardField> {
  late final TextEditingController _textController;
  late FormController _formController;
  bool _initialized = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Get controller (this registers us as a dependent of the InheritedWidget too)
    final newController = SmartFormGuard.of(context);

    // 2. Initial logic or if controller changed parent (rare but possible)
    if (!_initialized || newController != _formController) {
      _formController = newController;

      // Register listener if not already
      // We need to match lifecycle.
      // If we switched controllers, remove old listener?
      // Simplification: Assume controller stable for now, but correct way:
      // We can't easily remove listener from old controller unless we stored it.
      // Given SmartFormGuard creates controller in initState, it's stable per this Widget's lifecycle usually.

      if (!_listening) {
        _formController.addListener(_onFormChanged);
        _listening = true;
      }

      _registerField();
      _trySyncValue();
      _initialized = true;
    }
  }

  void _registerField() {
    // Register field with composed validator
    String? Function(dynamic)? composedValidator;
    if (widget.validators != null) {
      composedValidator = Validators.compose(widget.validators!);
    } else {
      composedValidator = widget.validator;
    }

    _formController.registerField(widget.name, validator: composedValidator);
  }

  void _onFormChanged() {
    if (!mounted) return;

    // 1. Sync Value (Restore / Reset logic)
    _trySyncValue();

    // 2. Rebuild to show errors (setState)
    setState(() {});
  }

  void _trySyncValue() {
    final state = _formController.getField(widget.name);
    if (state == null) return;

    final stateValue = state.value?.toString() ?? "";
    final currentValue = _textController.text;

    // Only update if strictly different.
    // And to avoid fighting with user typing, we need to be careful.
    // If stateValue changed recently, it might be due to US typing (via onChanged).
    // Logic:
    // If stateValue != currentValue
    // This implies stateValue changed EXTERNALLY (Restore, Reset, or programmed set).
    // Because if WE typed, onChanged -> updateField -> stateValue becomes what we typed.
    // So they should be equal.

    if (stateValue != currentValue) {
      // Restore cursor position if possible
      final selection = _textController.selection;
      _textController.text = stateValue;

      // Try to keep cursor if text length permits
      if (selection.baseOffset >= 0 &&
          selection.baseOffset <= stateValue.length) {
        _textController.selection = selection;
      } else {
        // End of text
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: stateValue.length),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_listening) {
      _formController.removeListener(_onFormChanged);
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: We don't rely on InheritedWidget rebuild anymore for updates,
    // but we do for access.

    final state = _formController.getField(widget.name);
    final errorText = state?.touched == true ? state?.error : null;

    return TextFormField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: errorText,
      ),
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: (value) {
        // Update controller. This triggers notifyListeners -> _onFormChanged.
        // In _onFormChanged, stateValue will match value, so no text update loop.
        _formController.updateField(widget.name, value);
      },
    );
  }
}
