import 'package:app_forms/app_forms.dart';
import 'package:flutter/cupertino.dart';

abstract class AppForm {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic>? getValues() {
    return formKey.currentState?.value;
  }

  void initValues() async {}

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
}
