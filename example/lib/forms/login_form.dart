import 'dart:developer';

import 'package:app_forms/app_forms.dart';

class LoginForm extends AppForm {
  final email = AppFormField<int>(name: 'email', initialValue: 10);

  LoginForm() {
    email.setInitialValue(100);
  }

  @override
  Future onSubmit(Map<String, dynamic>? values) async {
    log('values $values');
  }
}
