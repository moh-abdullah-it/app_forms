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
      onChange: (field) {
        log('email State Changed ${field?.value}');
      },
      onValid: (field) {
        log('email Valid ${field?.value}');
      });

  final password = AppFormField<String>(name: 'password', initialValue: 'test');

  LoginForm() {
    setLoading();
    setFields([email, password]);
    setLoading(false);
  }

  updateEmailValue() {
    email.value = 'm@m.com';
    updateFieldsValue();
  }

  @override
  Future onSubmit(Map<String, dynamic>? values) async {
    await Future.delayed(
        const Duration(seconds: 3), () => log('values $values'));
  }
}
