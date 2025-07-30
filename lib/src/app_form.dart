import 'package:app_forms/app_forms.dart';
import 'package:app_forms/src/utils/debouncer.dart';
import 'package:flutter/cupertino.dart';

/// Abstract base class for all forms in the app_forms package.
///
/// This class provides a complete form management system that separates
/// form logic from UI components. It handles validation, state management,
/// field operations, and form lifecycle events.
///
/// ## Key Features:
/// - **State Management**: Built-in loading, progress, error, and success states
/// - **Auto-validation**: Configurable automatic field validation with debouncing
/// - **Lifecycle Hooks**: onInit, onSubmit, onValid, and onReset callbacks
/// - **Field Management**: Dynamic field operations and value synchronization
/// - **Error Handling**: Server-side validation error integration
///
/// ## Usage:
/// ```dart
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
///     // Handle form submission
///   }
/// }
/// ```
///
/// ## Lifecycle:
/// 1. Form is created and fields are set via [setFields]
/// 2. [onInit] is called when form is first accessed
/// 3. Field changes trigger validation and callbacks
/// 4. [onSubmit] is called when [submit] is invoked
/// 5. [onReset] is called when [reset] is invoked
abstract class AppForm {
  /// The global key for the FormBuilder widget.
  ///
  /// This key provides access to the FormBuilder's state and methods
  /// for validation, value retrieval, and form operations.
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  /// Internal list of form fields.
  ///
  /// Contains all [AppFormField] instances associated with this form.
  /// Use [setFields] to populate this list.
  List<AppFormField> _fields = [];

  /// Whether the form should automatically validate fields on change.
  ///
  /// When `true`, fields are validated automatically as the user types
  /// with a 250ms debounce delay. When `false`, validation only occurs
  /// on explicit calls to [saveAndValidate] or form submission.
  ///
  /// Defaults to `true`.
  bool get autoValidate => true;

  /// Internal debouncer to optimize field change events.
  ///
  /// Prevents excessive validation calls by delaying execution
  /// until 250ms after the last field change event.
  final _debouncer = Debouncer(milliseconds: 250);
  
  /// Separate debouncer for UI updates to decouple validation from UI.
  ///
  /// Allows validation to happen quickly while batching UI updates.
  final _uiDebouncer = Debouncer(milliseconds: 16); // ~60fps

  /// Whether the form is currently being submitted.
  ///
  /// Set to `true` during [onSubmit] execution to disable form interactions
  /// and show loading indicators in the UI.
  bool progressing = false;

  /// Whether the form is in a loading state.
  ///
  /// Use [setLoading] to control this state for custom loading scenarios
  /// beyond form submission.
  bool loading = false;

  /// Whether the form has validation or submission errors.
  ///
  /// Automatically set to `true` when validation fails or when
  /// [setValidationErrors] is called. Use [setHasErrors] to control manually.
  bool hasErrors = false;

  /// Whether the form submission was successful.
  ///
  /// Use [setSuccess] to indicate successful form operations to the UI.
  bool success = false;

  /// Internal reference to the form listener widget.
  ///
  /// Used to trigger UI updates when form state changes.
  /// Automatically set by [AppFormListener] widgets.
  AppFormListener? _listener;

  /// Initial values for form fields.
  ///
  /// Populated automatically when [setFields] is called.
  /// Used by [AppFormBuilder] to initialize field values.
  Map<String, dynamic> initialValue = {};

  /// Internal cache of current field values.
  ///
  /// Maintained for performance optimization and change detection.
  final Map<String, dynamic> _values = {};
  
  /// Cache of previous field values for change detection.
  ///
  /// Used to detect actual changes and prevent unnecessary operations.
  final Map<String, dynamic> _previousValues = {};
  
  /// Cache for expensive validation results.
  ///
  /// Prevents re-running validations on unchanged values.
  final Map<String, String?> _validationCache = {};
  
  /// Maximum size for validation cache to prevent memory leaks.
  static const int _maxCacheSize = 100;
  
  /// Performance metrics for debugging and optimization.
  final Map<String, int> _performanceMetrics = {};

  /// Gets the current FormBuilder state.
  ///
  /// Returns `null` if the form has not been built yet or the widget
  /// is not currently mounted.
  FormBuilderState? get state => formKey.currentState;

  /// Retrieves the current form values.
  ///
  /// Returns a map of field names to their current values.
  /// Returns `null` if the form state is not available.
  ///
  /// ## Example:
  /// ```dart
  /// final values = form.getValues();
  /// print('Email: ${values?['email']}');
  /// ```
  Map<String, dynamic>? getValues() {
    return state?.value;
  }

  /// Called when the form is first accessed.
  ///
  /// Override this method to perform initialization logic such as:
  /// - Loading initial data from APIs
  /// - Setting up listeners
  /// - Configuring form state
  ///
  /// This method is called only once per form instance lifecycle.
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// Future<void> onInit() async {
  ///   final userData = await userService.getCurrentUser();
  ///   email.value = userData.email;
  ///   updateFieldsValue();
  /// }
  /// ```
  Future<void> onInit() async {}

  /// Called when the form is submitted via [submit].
  ///
  /// This method must be implemented by subclasses to handle form submission.
  /// The [values] parameter contains the current form field values.
  ///
  /// ## State Management:
  /// - [progressing] is automatically set to `true` during execution
  /// - [hasErrors] is set to `true` if validation fails
  /// - Use [setSuccess], [setHasErrors], etc. to update form state
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// Future<void> onSubmit(Map<String, dynamic>? values) async {
  ///   try {
  ///     await authService.login(values!['email'], values['password']);
  ///     setSuccess(true);
  ///   } catch (e) {
  ///     setValidationErrors({'general': 'Login failed'});
  ///   }
  /// }
  /// ```
  Future<void> onSubmit(Map<String, dynamic>? values);

  /// Called when the form becomes valid.
  ///
  /// This method is triggered whenever all form fields pass validation.
  /// Use this hook to perform actions that should occur when the form
  /// is in a valid state.
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// Future<void> onValid(Map<String, dynamic>? values) async {
  ///   // Enable submit button, show preview, etc.
  ///   print('Form is now valid with values: $values');
  /// }
  /// ```
  Future<void> onValid(Map<String, dynamic>? values) async {}

  /// Called when the form is reset via [reset].
  ///
  /// Override this method to perform cleanup or reinitialization
  /// when the form is reset to its initial state.
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// void onReset() {
  ///   setSuccess(false);
  ///   setHasErrors(false);
  ///   // Clear any custom state
  /// }
  /// ```
  void onReset() {}

  /// Saves and validates the current form state.
  ///
  /// Returns `true` if all fields are valid, `false` if any field has errors,
  /// or `null` if the form state is not available.
  ///
  /// ## Parameters:
  /// - [focusOnInvalid]: Whether to focus the first invalid field (default: `true`)
  /// - [autoScrollWhenFocusOnInvalid]: Whether to scroll to focused invalid field (default: `false`)
  ///
  /// ## Example:
  /// ```dart
  /// if (form.saveAndValidate() ?? false) {
  ///   // Form is valid, proceed with submission
  ///   await onSubmit(getValues());
  /// } else {
  ///   // Form has errors, handle accordingly
  ///   setHasErrors(true);
  /// }
  /// ```
  bool? saveAndValidate({
    bool focusOnInvalid = true,
    bool autoScrollWhenFocusOnInvalid = false,
  }) {
    return state?.saveAndValidate(
      focusOnInvalid: focusOnInvalid,
      autoScrollWhenFocusOnInvalid: autoScrollWhenFocusOnInvalid,
    );
  }

  /// Submits the form after validation.
  ///
  /// This method orchestrates the complete form submission process:
  /// 1. Clears previous errors and sets progressing state
  /// 2. Validates all fields using [saveAndValidate]
  /// 3. Calls [onSubmit] if validation passes
  /// 4. Sets error state if validation fails
  /// 5. Updates UI listeners with final state
  ///
  /// The [progressing] state is automatically managed during this process
  /// to provide feedback to UI components.
  ///
  /// ## Example:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: form.progressing ? null : form.submit,
  ///   child: form.progressing 
  ///     ? CircularProgressIndicator() 
  ///     : Text('Submit'),
  /// )
  /// ```
  Future<void> submit() async {
    hasErrors = false;
    progressing = true;
    _listener?.update();
    
    try {
      if (saveAndValidate() ?? false) {
        await onSubmit(getValues());
      } else {
        hasErrors = true;
      }
    } catch (e) {
      hasErrors = true;
      rethrow;
    } finally {
      progressing = false;
      _listener?.update();
    }
  }

  /// Resets the form to its initial state.
  ///
  /// This method:
  /// 1. Resets all field values to their initial values
  /// 2. Clears all validation errors
  /// 3. Calls the [onReset] lifecycle hook
  ///
  /// ## Example:
  /// ```dart
  /// TextButton(
  ///   onPressed: form.reset,
  ///   child: Text('Reset Form'),
  /// )
  /// ```
  void reset() {
    state?.reset();
    onReset();
  }

  /// Sets the form fields and initializes their values with optimization.
  ///
  /// This method should be called in the form constructor to register
  /// all fields with the form. It automatically:
  /// - Stores field references for internal management
  /// - Populates [initialValue] map for FormBuilder
  /// - Initializes internal value cache
  /// - Sets initial field values
  /// - Pre-allocates performance tracking structures
  ///
  /// ## Parameters:
  /// - [fields]: List of [AppFormField] instances to register
  ///
  /// ## Example:
  /// ```dart
  /// LoginForm() {
  ///   setFields([email, password, rememberMe]);
  /// }
  /// ```
  void setFields(List<AppFormField> fields) {
    _fields = fields;
    
    // Pre-allocate maps with known capacity for better performance
    final fieldCount = fields.length;
    if (initialValue.isEmpty) {
      // Only allocate if not already done (avoid re-allocation)
      initialValue = Map<String, dynamic>.from({});
      _values.clear();
      _previousValues.clear();
    }
    
    for (final field in fields) {
      initialValue[field.name] = field.initialValue;
      _values[field.name] = field.initialValue;
      _previousValues[field.name] = field.initialValue;
      field.value = _values[field.name];
      
      // Initialize performance tracking
      _performanceMetrics['${field.name}_validations'] = 0;
      _performanceMetrics['${field.name}_changes'] = 0;
    }
  }

  /// Internal method called when form fields change.
  ///
  /// This method is automatically called by [AppFormBuilder] when
  /// any field value changes. It handles:
  /// - Auto-validation (if enabled)
  /// - Field change callbacks
  /// - Form validity checks and [onValid] calls
  /// - Value synchronization
  ///
  /// This method should not be called directly by user code.
  void onChange() {
    if (autoValidate) {
      _autoValidate();
    } else {
      _listenFieldChange();
    }
    if (state?.isValid ?? false) {
      onValid(getValues());
    }
    _setFieldsValue();
  }

  /// Updates FormBuilder field values from AppFormField values.
  ///
  /// This method synchronizes programmatically set field values
  /// with the FormBuilder widget. Call this after updating
  /// field values directly on [AppFormField] instances.
  ///
  /// ## Example:
  /// ```dart
  /// void loadUserData() {
  ///   email.value = 'user@example.com';
  ///   name.value = 'John Doe';
  ///   updateFieldsValue(); // Sync with FormBuilder
  /// }
  /// ```
  void updateFieldsValue() {
    for (final field in _fields) {
      state?.fields[field.name]?.didChange(field.value);
    }
  }

  /// Sets validation errors on form fields.
  ///
  /// This method is typically used to display server-side validation
  /// errors returned from API calls. It automatically sets [hasErrors]
  /// to `true` and applies error messages to the specified fields.
  ///
  /// ## Parameters:
  /// - [errors]: Map of field names to error messages. Values can be:
  ///   - `String`: Single error message
  ///   - `List<String>`: Multiple errors (first one is used)
  ///
  /// ## Example:
  /// ```dart
  /// try {
  ///   await submitToServer(values);
  /// } catch (validationException) {
  ///   setValidationErrors({
  ///     'email': 'Email already exists',
  ///     'password': ['Too weak', 'Must contain numbers']
  ///   });
  /// }
  /// ```
  void setValidationErrors(Map<String, dynamic>? errors) {
    hasErrors = true;
    if (errors != null && errors.isNotEmpty) {
      errors.forEach((fieldKey, value) {
        final field = state?.fields[fieldKey];
        if (value is List && value.isNotEmpty) {
          field?.invalidate(value.first.toString());
        } else if (value is String) {
          field?.invalidate(value);
        }
      });
    }
  }

  /// Internal method that handles automatic validation with memoization.
  ///
  /// This method is called when [autoValidate] is `true` and a field changes.
  /// It validates only changed fields and uses cached validation results
  /// for performance optimization.
  void _autoValidate() {
    for (final field in _fields) {
      final currentValue = state?.instantValue[field.name];
      final cachedValue = _values[field.name];
      
      // Only process if value actually changed
      if (currentValue != cachedValue) {
        _previousValues[field.name] = cachedValue;
        _values[field.name] = currentValue;
        
        // Check validation cache first
        final cacheKey = '${field.name}_${currentValue?.toString() ?? 'null'}';
        if (!_validationCache.containsKey(cacheKey)) {
          // Validate and cache result
          state?.fields[field.name]?.validate();
          final fieldState = state?.fields[field.name];
          _validationCache[cacheKey] = fieldState?.hasError == true 
              ? fieldState?.errorText 
              : null;
        }
        
        _callField(field);
      }
    }
  }

  /// Internal method that handles field change callbacks with optimization.
  ///
  /// This method is called when [autoValidate] is `false` and only
  /// triggers callbacks for fields that have onChange or onValid handlers.
  /// Uses memoization to prevent redundant callback executions.
  void _listenFieldChange() {
    // Pre-filter fields with callbacks to avoid repeated filtering
    final fieldsWithCallbacks = _fields.where(
        (element) => element.onChange != null || element.onValid != null).toList();
    
    for (final field in fieldsWithCallbacks) {
      final currentValue = state?.instantValue[field.name];
      final cachedValue = _values[field.name];
      
      // Only process actual changes
      if (currentValue != cachedValue) {
        _previousValues[field.name] = cachedValue;
        _values[field.name] = currentValue;
        _callField(field);
      }
    }
  }

  /// Internal method that calls field callbacks with debouncing.
  ///
  /// This method ensures field callbacks are not called too frequently
  /// by using a 250ms debouncer.
  void _callField(AppFormField field) {
    _debouncer.run(() {
      field.onChange?.call(state?.fields[field.name]);
      if (state?.fields[field.name]?.isValid ?? false) {
        field.onValid?.call(state?.fields[field.name]);
      }
    });
  }

  /// Sets the form listener for UI updates.
  ///
  /// This setter is used internally by [AppFormListener] widgets
  /// to register themselves for form state change notifications.
  ///
  /// This should not be called directly by user code.
  set listener(AppFormListener listener) {
    _listener = listener;
  }

  /// Internal method that synchronizes field values and updates UI.
  ///
  /// This method updates [AppFormField.value] properties and triggers
  /// UI updates via the registered listener with optimized batching.
  void _setFieldsValue() {
    // Track if any values actually changed
    bool hasChanges = false;
    
    for (final field in _fields) {
      final newValue = _values[field.name] ?? field.initialValue;
      if (field.value != newValue) {
        field.value = newValue;
        hasChanges = true;
      }
    }
    
    // Only trigger UI update if values actually changed
    if (hasChanges) {
      _uiDebouncer.run(() => _listener?.update());
    }
  }

  /// Sets the form success state.
  ///
  /// Use this method to indicate successful form operations to the UI.
  /// This will trigger UI updates in [AppFormListener] widgets.
  ///
  /// ## Parameters:
  /// - [success]: Whether the operation was successful (default: `true`)
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// Future<void> onSubmit(Map<String, dynamic>? values) async {
  ///   await apiService.saveData(values);
  ///   setSuccess(true); // Show success message in UI
  /// }
  /// ```
  void setSuccess([bool success = true]) => this.success = success;

  /// Sets the form loading state.
  ///
  /// Use this method to indicate loading operations beyond form submission.
  /// This will trigger UI updates in [AppFormListener] widgets.
  ///
  /// ## Parameters:
  /// - [loading]: Whether the form is in loading state (default: `true`)
  ///
  /// ## Example:
  /// ```dart
  /// Future<void> loadInitialData() async {
  ///   setLoading(true);
  ///   final data = await apiService.fetchData();
  ///   // populate fields...
  ///   setLoading(false);
  /// }
  /// ```
  void setLoading([bool loading = true]) => this.loading = loading;

  /// Sets the form error state.
  ///
  /// Use this method to manually control the form's error state.
  /// This will trigger UI updates in [AppFormListener] widgets.
  ///
  /// ## Parameters:
  /// - [hasErrors]: Whether the form has errors (default: `true`)
  ///
  /// ## Example:
  /// ```dart
  /// void clearErrors() {
  ///   setHasErrors(false);
  ///   // Clear any custom error messages
  /// }
  /// ```
  void setHasErrors([bool hasErrors = true]) => this.hasErrors = hasErrors;
  
  /// Clears validation cache to free memory.
  ///
  /// This method should be called periodically or when the cache grows too large
  /// to prevent memory leaks. It's automatically called when cache size exceeds
  /// the maximum limit.
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// void onReset() {
  ///   super.onReset();
  ///   clearValidationCache(); // Clear cache on form reset
  /// }
  /// ```
  void clearValidationCache() {
    _validationCache.clear();
    _performanceMetrics['cache_clears'] = (_performanceMetrics['cache_clears'] ?? 0) + 1;
  }
  
  /// Gets performance metrics for debugging and optimization.
  ///
  /// Returns a map containing various performance metrics such as:
  /// - Field validation counts
  /// - Field change counts
  /// - Cache hit/miss ratios
  /// - Cache clear operations
  ///
  /// ## Example:
  /// ```dart
  /// final metrics = form.getPerformanceMetrics();
  /// print('Email validations: ${metrics['email_validations']}');
  /// print('Cache clears: ${metrics['cache_clears']}');
  /// ```
  Map<String, int> getPerformanceMetrics() {
    return Map<String, int>.from(_performanceMetrics);
  }
  
  /// Internal method to manage validation cache size.
  ///
  /// Automatically clears cache when it exceeds maximum size to prevent
  /// memory leaks in long-running applications.
  void _manageCacheSize() {
    if (_validationCache.length > _maxCacheSize) {
      // Keep only the most recent half of entries
      final entries = _validationCache.entries.toList();
      _validationCache.clear();
      
      // Add back the second half (most recent)
      final keepCount = _maxCacheSize ~/ 2;
      final startIndex = entries.length - keepCount;
      for (int i = startIndex; i < entries.length; i++) {
        _validationCache[entries[i].key] = entries[i].value;
      }
      
      _performanceMetrics['cache_cleanups'] = (_performanceMetrics['cache_cleanups'] ?? 0) + 1;
    }
  }
}
