import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/field_state.dart';
import '../models/analytics_report.dart';
import 'analytics_engine.dart';
import 'form_storage.dart';

class FormController extends ChangeNotifier {
  final String formId;
  final FormStorage _storage;
  final AnalyticsEngine _analytics = AnalyticsEngine();

  // Internal state
  final Map<String, FieldState<dynamic>> _fields = {};
  final Map<String, String? Function(dynamic)> _validators = {};
  Timer? _autoSaveTimer;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isValid => _fields.values.every((f) => f.isValid);
  AnalyticsReport get analytics => _analytics.generateReport();

  FormController({required this.formId, required FormStorage storage})
    : _storage = storage {
    _restoreFuture = _restoreForm();
  }

  late final Future<void> _restoreFuture;
  @visibleForTesting
  Future<void> get restoreFuture => _restoreFuture;

  void registerField(
    String name, {
    String? Function(dynamic)? validator,
    dynamic initialValue,
  }) {
    if (!_fields.containsKey(name)) {
      _fields[name] = FieldState(value: initialValue);
    } else {
      // If restoration happened before registration, _fields[name] has the restored value.
      // We should KEEP it.
      // But what if we passed an initialValue?
      // Typically restored value > initialValue.
      // So do nothing to value.

      // Just update validator if needed.
      // But wait, if we blindly populated via restore, the touched/isValid might be default.
    }

    if (validator != null) {
      _validators[name] = validator;

      // OPTIONAL: Re-validate immediately if we have a value?
      // Since we just registered, and if we have a restored value, we might want to check validity.
      // But maybe let UI drive that or lazy validate.
    }
  }

  void updateField(String name, dynamic value) {
    if (!_fields.containsKey(name)) return;

    // Validate
    String? error;
    if (_validators.containsKey(name)) {
      error = _validators[name]!(value);
    }

    _fields[name] = _fields[name]!.copyWith(
      value: value,
      error: error,
      isValid: error == null,
      touched: true,
    );

    if (error != null) {
      _analytics.logFieldFailure(name);
    }

    notifyListeners();
    _triggerAutoSave();
  }

  FieldState<dynamic>? getField(String name) => _fields[name];

  Future<void> _triggerAutoSave() async {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveForm();
    });
  }

  Future<void> _saveForm() async {
    final data = _fields.map((key, state) => MapEntry(key, state.value));
    debugPrint("SmartFormGuard: Saving form $formId -> $data");
    await _storage.saveForm(formId, data);
  }

  Future<void> _restoreForm() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("SmartFormGuard: restoring form $formId...");
    final data = await _storage.getForm(formId);
    debugPrint("SmartFormGuard: restored data for $formId -> $data");

    if (data != null) {
      data.forEach((key, value) {
        // Populate fields with restored data.
        // If the field is already registered, this updates it.
        // If not, it pre-populates it for when the widget registers.
        if (_fields.containsKey(key)) {
          _fields[key] = _fields[key]!.copyWith(value: value);
        } else {
          _fields[key] = FieldState(value: value);
        }
      });
    }

    _isLoading = false;
    notifyListeners();
  }

  bool validate() {
    _analytics.logSubmissionAttempt();
    bool allValid = true;
    for (var name in _fields.keys) {
      final value = _fields[name]?.value;
      String? error;
      if (_validators.containsKey(name)) {
        error = _validators[name]!(value);
      }

      if (error != null) {
        allValid = false;
        _analytics.logFieldFailure(name);
      }

      _fields[name] = _fields[name]!.copyWith(
        error: error,
        isValid: error == null,
        touched: true,
      );
    }
    notifyListeners();
    return allValid;
  }

  void reset() {
    _fields.forEach((key, _) {
      _fields[key] = FieldState(value: null);
    });
    _storage.clearForm(formId);
    _analytics.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
