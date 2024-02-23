import 'package:app_forms/app_forms.dart';
import 'package:app_forms/src/utils/debouncer.dart';
import 'package:flutter/cupertino.dart';

abstract class AppForm {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  List<AppFormField> _fields = [];

  bool get autoValidate => true;

  final _debouncer = Debouncer(milliseconds: 250);

  bool progressing = false;
  bool loading = false;
  bool hasErrors = false;
  bool success = false;

  AppFormListener? _listener;

  Map<String, dynamic> initialValue = {};
  final Map<String, dynamic> _values = {};

  FormBuilderState? get state => formKey.currentState;

  Map<String, dynamic>? getValues() {
    return state?.value;
  }

  Future onSubmit(Map<String, dynamic>? values);

  Future onValid(Map<String, dynamic>? values) async {}

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
    hasErrors = false;
    progressing = true;
    _listener?.update();
    if (saveAndValidate() ?? false) {
      await onSubmit(getValues());
    } else {
      hasErrors = true;
    }
    progressing = false;
    _listener?.update();
  }

  void reset() {
    state?.reset();
    onReset();
  }

  void setFields(List<AppFormField> fields) {
    _fields = fields;
    for (var filed in fields) {
      initialValue[filed.name] = filed.initialValue;
      _values[filed.name] = filed.initialValue;
      filed.value = _values[filed.name];
    }
  }

  void onChange() {
    if (autoValidate) {
      _autoValidate();
    } else {
      _listenFieldChange();
    }
    if (state?.isValid ?? false) {
      onValid(getValues());
    }
    _setFieldsValue();
  }

  void updateFieldsValue(List<AppFormField> fields) {
    for (var element in fields) {
      state?.fields[element.name]?.didChange(element.value);
    }
  }

  void setValidationErrors(Map<String, dynamic>? errors) {
    hasErrors = true;
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
        _callField(field);
      }
    }
  }

  void _listenFieldChange() {
    for (var field in _fields.where(
        (element) => element.onChange != null || element.onValid != null)) {
      if (_values[field.name] != state?.instantValue[field.name]) {
        _values[field.name] = state?.instantValue[field.name];
        _callField(field);
      }
    }
  }

  _callField(AppFormField field) {
    _debouncer.run(() {
      field.onChange?.call(state?.fields[field.name]);
      if (state?.fields[field.name]?.isValid ?? false) {
        field.onValid?.call(state?.fields[field.name]);
      }
    });
  }

  set listener(AppFormListener listener) {
    _listener = listener;
  }

  void _setFieldsValue() {
    for (var field in _fields) {
      field.value = _values[field.name] ?? field.initialValue;
    }
    _debouncer.run(() => _listener?.update());
  }

  void setSuccess([bool success = true]) => this.success = success;

  void setLoading([bool loading = true]) => this.loading = loading;

  void setHasErrors([bool hasErrors = true]) => this.hasErrors = hasErrors;
}
