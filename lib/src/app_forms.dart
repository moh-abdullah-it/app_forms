import 'package:app_forms/app_forms.dart';
import 'package:flutter/foundation.dart';

/// Mixin for forms that need cleanup on disposal.
/// 
/// Forms can implement this mixin to provide custom cleanup logic
/// that will be called when the form is disposed.
mixin _DisposableForm {
  /// Called when the form is disposed to perform cleanup.
  /// 
  /// Override this method to clean up resources, cancel timers,
  /// close streams, or perform other cleanup operations.
  void _cleanup() {
    // Default implementation - can be overridden
  }
}

/// Global registry for form instances.
/// 
/// Maps form type names to their instances for dependency injection.
final Map<String, AppForm> _forms = {};

/// Tracks which forms have been initialized.
/// 
/// Prevents multiple initialization calls to the same form instance.
final Map<String, bool> _initForms = {};

/// Cache for form initialization futures to prevent concurrent initialization.
/// 
/// Ensures only one initialization occurs even with concurrent access.
final Map<String, Future<void>> _initializationFutures = {};

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

  /// Retrieves a form instance by its type with optimized initialization.
  ///
  /// This method provides type-safe access to injected forms.
  /// On first access, it automatically calls [AppForm.onInit] to
  /// initialize the form using concurrent-safe initialization.
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
  /// ## Optimized Initialization:
  /// The first call to `get<T>()` for any form type will:
  /// 1. Use cached initialization future to prevent concurrent calls
  /// 2. Call the form's [AppForm.onInit] method only once
  /// 3. Mark the form as initialized to prevent duplicate calls
  /// 4. Return the initialized form instance
  static T get<T extends AppForm>() {
    final formTypeName = T.toString();
    
    if (!_forms.containsKey(formTypeName)) {
      throw Exception('Form $formTypeName not found. '
          'Make sure to inject it using AppForms.injectForms() before use.');
    }
    
    final form = _forms[formTypeName]! as T;
    
    // Initialize form on first access with concurrency protection
    if (!_initForms.containsKey(formTypeName)) {
      // Use cached future to prevent concurrent initialization
      _initializationFutures[formTypeName] ??= _initializeForm(form, formTypeName);
      // Note: We don't await here to keep the method synchronous
      // The form is usable immediately, initialization happens in background
    }
    
    return form;
  }
  
  /// Internal method to handle form initialization safely.
  ///
  /// This method ensures thread-safe initialization and proper cleanup.
  static Future<void> _initializeForm(AppForm form, String formTypeName) async {
    try {
      await form.onInit();
      _initForms[formTypeName] = true;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing form $formTypeName: $e');
      // Remove from cache so it can be retried
      _initializationFutures.remove(formTypeName);
      rethrow;
    }
  }

  /// Disposes a form's initialization state with cleanup.
  ///
  /// This method resets the initialization flag for a form type,
  /// allowing [AppForm.onInit] to be called again on the next
  /// access via [get]. It also cleans up caches and resources.
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
  /// ## Cleanup Operations:
  /// This method performs the following cleanup:
  /// - Resets initialization state
  /// - Clears initialization future cache
  /// - Triggers form-specific cleanup if available
  static void dispose<T extends AppForm>() {
    final formTypeName = T.toString();
    _initForms.remove(formTypeName);
    _initializationFutures.remove(formTypeName);
    
    // Trigger form cleanup if form exists and has cleanup method
    final form = _forms[formTypeName];
    if (form != null) {
      // Call cleanup if form implements the mixin
      if (form is _DisposableForm) {
        (form as _DisposableForm)._cleanup();
      }
      
      // Clear form's internal caches using duck typing
      try {
        // Use dynamic call to avoid reflection dependencies
        (form as dynamic).clearValidationCache?.call();
      } catch (e) {
        // Method doesn't exist or error calling it - ignore
        debugPrint('Note: Form cleanup method not available: $e');
      }
    }
  }
}
