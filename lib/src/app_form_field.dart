import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

class AppFormField<T> {
  final GlobalKey<FormBuilderFieldState> fieldKey =
      GlobalKey<FormBuilderFieldState>();
  final String name;
  final String? Function(String?)? validations;

  final Function(FormBuilderFieldState? state)? onChange;

  final Function(FormBuilderFieldState? state)? onValid;

  T? initialValue;

  T? value;

  AppFormField(
      {required this.name,
      this.validations,
      this.initialValue,
      this.onChange,
      this.onValid});

  setValue(T? value) {
    fieldKey.currentState?.didChange(value);
  }

  reset() {
    fieldKey.currentState?.reset();
  }

  FormBuilderState? get formState => fieldKey.currentState?.formState;
}
