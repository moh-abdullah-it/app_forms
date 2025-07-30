import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

/// Type definition for form state builder callback function.
///
/// This function receives a form instance and returns a widget tree
/// that should rebuild when the form state changes.
typedef StateWidgetBuilder<T extends AppForm> = Widget Function(T form);

/// A widget that listens to form state changes and rebuilds accordingly.
///
/// This widget automatically rebuilds whenever the form's state changes,
/// such as when fields are validated, form submission starts/ends, or
/// loading/error states are updated. It's perfect for displaying submit
/// buttons, status messages, and other UI elements that depend on form state.
///
/// ## Key Features:
/// - **Reactive Rebuilds**: Automatically rebuilds when form state changes
/// - **State Access**: Provides access to form's loading, error, success states
/// - **Automatic Registration**: Registers itself with the form for updates
/// - **Type Safety**: Generic type parameter ensures compile-time type checking
///
/// ## Common Use Cases:
/// - Submit buttons that disable during form submission
/// - Loading indicators during form operations
/// - Error messages based on form validation state
/// - Success messages after form submission
/// - Dynamic UI based on form field values
///
/// ## Usage:
/// ```dart
/// AppFormListener<LoginForm>(
///   builder: (form) {
///     return Column(
///       children: [
///         ElevatedButton(
///           onPressed: form.progressing ? null : form.submit,
///           child: form.progressing
///             ? CircularProgressIndicator()
///             : Text('Login'),
///         ),
///         if (form.hasErrors)
///           Text('Please fix errors above', style: TextStyle(color: Colors.red)),
///         if (form.success)
///           Text('Login successful!', style: TextStyle(color: Colors.green)),
///       ],
///     );
///   },
/// )
/// ```
///
/// ## State Properties Available:
/// - `form.progressing`: Whether form is being submitted
/// - `form.loading`: Whether form is in loading state
/// - `form.hasErrors`: Whether form has validation errors
/// - `form.success`: Whether form operation was successful
/// - `form.fieldName.value`: Access to individual field values
///
/// ## Type Parameter:
/// - [T]: The form class type (must extend [AppForm])
class AppFormListener<T extends AppForm> extends StatelessWidget {
  /// The builder function that creates the reactive UI.
  ///
  /// This function receives the form instance and should return a widget
  /// tree that depends on the form's state. The widget tree will be
  /// rebuilt whenever the form state changes.
  ///
  /// ## Example:
  /// ```dart
  /// builder: (form) {
  ///   return ElevatedButton(
  ///     onPressed: form.progressing ? null : () {
  ///       if (form.saveAndValidate() ?? false) {
  ///         form.submit();
  ///       }
  ///     },
  ///     child: form.progressing
  ///       ? Row(
  ///           mainAxisSize: MainAxisSize.min,
  ///           children: [
  ///             SizedBox(
  ///               width: 16,
  ///               height: 16,
  ///               child: CircularProgressIndicator(strokeWidth: 2),
  ///             ),
  ///             SizedBox(width: 8),
  ///             Text('Submitting...'),
  ///           ],
  ///         )
  ///       : Text('Submit'),
  ///   );
  /// }
  /// ```
  final StateWidgetBuilder<T> builder;
  
  /// Creates an [AppFormListener] widget.
  ///
  /// The constructor automatically registers this listener with the form
  /// instance to receive state change notifications.
  ///
  /// ## Parameters:
  /// - [key]: Widget key for the listener
  /// - [builder]: Function that builds the reactive UI (required)
  ///
  /// ## Example:
  /// ```dart
  /// AppFormListener<RegistrationForm>(
  ///   builder: (form) => SubmitButton(form: form),
  /// )
  /// ```
  AppFormListener({super.key, required this.builder}) {
    // Register this listener with the form for state change notifications
    AppForms.get<T>().listener = this;
  }
  /// Internal setState function provided by StatefulBuilder.
  ///
  /// This function is used to trigger rebuilds when the form state changes.
  /// It's automatically set by the StatefulBuilder widget.
  late void Function(void Function()) setState;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, void Function(void Function()) setState) {
        // Store the setState function for later use in update()
        this.setState = setState;
        
        // Get the form instance and build the UI
        final form = AppForms.get<T>();
        return builder(form);
      },
    );
  }

  /// Triggers a rebuild of this listener widget.
  ///
  /// This method is called internally by the [AppForm] when its state changes.
  /// It causes the [builder] function to be called again with the updated
  /// form state, allowing the UI to reflect the current form state.
  ///
  /// This method should not be called directly by user code - it's automatically
  /// called by the form when state changes occur.
  ///
  /// ## Internal Usage:
  /// The form calls this method in scenarios such as:
  /// - Field validation state changes
  /// - Form submission starts/ends ([AppForm.submit])
  /// - Loading state changes ([AppForm.setLoading])
  /// - Error state changes ([AppForm.setHasErrors])
  /// - Success state changes ([AppForm.setSuccess])
  void update() {
    setState(() {
      // Empty setState call to trigger rebuild
      // The actual state is in the form instance
    });
  }
}
