class FieldState<T> {
  final T? value;
  final String? error;
  final bool touched;
  final bool isValid;

  const FieldState({
    this.value,
    this.error,
    this.touched = false,
    this.isValid = true,
  });

  FieldState<T> copyWith({
    T? value,
    String? error,
    bool? touched,
    bool? isValid,
  }) {
    return FieldState<T>(
      value: value ?? this.value,
      error: error, // Error can be nullified, so strictly pass it
      touched: touched ?? this.touched,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  String toString() =>
      'FieldState(value: $value, error: $error, touched: $touched, isValid: $isValid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FieldState<T> &&
        other.value == value &&
        other.error == error &&
        other.touched == touched &&
        other.isValid == isValid;
  }

  @override
  int get hashCode =>
      value.hashCode ^ error.hashCode ^ touched.hashCode ^ isValid.hashCode;
}
