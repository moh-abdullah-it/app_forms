import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

/// Type definition for form state builder callback function.
///
/// This function receives a form instance and returns a widget tree
/// that should rebuild when the form state changes.
typedef StateWidgetBuilder<T extends AppForm> = Widget Function(T form);

/// Type definition for update condition callback function.
///
/// This function receives a form instance and returns a boolean indicating
/// whether the widget should rebuild in response to form state changes.
typedef UpdateWhenCallback<T extends AppForm> = bool Function(T form);

/// Interface for objects that can receive form state updates.
///
/// This interface ensures type safety when the form needs to notify
/// listeners about state changes.
abstract class AppFormListenerInterface {
  /// Called when the form state changes and the listener should update.
  void update();
}

/// A widget that listens to form state changes and rebuilds accordingly.
///
/// This widget automatically rebuilds whenever the form's state changes,
/// such as when fields are validated, form submission starts/ends, or
/// loading/error states are updated. It's perfect for displaying submit
/// buttons, status messages, and other UI elements that depend on form state.
///
/// ## Key Features:
/// - **Reactive Rebuilds**: Automatically rebuilds when form state changes
/// - **Conditional Updates**: Optional [updateWhen] callback for performance optimization
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
/// // Basic usage - rebuilds on any form state change
/// AppFormListener<LoginForm>(
///   builder: (form) {
///     return ElevatedButton(
///       onPressed: form.progressing ? null : form.submit,
///       child: form.progressing
///         ? CircularProgressIndicator()
///         : Text('Login'),
///     );
///   },
/// )
///
/// // With updateWhen - only rebuilds when specific conditions are met
/// AppFormListener<LoginForm>(
///   updateWhen: (form) => form.progressing || form.hasErrors,
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
class AppFormListener<T extends AppForm> extends StatefulWidget {
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
  
  /// Optional callback to control when the widget should rebuild.
  ///
  /// This function is called before each potential rebuild to determine
  /// if the widget should actually rebuild. If this callback returns `false`,
  /// the rebuild is skipped, providing performance optimization for complex UIs.
  ///
  /// ## Parameters:
  /// - [form]: The current form instance with updated state
  ///
  /// ## Returns:
  /// `true` if the widget should rebuild, `false` to skip the rebuild
  ///
  /// ## Performance Benefits:
  /// - Prevents unnecessary rebuilds when irrelevant state changes
  /// - Reduces widget tree rebuilds for better performance
  /// - Allows fine-grained control over rebuild conditions
  ///
  /// ## Example:
  /// ```dart
  /// // Only rebuild when form is progressing or has errors
  /// updateWhen: (form) => form.progressing || form.hasErrors,
  ///
  /// // Only rebuild when specific field values change
  /// updateWhen: (form) => form.email.value != _lastEmailValue,
  ///
  /// // Only rebuild during form submission states
  /// updateWhen: (form) => form.progressing || form.success,
  /// ```
  final UpdateWhenCallback<T>? updateWhen;
  
  /// Creates an [AppFormListener] widget.
  ///
  /// The constructor automatically registers this listener with the form
  /// instance to receive state change notifications.
  ///
  /// ## Parameters:
  /// - [key]: Widget key for the listener
  /// - [builder]: Function that builds the reactive UI (required)
  /// - [updateWhen]: Optional callback to control when rebuilds occur
  ///
  /// ## Example:
  /// ```dart
  /// // Basic listener - rebuilds on any state change
  /// AppFormListener<RegistrationForm>(
  ///   builder: (form) => SubmitButton(form: form),
  /// )
  ///
  /// // Optimized listener - only rebuilds when needed
  /// AppFormListener<RegistrationForm>(
  ///   updateWhen: (form) => form.progressing || form.success,
  ///   builder: (form) => SubmitButton(form: form),
  /// )
  /// ```
  const AppFormListener({
    super.key, 
    required this.builder,
    this.updateWhen,
  });

  @override
  State<AppFormListener<T>> createState() => _AppFormListenerState<T>();
}

class _AppFormListenerState<T extends AppForm> extends State<AppFormListener<T>> implements AppFormListenerInterface {
  @override
  void initState() {
    super.initState();
    // Defer listener registration until after the first build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppForms.get<T>().listener = this;
      }
    });
  }

  @override
  void dispose() {
    // Unregister this listener to prevent memory leaks
    final form = AppForms.get<T>();
    if (form.listener == this) {
      form.listener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the form instance and build the UI
    final form = AppForms.get<T>();
    return widget.builder(form);
  }

  /// Triggers a rebuild of this listener widget if conditions are met.
  ///
  /// This method is called internally by the [AppForm] when its state changes.
  /// If an [updateWhen] callback is provided, it's evaluated first to determine
  /// if the rebuild should proceed. This provides performance optimization by
  /// preventing unnecessary rebuilds when irrelevant state changes occur.
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
  ///
  /// ## Conditional Updates:
  /// When [updateWhen] is provided:
  /// 1. The callback is called with the current form state
  /// 2. If it returns `true`, the widget rebuilds
  /// 3. If it returns `false`, the rebuild is skipped
  /// 4. If [updateWhen] is null, the widget always rebuilds
  @override
  void update() {
    // Check if the widget is still mounted before attempting to setState
    if (!mounted) return;
    
    // Check if we should update based on the updateWhen callback
    if (widget.updateWhen != null) {
      final form = AppForms.get<T>();
      if (!widget.updateWhen!(form)) {
        // Skip rebuild if updateWhen returns false
        return;
      }
    }
    
    setState(() {
      // Empty setState call to trigger rebuild
      // The actual state is in the form instance
    });
  }
}
