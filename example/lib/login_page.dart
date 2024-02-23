import 'package:app_forms/app_forms.dart';
import 'package:example/forms/login_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: AppFormBuilder<LoginForm>(
        builder: (loginForm) {
          return Column(
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
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
