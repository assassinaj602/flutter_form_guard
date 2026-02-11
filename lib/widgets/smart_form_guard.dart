import 'package:flutter/material.dart';
import '../core/form_controller.dart';
import '../core/form_storage.dart';

/// A smart wrapper widget that provides form state management to its descendants.
///
/// Wraps your form and provides a [FormController] via [SmartFormGuard.of].
/// Handles auto-saving, restoration, and analytics.
class SmartFormGuard extends StatefulWidget {
  /// Unique identifier for this form. Used as the key for storage persistence.
  final String formId;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Whether to automatically save form state on changes. Defaults to `true`.
  final bool autoSave;

  /// Whether to automatically restore saved state on initialization. Defaults to `true`.
  final bool autoRestore;

  /// Optional custom storage provider. Defaults to [SharedPrefsFormStorage].
  final FormStorage? storage;

  const SmartFormGuard({
    super.key,
    required this.formId,
    required this.child,
    this.autoSave = true,
    this.autoRestore = true,
    this.storage,
  });

  static FormController of(BuildContext context) {
    final _Result? result =
        context.dependOnInheritedWidgetOfExactType<_Result>();
    assert(result != null, 'No SmartFormGuard found in context');
    return result!.controller;
  }

  @override
  State<SmartFormGuard> createState() => _SmartFormGuardState();
}

class _SmartFormGuardState extends State<SmartFormGuard> {
  late final FormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormController(
      formId: widget.formId,
      storage: widget.storage ?? SharedPrefsFormStorage(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return _Result(controller: _controller, child: widget.child);
      },
    );
  }
}

// ignore: library_private_types_in_public_api
class _Result extends InheritedWidget {
  final FormController controller;

  const _Result({required this.controller, required super.child});

  @override
  bool updateShouldNotify(_Result oldWidget) =>
      controller != oldWidget.controller;
}
