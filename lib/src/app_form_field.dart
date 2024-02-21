import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

class AppFormField<T> {
  final GlobalKey<FormBuilderFieldState> fieldKey =
      GlobalKey<FormBuilderFieldState>();
  final String name;
  final String? Function(String?)? validations;
  T? initialValue;
  AppFormField({required this.name, this.validations, this.initialValue});

  setInitialValue(T? value) {
    this.initialValue = value;
  }
}
