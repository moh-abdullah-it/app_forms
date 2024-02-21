import 'package:app_forms/app_forms.dart';
import 'package:flutter/cupertino.dart';

abstract class AppForm {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  List<AppFormField> _fields = [];
  bool get autoValidate => true;

  Map<String, dynamic> initialValue = {};
  final Map<String, dynamic> _values = {};

  Map<String, dynamic>? getValues() {
    return formKey.currentState?.value;
  }

  Future onSubmit(Map<String, dynamic>? values);

  void onReset() {}

  bool? saveAndValidate({
    bool focusOnInvalid = true,
    bool autoScrollWhenFocusOnInvalid = false,
  }) {
    return formKey.currentState?.saveAndValidate(
      focusOnInvalid: focusOnInvalid,
      autoScrollWhenFocusOnInvalid: autoScrollWhenFocusOnInvalid,
    );
  }

  void submit() async {
    if (saveAndValidate() ?? false) {
      onSubmit(getValues());
    } else {}
  }

  void setFields(List<AppFormField> fields) {
    _fields = fields;
    for (var element in fields) {
      initialValue[element.name] = element.initialValue;
      _values[element.name] = element.initialValue;
    }
  }

  void onChange() {
    if (autoValidate) {
      _autoValidate();
    }
  }

  void updateFieldsValue(List<AppFormField> fields) {
    for (var element in fields) {
      formKey.currentState?.fields[element.name]?.didChange(element.value);
    }
  }

  void setValidationErrors(Map<String, dynamic>? errors) {
    if (errors != null && errors.isNotEmpty) {
      errors.forEach((fieldKey, value) {
        var field = formKey.currentState?.fields[fieldKey];
        if (value is List) {
          field?.invalidate(value.first);
        }
        if (value is String) {
          field?.invalidate(value);
        }
      });
    }
  }

  void _autoValidate() {
    for (var element in _fields) {
      if (_values[element.name] !=
          formKey.currentState?.instantValue[element.name]) {
        _values[element.name] =
            formKey.currentState?.instantValue[element.name];
        formKey.currentState?.fields[element.name]?.validate();
      }
    }
  }
}
