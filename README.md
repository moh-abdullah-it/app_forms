# App Forms

[![Pub Version](https://img.shields.io/pub/v/app_forms)](https://pub.dev/packages/app_forms)
[![License](https://img.shields.io/github/license/moh-abdullah-it/app_forms)](https://github.com/moh-abdullah-it/app_forms/blob/main/LICENSE)

A powerful Flutter package that separates form logic from UI components using `flutter_form_builder`. Build maintainable, testable, and reusable forms with clean architecture principles.

## ✨ Features

- **🏗️ Clean Architecture**: Separate form logic from UI components
- **💉 Dependency Injection**: Global form management with singleton pattern
- **🔄 Reactive State Management**: Real-time form state updates and validation
- **⚡ Auto-validation**: Configurable automatic field validation with debouncing
- **🎯 Type Safety**: Generic type support for form fields
- **📋 Field Management**: Advanced field operations (setValue, reset, validation)
- **🔍 Form State Tracking**: Built-in loading, progress, error, and success states
- **🎭 Lifecycle Hooks**: onInit, onSubmit, onValid, and onReset callbacks
- **🚀 Performance Optimized**: Debounced field changes (250ms) for optimal performance
- **📦 Easy Integration**: Works seamlessly with flutter_form_builder

## 🚀 Quick Start

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  app_forms: ^0.7.0
  form_builder_validators: ^11.2.0
```

### Basic Usage

#### 1. Create Your Form Class

```dart
import 'package:app_forms/app_forms.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginForm extends AppForm {
  // Configure auto-validation
  @override
  bool get autoValidate => true;

  // Define form fields with validation and callbacks
  final email = AppFormField<String>(
    name: 'email',
    initialValue: 'user@example.com',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.email(),
    ]),
    onChange: (field) {
      print('Email changed: ${field?.value}');
    },
    onValid: (field) {
      print('Email is valid: ${field?.value}');
    },
  );

  final password = AppFormField<String>(
    name: 'password',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.minLength(6),
    ]),
  );

  LoginForm() {
    setFields([email, password]);
  }

  @override
  Future<void> onInit() async {
    // Initialize form data, API calls, etc.
    print('Form initialized');
  }

  @override
  Future<void> onSubmit(Map<String, dynamic>? values) async {
    // Handle form submission
    print('Submitting: $values');
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setSuccess(true);
    } catch (e) {
      setHasErrors(true);
    }
  }

  @override
  Future<void> onValid(Map<String, dynamic>? values) async {
    // Called when form becomes valid
    print('Form is valid: $values');
  }

  @override
  void onReset() {
    // Handle form reset
    print('Form reset');
  }
}
```

#### 2. Inject Forms in main.dart

```dart
import 'package:app_forms/app_forms.dart';

void main() {
  // Inject your forms globally
  AppForms.injectForms([
    LoginForm(),
    // Add other forms here
  ]);
  
  runApp(MyApp());
}
```

#### 3. Build Your UI

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Builder - handles form state and validation
            AppFormBuilder<LoginForm>(
              builder: (form) {
                return Column(
                  children: [
                    FormBuilderTextField(
                      name: form.email.name,
                      validator: form.email.validations,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: form.password.name,
                      validator: form.password.validations,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Form Listener - reacts to form state changes
            AppFormListener<LoginForm>(
              builder: (form) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: form.progressing ? null : form.submit,
                      child: form.progressing
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                    if (form.hasErrors)
                      const Text(
                        'Please fix errors above',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (form.success)
                      const Text(
                        'Login successful!',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📚 Advanced Features

### Form State Management

```dart
class MyForm extends AppForm {
  void customAction() {
    // Control form states
    setLoading(true);        // Show loading state
    setHasErrors(false);     // Clear errors
    setSuccess(false);       // Clear success state
    
    // Access form values
    final values = getValues();
    
    // Validate programmatically
    final isValid = saveAndValidate();
    
    // Reset form
    reset();
  }
}
```

### Dynamic Field Updates

```dart
class MyForm extends AppForm {
  void updateFieldValue() {
    // Update field value programmatically
    email.value = 'new@example.com';
    updateFieldsValue(); // Sync with form builder
  }
  
  void setServerErrors(Map<String, dynamic> errors) {
    // Set validation errors from server
    setValidationErrors({
      'email': 'Email already exists',
      'password': 'Password too weak'
    });
  }
}
```

### Custom Validation

```dart
final customField = AppFormField<String>(
  name: 'username',
  validations: (value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null; // Valid
  },
);
```

## 🏛️ Architecture

### Core Components

- **AppForm**: Abstract base class for all forms
- **AppFormField**: Type-safe field configuration
- **AppForms**: Singleton service for dependency injection
- **AppFormBuilder**: Widget wrapper connecting forms to UI
- **AppFormListener**: Reactive widget for form state changes

### Flow Diagram

```
Form Definition → Dependency Injection → UI Binding → State Management
     ↓                    ↓                ↓             ↓
  AppForm           AppForms.inject    AppFormBuilder  AppFormListener
```

## 🔧 Configuration Options

### Auto-validation Control

```dart
class MyForm extends AppForm {
  @override
  bool get autoValidate => false; // Disable auto-validation
}
```

### Custom Debouncing

The package uses a 250ms debouncer by default. This is configured internally but optimized for most use cases.

## 🧪 Testing

```dart
void main() {
  group('LoginForm Tests', () {
    late LoginForm form;
    
    setUp(() {
      form = LoginForm();
      AppForms.injectForms([form]);
    });
    
    test('should validate email field', () {
      form.email.setValue('invalid-email');
      expect(form.saveAndValidate(), false);
      
      form.email.setValue('valid@email.com');
      expect(form.saveAndValidate(), true);
    });
  });
}
```

## 📖 API Reference

See the [API documentation](https://pub.dev/documentation/app_forms/latest/) for detailed information about all available methods and properties.

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) and submit pull requests to our [GitHub repository](https://github.com/moh-abdullah-it/app_forms).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📁 [GitHub Issues](https://github.com/moh-abdullah-it/app_forms/issues)
- 📦 [Pub.dev Package](https://pub.dev/packages/app_forms)
- 📧 [Email Support](mailto:support@example.com)