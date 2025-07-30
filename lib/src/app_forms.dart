import 'package:app_forms/app_forms.dart';

/// Global registry for form instances.
/// 
/// Maps form type names to their instances for dependency injection.
final Map<String, AppForm> _forms = {};

/// Tracks which forms have been initialized.
/// 
/// Prevents multiple initialization calls to the same form instance.
final Map<String, bool> _initForms = {};

/// Dependency injection service for managing form instances.
///
/// This class provides a singleton pattern for form management, allowing
/// forms to be injected globally and accessed from anywhere in the app.
/// It handles form lifecycle management including initialization and disposal.
///
/// ## Key Features:
/// - **Global Access**: Forms can be accessed from any widget
/// - **Lazy Initialization**: Forms are initialized only when first accessed
/// - **Type Safety**: Generic type parameter ensures type-safe form retrieval
/// - **Lifecycle Management**: Automatic initialization and disposal handling
///
/// ## Usage:
/// ```dart
/// // 1. Inject forms in main.dart
/// void main() {
///   AppForms.injectForms([LoginForm(), RegisterForm()]);
///   runApp(MyApp());
/// }
///
/// // 2. Access forms in widgets
/// class LoginPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return AppFormBuilder<LoginForm>(
///       builder: (form) => /* UI using form */,
///     );
///   }
/// }
/// ```
///
/// ## Lifecycle:
/// 1. Forms are registered via [injectForms]
/// 2. Forms are retrieved via [get] (triggers [AppForm.onInit] on first access)
/// 3. Forms can be disposed via [dispose] to reset initialization state
class AppForms<T extends AppForm> {
  /// Injects a list of form instances into the global registry.
  ///
  /// This method should be called once during app initialization,
  /// typically in the `main()` function before calling `runApp()`.
  ///
  /// ## Parameters:
  /// - [formsList]: List of form instances to register globally
  ///
  /// ## Example:
  /// ```dart
  /// void main() {
  ///   AppForms.injectForms([
  ///     LoginForm(),
  ///     RegisterForm(),
  ///     ProfileForm(),
  ///   ]);
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## Important Notes:
  /// - Each form type should only be injected once
  /// - Forms are identified by their runtime type name
  /// - Injecting the same form type multiple times will override the previous instance
  static void injectForms(List<AppForm> formsList) {
    for (final form in formsList) {
      _forms[form.runtimeType.toString()] = form;
    }
  }

  /// Retrieves a form instance by its type.
  ///
  /// This method provides type-safe access to injected forms.
  /// On first access, it automatically calls [AppForm.onInit] to
  /// initialize the form.
  ///
  /// ## Type Parameter:
  /// - [T]: The form class type to retrieve (must extend [AppForm])
  ///
  /// ## Returns:
  /// The form instance of type [T]
  ///
  /// ## Throws:
  /// - [Exception]: If the requested form type was not injected
  ///
  /// ## Example:
  /// ```dart
  /// class LoginPage extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final loginForm = AppForms.get<LoginForm>();
  ///     // Use form...
  ///   }
  /// }
  /// ```
  ///
  /// ## Automatic Initialization:
  /// The first call to `get<T>()` for any form type will:
  /// 1. Call the form's [AppForm.onInit] method
  /// 2. Mark the form as initialized to prevent duplicate calls
  /// 3. Return the initialized form instance
  static T get<T extends AppForm>() {
    final formTypeName = T.toString();
    
    if (!_forms.containsKey(formTypeName)) {
      throw Exception('Form $formTypeName not found. '
          'Make sure to inject it using AppForms.injectForms() before use.');
    }
    
    final form = _forms[formTypeName]! as T;
    
    // Initialize form on first access
    if (!_initForms.containsKey(formTypeName)) {
      form.onInit();
      _initForms[formTypeName] = true;
    }
    
    return form;
  }

  /// Disposes a form's initialization state.
  ///
  /// This method resets the initialization flag for a form type,
  /// allowing [AppForm.onInit] to be called again on the next
  /// access via [get].
  ///
  /// This is typically called by [AppFormBuilder] when the form
  /// widget is disposed (e.g., when navigating away from a page).
  ///
  /// ## Type Parameter:
  /// - [T]: The form class type to dispose
  ///
  /// ## Example:
  /// ```dart
  /// // Manual disposal (rarely needed)
  /// AppForms.dispose<LoginForm>();
  /// 
  /// // The next call to get<LoginForm>() will trigger onInit again
  /// final form = AppForms.get<LoginForm>(); // onInit called
  /// ```
  ///
  /// ## Note:
  /// This method does not remove the form instance from the registry,
  /// only resets its initialization state. The form instance remains
  /// available for future access.
  static void dispose<T extends AppForm>() {
    _initForms.remove(T.toString());
  }
}
