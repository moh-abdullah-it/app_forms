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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            AppFormBuilder<LoginForm>(
              builder: (loginForm) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    FormBuilderTextField(
                      name: loginForm.email.name,
                      validator: loginForm.email.validations,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Email'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FormBuilderTextField(
                      name: loginForm.password.name,
                      validator: loginForm.password.validations,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Password'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                );
              },
            ),
            AppFormListener<LoginForm>(
              updateWhen: (form) => form.email.value != null,
              builder: (form) {
                return ElevatedButton(
                    onPressed: form.progressing
                        ? null
                        : () {
                            form.submit();
                          },
                    child: Text('Submit ${form.email.value}'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
