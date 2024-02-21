import 'package:app_forms/app_forms.dart';
import 'package:example/forms/login_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final loginForm = LoginForm();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: AppFormBuilder(
            form: loginForm,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: loginForm.email.name,
                  key: loginForm.email.fieldKey,
                  validator: loginForm.email.validations,
                  initialValue: loginForm.email.initialValue.toString(),
                ),
                ElevatedButton(
                  onPressed: () {
                    loginForm.email.fieldKey.currentState?.didChange(100);
                  },
                  child: Text('Submit'),
                ),
              ],
            )),
      ),
    );
  }
}
