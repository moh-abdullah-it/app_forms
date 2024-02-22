import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

typedef Builder<T extends AppForm> = Widget Function(T form);

class AppFormBuilder<T extends AppForm> extends StatelessWidget {
  /// Called when one of the form fields changes.
  ///
  /// In addition to this callback being invoked, all the form fields themselves
  /// will rebuild.
  final VoidCallback? onChanged;

  /// {@macro flutter.widgets.navigator.onPopInvoked}
  ///
  /// {@tool dartpad}
  /// This sample demonstrates how to use this parameter to show a confirmation
  /// dialog when a navigation pop would cause form data to be lost.
  ///
  /// ** See code in examples/api/lib/widgets/form/form.1.dart **
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [canPop], which also comes from [PopScope] and is often used in
  ///    conjunction with this parameter.
  ///  * [PopScope.onPopInvoked], which is what [Form] delegates to internally.ther widget that provides a way to intercept the
  ///    back button.
  final void Function(bool)? onPopInvoked;

  /// {@macro flutter.widgets.PopScope.canPop}
  ///
  /// {@tool dartpad}
  /// This sample demonstrates how to use this parameter to show a confirmation
  /// dialog when a navigation pop would cause form data to be lost.
  ///
  /// ** See code in examples/api/lib/widgets/form/form.1.dart **
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onPopInvoked], which also comes from [PopScope] and is often used in
  ///    conjunction with this parameter.
  ///  * [PopScope.canPop], which is what [Form] delegates to internally.
  final bool? canPop;

  /// The widget below this widget in the tree.
  ///
  /// This is the root of the widget hierarchy that contains this form.
  ///
  /// {@macro flutter.widgets.child}
  //final Widget child;

  /// Used to enable/disable form fields auto validation and update their error
  /// text.
  ///
  /// {@macro flutter.widgets.form.autovalidateMode}
  final AutovalidateMode? autoValidateMode;

  /// Whether the form should ignore submitting values from fields where
  /// `enabled` is `false`.
  ///
  /// This behavior is common in HTML forms where _readonly_ values are not
  /// submitted when the form is submitted.
  ///
  /// `true` = Disabled / `false` = Read only
  ///
  /// When `true`, the final form value will not contain disabled fields.
  /// Default is `false`.
  final bool skipDisabled;

  /// Whether the form is able to receive user input.
  ///
  /// Defaults to true.
  ///
  /// When `false` all the form fields will be disabled - won't accept input -
  /// and their enabled state will be ignored.
  final bool enabled;

  /// Whether to clear the internal value of a field when it is unregistered.
  ///
  /// Defaults to `false`.
  ///
  /// When set to `true`, the form builder will not keep the internal values
  /// from disposed [FormBuilderField]s. This is useful for dynamic forms where
  /// fields are registered and unregistered due to state change.
  ///
  /// This setting will have no effect when registering a field with the same
  /// name as the unregistered one.
  final bool clearValueOnUnregister;

  final Builder<T> builder;

  const AppFormBuilder({
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

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: AppForms.get<T>().formKey,
      onChanged: () {
        AppForms.get<T>().onChange();
        onChanged?.call();
      },
      onPopInvoked: onPopInvoked,
      canPop: canPop,
      autovalidateMode: autoValidateMode,
      initialValue: AppForms.get<T>().initialValue,
      skipDisabled: skipDisabled,
      enabled: enabled,
      clearValueOnUnregister: clearValueOnUnregister,
      child: builder(AppForms.get<T>()),
    );
  }
}
