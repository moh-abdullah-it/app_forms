# App Forms
 This package help you to Organize folders Structure and Forms Logic. **package in development**

## Getting started

* Install package:
``` shell
 flutter pub add app_forms
```

## Using
* Create Form Class For Logic:

```` dart
class LoginForm extends AppForm {
/// form logic
}
````

* Declare Form Fields:

```` dart
class LoginForm extends AppForm {

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
    setFields([email, password]);
  }
}
````

* Inject Forms in `main.dart`:

```` dart
  AppForms.injectForms([LoginForm()]);
````

* Create User View `login_page.dart`:

```` dart
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
````