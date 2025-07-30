import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

/// Type definition for form builder callback function.
///
/// This function receives a form instance and returns a widget tree
/// that represents the form's UI.
typedef WidgetBuilder<T extends AppForm> = Widget Function(T form);

/// A widget that builds form UI using an [AppForm] instance.
///
/// This widget acts as a bridge between the [AppForm] logic and the
/// FormBuilder UI components. It automatically retrieves the form instance
/// from the dependency injection system and provides it to the builder function.
///
/// ## Key Features:
/// - **Automatic Form Retrieval**: Gets form instance via [AppForms.get]
/// - **FormBuilder Integration**: Wraps content in a FormBuilder widget
/// - **Change Detection**: Automatically calls [AppForm.onChange] on field changes
/// - **Lifecycle Management**: Handles form disposal on widget disposal
/// - **Type Safety**: Generic type parameter ensures compile-time type checking
///
/// ## Usage:
/// ```dart
/// AppFormBuilder<LoginForm>(
///   builder: (loginForm) {
///     return Column(
///       children: [
///         FormBuilderTextField(
///           name: loginForm.email.name,
///           validator: loginForm.email.validations,
///           decoration: InputDecoration(labelText: 'Email'),
///         ),
///         FormBuilderTextField(
///           name: loginForm.password.name,
///           validator: loginForm.password.validations,
///           obscureText: true,
///           decoration: InputDecoration(labelText: 'Password'),
///         ),
///       ],
///     );
///   },
/// )
/// ```
///
/// ## Integration with FormBuilder:
/// This widget automatically configures the FormBuilder with:
/// - Form key from the [AppForm] instance
/// - Initial values from form fields
/// - Change callbacks that trigger form logic
/// - Form disposal on widget removal
///
/// ## Type Parameter:
/// - [T]: The form class type (must extend [AppForm])
class AppFormBuilder<T extends AppForm> extends StatelessWidget {
  /// Called when one of the form fields changes.
  ///
  /// This callback is invoked in addition to the form's internal change handling.
  /// All form fields will rebuild when this callback is triggered.
  final VoidCallback? onChanged;

  /// Called when a pop navigation is invoked.
  ///
  /// This callback is triggered when the user attempts to navigate back
  /// (via back button, swipe gesture, etc.). It can be used to show
  /// confirmation dialogs or save form data before navigation.
  ///
  /// The form is automatically disposed when navigation occurs.
  final void Function(bool)? onPopInvoked;

  /// Whether the form can be popped by the user.
  ///
  /// When set to `false`, prevents automatic navigation when the user
  /// attempts to go back. Use in conjunction with [onPopInvoked] to
  /// show confirmation dialogs or validate form state before allowing navigation.
  final bool? canPop;

  // Note: child parameter not used - content is provided via builder function

  /// Controls when form fields are automatically validated.
  ///
  /// This setting works in conjunction with the form's [AppForm.autoValidate]
  /// property to control validation behavior.
  final AutovalidateMode? autoValidateMode;

  /// Whether to exclude disabled fields from form values.
  ///
  /// When `true`, disabled fields are not included in the form's value map.
  /// When `false`, disabled fields are included (read-only behavior).
  ///
  /// Defaults to `false`.
  final bool skipDisabled;

  /// Whether the entire form accepts user input.
  ///
  /// When `false`, all form fields become disabled regardless of their
  /// individual enabled state. Defaults to `true`.
  final bool enabled;

  /// Whether to clear field values when fields are disposed.
  ///
  /// When `true`, field values are cleared when their widgets are disposed.
  /// This is useful for dynamic forms where fields appear and disappear.
  ///
  /// Defaults to `false`.
  final bool clearValueOnUnregister;

  /// The builder function that creates the form's UI.
  ///
  /// This function receives the form instance and should return a widget
  /// tree that represents the form's user interface. The form instance
  /// provides access to all field configurations and form state.
  ///
  /// ## Example:
  /// ```dart
  /// builder: (form) {
  ///   return Column(
  ///     children: [
  ///       FormBuilderTextField(
  ///         name: form.email.name,
  ///         validator: form.email.validations,
  ///       ),
  ///       // More fields...
  ///     ],
  ///   );
  /// }
  /// ```
  final WidgetBuilder<T> builder;

  /// Creates an [AppFormBuilder] widget.
  ///
  /// ## Parameters:
  /// - [builder]: Function that builds the form UI (required)
  /// - [onChanged]: Callback for form field changes
  /// - [onPopInvoked]: Callback for navigation pop events
  /// - [canPop]: Whether the form can be popped
  /// - [autoValidateMode]: When to automatically validate fields
  /// - [skipDisabled]: Whether to exclude disabled fields from values
  /// - [enabled]: Whether the entire form accepts input
  /// - [clearValueOnUnregister]: Whether to clear values when fields are disposed
  ///
  /// ## Example:
  /// ```dart
  /// AppFormBuilder<LoginForm>(
  ///   builder: (form) => LoginFormUI(form),
  ///   onChanged: () => print('Form changed'),
  ///   autoValidateMode: AutovalidateMode.onUserInteraction,
  /// )
  /// ```
   AppFormBuilder({
    super.key,
    required this.builder,
    this.onChanged,
    this.onPopInvoked,
    this.canPop,
    this.autoValidateMode,
    this.skipDisabled = false,
    this.enabled = true,
    this.clearValueOnUnregister = false,
  });

  /// Cached form instance to avoid repeated lookups.
  T? _cachedForm;
  
  /// Cached initial values to detect if they changed.
  Map<String, dynamic>? _cachedInitialValues;
  
  @override
  Widget build(BuildContext context) {
    // Use cached form instance or get new one
    _cachedForm ??= AppForms.get<T>();
    final form = _cachedForm!;
    
    // Check if initial values changed (rare but possible)
    if (_cachedInitialValues == null || 
        !_mapEquals(_cachedInitialValues!, form.initialValue)) {
      _cachedInitialValues = Map<String, dynamic>.from(form.initialValue);
    }
    
    return FormBuilder(
      key: form.formKey,
      onChanged: () {
        // Trigger form's internal change handling
        form.onChange();
        // Call external change callback if provided
        onChanged?.call();
      },
      onPopInvokedWithResult: (didPop, result) {
        // Clear cache and dispose form when navigation occurs
        _cachedForm = null;
        _cachedInitialValues = null;
        AppForms.dispose<T>();
        onPopInvoked?.call(didPop);
      },
      canPop: canPop,
      autovalidateMode: autoValidateMode,
      initialValue: _cachedInitialValues!,
      skipDisabled: skipDisabled,
      enabled: enabled,
      clearValueOnUnregister: clearValueOnUnregister,
      child: builder(form),
    );
  }
  
  /// Helper method to compare maps for equality.
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    
    return true;
  }
}
