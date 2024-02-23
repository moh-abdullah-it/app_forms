import 'dart:developer';

import 'package:app_forms/app_forms.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginForm extends AppForm {
  @override
  bool get autoValidate => true;

  final email = AppFormField<String>(
      name: 'email',
      initialValue: 'email@email.com',
      validations: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.email(),
      ]),
      onChange: (state) {
        log('email State Changed ${state?.value}');
      },
      onValid: (state) {
        log('email Valid ${state?.value}');
      });

  final password = AppFormField<String>(name: 'password', initialValue: 'test');

  LoginForm() {
    setFields([email, password]);
  }

  updateEmailValue() {
    email.value = 'error@email';
    updateFieldsValue([email]);
  }

  @override
  Future onSubmit(Map<String, dynamic>? values) async {
    await Future.delayed(const Duration(seconds: 3), () => log('values $values'));
  }
}
