import 'package:app_forms/app_forms.dart';
import 'package:flutter/cupertino.dart';

abstract class AppForm {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  List<AppFormField> _fields = [];
  bool get autoValidate => true;

  Map<String, dynamic> initialValue = {};
  final Map<String, dynamic> _values = {};
  FormBuilderState? get state => formKey.currentState;

  Map<String, dynamic>? getValues() {
    return state?.value;
  }

  Future onSubmit(Map<String, dynamic>? values);

  void onReset() {}

  bool? saveAndValidate({
    bool focusOnInvalid = true,
    bool autoScrollWhenFocusOnInvalid = false,
  }) {
    return state?.saveAndValidate(
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
    } else {
      _listenFieldChange();
    }
  }

  void updateFieldsValue(List<AppFormField> fields) {
    for (var element in fields) {
      state?.fields[element.name]?.didChange(element.value);
    }
  }

  void setValidationErrors(Map<String, dynamic>? errors) {
    if (errors != null && errors.isNotEmpty) {
      errors.forEach((fieldKey, value) {
        var field = state?.fields[fieldKey];
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
    for (var field in _fields) {
      if (_values[field.name] != state?.instantValue[field.name]) {
        _values[field.name] = state?.instantValue[field.name];
        state?.fields[field.name]?.validate();
        // call field
        _callFiled(field);
      }
    }
  }

  void _listenFieldChange() {
    for (var field in _fields.where(
        (element) => element.onChange != null || element.onValid != null)) {
      if (_values[field.name] != state?.instantValue[field.name]) {
        _values[field.name] = state?.instantValue[field.name];
        _callFiled(field);
      }
    }
  }

  _callFiled(AppFormField field) {
    field.onChange?.call(state?.fields[field.name]);
    if (state?.fields[field.name]?.isValid ?? false) {
      field.onValid?.call(state?.fields[field.name]);
    }
  }
}
