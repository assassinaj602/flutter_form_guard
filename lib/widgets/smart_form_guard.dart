import 'package:flutter/material.dart';
import '../core/form_controller.dart';
import '../core/form_storage.dart';

class SmartFormGuard extends StatefulWidget {
  final String formId;
  final Widget child;
  final bool autoSave;
  final bool autoRestore;
  final FormStorage? storage; // Allow custom storage provider

  const SmartFormGuard({
    Key? key,
    required this.formId,
    required this.child,
    this.autoSave = true,
    this.autoRestore = true,
    this.storage,
  }) : super(key: key);

  static FormController of(BuildContext context) {
    final _Result? result =
        context.dependOnInheritedWidgetOfExactType<_Result>();
    assert(result != null, 'No SmartFormGuard found in context');
    return result!.controller;
  }

  @override
  _SmartFormGuardState createState() => _SmartFormGuardState();
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

class _Result extends InheritedWidget {
  final FormController controller;

  const _Result({Key? key, required this.controller, required Widget child})
    : super(key: key, child: child);

  @override
  bool updateShouldNotify(_Result oldWidget) =>
      controller != oldWidget.controller;
}
