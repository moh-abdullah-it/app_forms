/// App Forms - A powerful Flutter package for form management.
/// 
/// This library provides a clean architecture for separating form logic
/// from UI components using flutter_form_builder. It includes dependency
/// injection, reactive state management, and comprehensive form handling.
///
/// ## Main Components:
/// 
/// ### Core Classes:
/// - [AppForm]: Abstract base class for all forms
/// - [AppFormField]: Type-safe field configuration and management
/// - [AppForms]: Dependency injection service for forms
/// 
/// ### Widget Components:
/// - [AppFormBuilder]: Connects forms to FormBuilder UI
/// - [AppFormListener]: Reactive widget for form state changes
/// 
/// ### Utilities:
/// - [Debouncer]: Performance optimization for field changes
/// 
/// ## Quick Start:
/// 
/// ```dart
/// // 1. Create a form class
/// class LoginForm extends AppForm {
///   final email = AppFormField<String>(
///     name: 'email',
///     validations: FormBuilderValidators.email(),
///   );
///   
///   LoginForm() {
///     setFields([email]);
///   }
///   
///   @override
///   Future<void> onSubmit(Map<String, dynamic>? values) async {
///     // Handle submission
///   }
/// }
/// 
/// // 2. Inject forms in main.dart
/// void main() {
///   AppForms.injectForms([LoginForm()]);
///   runApp(MyApp());
/// }
/// 
/// // 3. Use in widgets
/// AppFormBuilder<LoginForm>(
///   builder: (form) => /* Your UI */,
/// )
/// ```
/// 
/// ## Features:
/// - 🏗️ Clean Architecture: Separate form logic from UI
/// - 💉 Dependency Injection: Global form management
/// - 🔄 Reactive State Management: Real-time updates
/// - ⚡ Auto-validation: Configurable with debouncing
/// - 🎯 Type Safety: Generic type support
/// - 📋 Field Management: Advanced operations
/// - 🔍 State Tracking: Loading, progress, error states
/// - 🎭 Lifecycle Hooks: Complete form lifecycle management
/// 
/// For detailed documentation and examples, visit:
/// https://pub.dev/packages/app_forms
library app_forms;

// Export flutter_form_builder for convenience
// Users can access FormBuilderTextField, FormBuilderValidators, etc.
export 'package:flutter_form_builder/flutter_form_builder.dart';

// Core form management classes
export 'src/app_form.dart';
export 'src/app_form_field.dart';
export 'src/app_forms.dart';

// UI widget components
export 'src/widgets/app_form_builder.dart';
export 'src/widgets/app_form_listener.dart';

// Note: Debouncer is intentionally not exported as it's an internal utility
// Users don't need direct access to it - it's used internally by AppForm
