import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

/// Represents a single form field with validation, callbacks, and state management.
///
/// This class encapsulates all the configuration and state for a form field,
/// including validation rules, change callbacks, initial values, and current values.
/// It provides a clean separation between field logic and UI components.
///
/// ## Type Safety:
/// The generic type parameter [T] ensures type safety for field values:
/// - `AppFormField<String>` for text fields
/// - `AppFormField<bool>` for checkboxes
/// - `AppFormField<int>` for numeric fields
/// - `AppFormField<DateTime>` for date fields
///
/// ## Key Features:
/// - **Type Safety**: Generic type parameter for compile-time type checking
/// - **Validation**: Flexible validation rules with FormBuilder integration
/// - **Callbacks**: onChange and onValid event handlers
/// - **State Management**: Tracks current and initial values
/// - **FormBuilder Integration**: Direct integration with flutter_form_builder
///
/// ## Usage:
/// ```dart
/// final email = AppFormField<String>(
///   name: 'email',
///   initialValue: 'user@example.com',
///   validations: FormBuilderValidators.compose([
///     FormBuilderValidators.required(),
///     FormBuilderValidators.email(),
///   ]),
///   onChange: (field) => print('Email changed: ${field?.value}'),
///   onValid: (field) => print('Email is valid: ${field?.value}'),
/// );
/// ```
///
/// ## Lifecycle:
/// 1. Field is created with configuration
/// 2. Field is registered with form via [AppForm.setFields]
/// 3. Field value changes trigger validation and callbacks
/// 4. Field can be programmatically updated via [setValue] or [reset]
class AppFormField<T> {
  /// The global key for the FormBuilderField widget.
  ///
  /// This key provides direct access to the FormBuilder field's state,
  /// allowing for programmatic control over the field's value and validation.
  final GlobalKey<FormBuilderFieldState> fieldKey =
      GlobalKey<FormBuilderFieldState>();
  /// The unique name identifier for this field.
  ///
  /// This name is used as the key in form values and must be unique
  /// within the form. It's also used by FormBuilder to identify the field.
  final String name;
  /// The validation function for this field.
  ///
  /// This function is called to validate the field's value and should
  /// return `null` if valid or an error message string if invalid.
  ///
  /// ## Common Patterns:
  /// ```dart
  /// // Single validator
  /// validations: FormBuilderValidators.required(),
  ///
  /// // Multiple validators
  /// validations: FormBuilderValidators.compose([
  ///   FormBuilderValidators.required(),
  ///   FormBuilderValidators.email(),
  /// ]),
  ///
  /// // Custom validator
  /// validations: (value) {
  ///   if (value?.isEmpty ?? true) return 'Required';
  ///   if (value!.length < 3) return 'Too short';
  ///   return null; // Valid
  /// },
  /// ```
  final String? Function(String?)? validations;

  /// Callback function called when the field value changes.
  ///
  /// This callback is triggered whenever the field's value is modified,
  /// either by user input or programmatic changes. It receives the
  /// FormBuilderFieldState as a parameter.
  ///
  /// ## Parameters:
  /// - [field]: The FormBuilderFieldState containing current value and validation state
  ///
  /// ## Example:
  /// ```dart
  /// onChange: (field) {
  ///   print('Field ${field?.widget.name} changed to: ${field?.value}');
  ///   // React to field changes, update other fields, etc.
  /// },
  /// ```
  final Function(FormBuilderFieldState? field)? onChange;

  /// Callback function called when the field becomes valid.
  ///
  /// This callback is triggered when the field's validation passes.
  /// It's useful for enabling submit buttons, showing success indicators,
  /// or performing actions when the field reaches a valid state.
  ///
  /// ## Parameters:
  /// - [field]: The FormBuilderFieldState containing the valid value
  ///
  /// ## Example:
  /// ```dart
  /// onValid: (field) {
  ///   print('Field ${field?.widget.name} is now valid: ${field?.value}');
  ///   // Enable dependent fields, show success icon, etc.
  /// },
  /// ```
  final Function(FormBuilderFieldState? field)? onValid;

  /// The initial value for this field.
  ///
  /// This value is used when the form is first rendered and when
  /// the field is reset. It can be modified after field creation
  /// if needed.
  T? initialValue;

  /// The current value of this field.
  ///
  /// This property is automatically updated as the field value changes
  /// and can be used to access the current field value programmatically.
  /// It can also be set directly to update the field value.
  T? value;

  /// Creates a new form field with the specified configuration.
  ///
  /// ## Parameters:
  /// - [name]: Unique identifier for the field (required)
  /// - [validations]: Validation function for the field
  /// - [initialValue]: Initial value when the field is created
  /// - [onChange]: Callback for field value changes
  /// - [onValid]: Callback for when field becomes valid
  ///
  /// ## Example:
  /// ```dart
  /// final passwordField = AppFormField<String>(
  ///   name: 'password',
  ///   initialValue: '',
  ///   validations: (value) {
  ///     if (value == null || value.isEmpty) return 'Password required';
  ///     if (value.length < 8) return 'Password too short';
  ///     return null;
  ///   },
  ///   onChange: (field) => _validatePasswordStrength(field?.value),
  ///   onValid: (field) => _enableSubmitButton(),
  /// );
  /// ```
  AppFormField({
    required this.name,
    this.validations,
    this.initialValue,
    this.onChange,
    this.onValid,
  });

  /// Sets the field's value programmatically.
  ///
  /// This method updates the field's value and triggers validation
  /// and change callbacks. It's equivalent to the user changing
  /// the field value through the UI.
  ///
  /// ## Parameters:
  /// - [value]: The new value to set
  ///
  /// ## Example:
  /// ```dart
  /// // Set email field value
  /// emailField.setValue('user@example.com');
  ///
  /// // Clear field value
  /// emailField.setValue(null);
  ///
  /// // Set boolean field
  /// rememberMeField.setValue(true);
  /// ```
  ///
  /// ## Note:
  /// If the field's FormBuilder widget is not yet mounted,
  /// this method will have no effect. Consider using [AppForm.updateFieldsValue]
  /// after setting multiple field values programmatically.
  void setValue(T? value) {
    fieldKey.currentState?.didChange(value);
  }

  /// Resets the field to its initial value.
  ///
  /// This method restores the field to its [initialValue] and
  /// clears any validation errors. It's equivalent to calling
  /// [setValue] with the [initialValue].
  ///
  /// ## Example:
  /// ```dart
  /// // Reset single field
  /// emailField.reset();
  ///
  /// // Reset is typically called as part of form reset
  /// form.reset(); // Resets all fields in the form
  /// ```
  void reset() {
    fieldKey.currentState?.reset();
  }

  /// Gets the parent form's state.
  ///
  /// This getter provides access to the FormBuilderState that contains
  /// this field. It can be used to access other fields in the same form
  /// or trigger form-wide operations.
  ///
  /// ## Returns:
  /// The FormBuilderState if the field is mounted, otherwise `null`.
  ///
  /// ## Example:
  /// ```dart
  /// // Access form values from within a field
  /// final formValues = emailField.formState?.value;
  ///
  /// // Validate entire form from a field
  /// final isFormValid = emailField.formState?.saveAndValidate();
  /// ```
  FormBuilderState? get formState => fieldKey.currentState?.formState;
}
