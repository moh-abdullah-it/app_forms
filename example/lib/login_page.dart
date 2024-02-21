import 'package:app_forms/app_forms.dart';
import 'package:example/forms/login_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final loginForm = LoginForm();

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
                  validator: loginForm.email.validations,
                ),
                FormBuilderTextField(
                  name: loginForm.password.name,
                  validator: loginForm.password.validations,
                ),
                ElevatedButton(
                  onPressed: () {
                    loginForm.submit();
                  },
                  child: Text('Submit'),
                ),
              ],
            )),
      ),
    );
  }
}