import 'dart:developer';

import 'package:app_forms/app_forms.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/foundation.dart';

/// Advanced ProfileSettingsForm demonstrating dynamic form management.
/// 
/// This form showcases:
/// - Dynamic field generation based on user preferences
/// - Real-time theme switching
/// - Notification preference management
/// - Data export/import capabilities
/// - Advanced validation with conditional requirements
/// - Memory-efficient caching
class ProfileSettingsForm extends AppForm {
  @override
  bool get autoValidate => true; // Enable smart caching

  /// Display name with dynamic validation
  final displayName = AppFormField<String>(
    name: 'displayName',
    initialValue: kDebugMode ? 'John Doe' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Display name is required',
      ),
      FormBuilderValidators.minLength(
        2,
        errorText: 'Display name must be at least 2 characters',
      ),
      FormBuilderValidators.maxLength(
        50,
        errorText: 'Display name cannot exceed 50 characters',
      ),
    ]),
    onChange: (field) {
      if (kDebugMode) {
        log('Display name changed: ${field?.value}');
      }
    },
  );

  /// Bio field with character counter
  final bio = AppFormField<String>(
    name: 'bio',
    initialValue: kDebugMode ? 'Flutter developer passionate about clean architecture and performance optimization.' : '',
    validations: FormBuilderValidators.maxLength(
      200,
      errorText: 'Bio cannot exceed 200 characters',
    ),
    onChange: (field) {
      if (kDebugMode) {
        log('Bio updated (${field?.value?.length ?? 0}/200 characters)');
      }
    },
  );

  /// Phone number with conditional validation
  final phoneNumber = AppFormField<String>(
    name: 'phoneNumber',
    initialValue: kDebugMode ? '+1-555-0123' : '',
    validations: (value) {
      if (value == null || value.isEmpty) {
        // Phone is optional, but if provided must be valid
        return null;
      }
      
      // Remove formatting for validation
      final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
      
      if (cleanPhone.length < 10) {
        return 'Phone number must be at least 10 digits';
      }
      
      if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
      
      return null;
    },
  );

  /// Theme preference
  final themeMode = AppFormField<String>(
    name: 'themeMode',
    initialValue: 'system',
    validations: FormBuilderValidators.required(
      errorText: 'Please select a theme preference',
    ),
    onChange: (field) {
      if (kDebugMode) {
        log('Theme changed to: ${field?.value}');
      }
      // Theme change will be handled in onInit or separately
    },
  );

  /// Language preference
  final language = AppFormField<String>(
    name: 'language',
    initialValue: 'en',
    validations: FormBuilderValidators.required(
      errorText: 'Please select a language',
    ),
  );

  /// Time zone
  final timeZone = AppFormField<String>(
    name: 'timeZone',
    initialValue: kDebugMode ? 'America/New_York' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your time zone',
    ),
  );

  /// Email notifications
  final emailNotifications = AppFormField<bool>(
    name: 'emailNotifications',
    initialValue: true,
    onChange: (field) {
      if (kDebugMode) {
        log('Email notifications: ${field?.value}');
      }
    },
  );

  /// Push notifications
  final pushNotifications = AppFormField<bool>(
    name: 'pushNotifications',
    initialValue: true,
    onChange: (field) {
      if (kDebugMode) {
        log('Push notifications: ${field?.value}');
      }
    },
  );

  /// Marketing emails (conditional on email notifications)
  final marketingEmails = AppFormField<bool>(
    name: 'marketingEmails',
    initialValue: false,
    onChange: (field) {
      if (kDebugMode) {
        log('Marketing emails: ${field?.value}');
      }
    },
  );

  /// Weekly digest emails
  final weeklyDigest = AppFormField<bool>(
    name: 'weeklyDigest',
    initialValue: true,
  );

  /// Privacy level
  final privacyLevel = AppFormField<String>(
    name: 'privacyLevel',
    initialValue: 'friends',
    validations: FormBuilderValidators.required(
      errorText: 'Please select a privacy level',
    ),
  );

  /// Profile visibility
  final profileVisibility = AppFormField<String>(
    name: 'profileVisibility',
    initialValue: 'public',
    validations: FormBuilderValidators.required(
      errorText: 'Please select profile visibility',
    ),
  );

  /// Auto-save preferences
  final autoSave = AppFormField<bool>(
    name: 'autoSave',
    initialValue: true,
    onChange: (field) {
      if (kDebugMode) {
        log('Auto-save setting changed: ${field?.value}');
      }
      // Auto-save will be handled separately
    },
  );

  /// Data export format preference
  final exportFormat = AppFormField<String>(
    name: 'exportFormat',
    initialValue: 'json',
  );

  /// Two-factor authentication
  final twoFactorEnabled = AppFormField<bool>(
    name: 'twoFactorEnabled',
    initialValue: false,
    onChange: (field) {
      if (kDebugMode) {
        log('Two-factor authentication: ${field?.value}');
      }
      // Two-factor setup will be handled separately
    },
  );

  /// Session timeout (in minutes)
  final sessionTimeout = AppFormField<int>(
    name: 'sessionTimeout',
    initialValue: 30,
    validations: (value) {
      if (value == null || value.isEmpty) return 'Session timeout is required';
      final intValue = int.tryParse(value);
      if (intValue == null) return 'Please enter a valid number';
      if (intValue < 5) return 'Minimum session timeout is 5 minutes';
      if (intValue > 480) return 'Maximum session timeout is 8 hours';
      return null;
    },
  );

  /// Advanced feature toggles (dynamic fields)
  final Map<String, AppFormField<bool>> _dynamicFeatures = {};

  /// Settings update tracking
  DateTime? _lastSaved;
  bool _hasUnsavedChanges = false;
  int _saveCount = 0;

  ProfileSettingsForm() {
    // Initialize dynamic feature toggles
    _initializeDynamicFeatures();
    
    // Register all standard fields
    setFields([
      displayName,
      bio,
      phoneNumber,
      themeMode,
      language,
      timeZone,
      emailNotifications,
      pushNotifications,
      marketingEmails,
      weeklyDigest,
      privacyLevel,
      profileVisibility,
      autoSave,
      exportFormat,
      twoFactorEnabled,
      sessionTimeout,
      // Add dynamic features
      ..._dynamicFeatures.values,
    ]);

    if (kDebugMode) {
      log('ProfileSettingsForm initialized with fields including ${_dynamicFeatures.length} dynamic features');
    }
  }

  /// Initializes dynamic feature toggle fields
  void _initializeDynamicFeatures() {
    final features = [
      'darkModeSchedule',
      'advancedSearch',
      'betaFeatures',
      'analyticsTracking',
      'locationServices',
      'voiceCommands',
    ];

    for (final feature in features) {
      _dynamicFeatures[feature] = AppFormField<bool>(
        name: feature,
        initialValue: false,
        onChange: (field) {
          if (kDebugMode) {
            log('Dynamic feature $feature: ${field?.value}');
          }
          _hasUnsavedChanges = true;
        },
      );
    }
  }

  @override
  Future<void> onInit() async {
    if (kDebugMode) {
      log('ProfileSettingsForm initializing...');
    }

    // Simulate loading user preferences from storage
    await _loadUserPreferences();

    // Setup auto-save monitoring
    _setupAutoSave();

    if (kDebugMode) {
      log('ProfileSettingsForm initialization complete');
      _logPerformanceMetrics();
    }
  }

  /// Loads user preferences from storage
  Future<void> _loadUserPreferences() async {
    try {
      // Simulate API call to load preferences
      await Future.delayed(const Duration(milliseconds: 200));

      if (kDebugMode) {
        // Load demo preferences
        themeMode.setValue('dark');
        language.setValue('en');
        timeZone.setValue('America/New_York');
        privacyLevel.setValue('private');
        profileVisibility.setValue('friends');
        sessionTimeout.setValue(60);
        
        // Load dynamic features
        _dynamicFeatures['betaFeatures']?.setValue(true);
        _dynamicFeatures['advancedSearch']?.setValue(true);
        
        updateFieldsValue();
        
        log('Demo preferences loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error loading preferences: $e');
      }
    }
  }

  /// Sets up auto-save functionality
  void _setupAutoSave() {
    // In a real app, you'd use a timer or stream subscription
    if (kDebugMode) {
      log('Auto-save monitoring enabled');
    }
  }

  /// Performs auto-save if enabled
  void _performAutoSave() {
    if (autoSave.value == true && _hasUnsavedChanges) {
      if (kDebugMode) {
        log('Performing auto-save...');
      }
      _saveSettings(showNotification: false);
    }
  }

  /// Simulates theme change notification
  void _notifyThemeChange(String? newTheme) {
    if (newTheme != null) {
      // In a real app, this would update the app's theme
      if (kDebugMode) {
        log('Theme change notification: $newTheme');
      }
    }
  }

  /// Simulates two-factor authentication setup
  void _simulateTwoFactorSetup() {
    if (kDebugMode) {
      log('Initiating two-factor authentication setup...');
    }
    // In a real app, this would navigate to 2FA setup flow
  }

  /// Gets all dynamic feature values
  Map<String, bool> getDynamicFeatureStates() {
    return _dynamicFeatures.map((key, field) => MapEntry(key, field.value ?? false));
  }

  /// Updates a dynamic feature
  void updateDynamicFeature(String featureName, bool enabled) {
    final field = _dynamicFeatures[featureName];
    if (field != null) {
      field.setValue(enabled);
      updateFieldsValue();
      _hasUnsavedChanges = true;
      
      if (kDebugMode) {
        log('Dynamic feature $featureName updated: $enabled');
      }
    }
  }

  /// Gets form completion percentage
  double getCompletionPercentage() {
    final values = getValues();
    if (values == null) return 0.0;

    final requiredFields = [
      displayName.name,
      themeMode.name,
      language.name,
      timeZone.name,
      privacyLevel.name,
      profileVisibility.name,
    ];

    final completedFields = requiredFields.where((fieldName) {
      final value = values[fieldName];
      return value != null && value.toString().isNotEmpty;
    }).length;

    return completedFields / requiredFields.length;
  }

  /// Exports user settings
  Map<String, dynamic> exportSettings() {
    final values = getValues() ?? {};
    final export = {
      'settings': values,
      'dynamicFeatures': getDynamicFeatureStates(),
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
        'saveCount': _saveCount,
      },
    };

    if (kDebugMode) {
      log('Settings exported: ${export.keys}');
    }

    return export;
  }

  /// Imports user settings
  Future<bool> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final settings = settingsData['settings'] as Map<String, dynamic>?;
      final features = settingsData['dynamicFeatures'] as Map<String, dynamic>?;

      if (settings != null) {
        // Update standard fields using known field mapping
        final fieldMap = _getFieldMap();
        settings.forEach((key, value) {
          final field = fieldMap[key];
          if (field != null) {
            field.setValue(value);
          }
        });

        // Update dynamic features
        if (features != null) {
          features.forEach((key, value) {
            updateDynamicFeature(key, value as bool);
          });
        }

        updateFieldsValue();
        
        if (kDebugMode) {
          log('Settings imported successfully');
        }
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error importing settings: $e');
      }
    }
    
    return false;
  }

  @override
  Future<void> onSubmit(Map<String, dynamic>? values) async {
    if (values == null) {
      setHasErrors(true);
      return;
    }

    await _saveSettings();
  }

  /// Saves settings with validation
  Future<void> _saveSettings({bool showNotification = true}) async {
    try {
      if (kDebugMode) {
        log('Saving profile settings...');
        _logPerformanceMetrics();
      }

      // Validate conditional requirements
      if (!_validateConditionalFields()) {
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _saveCount++;
      _lastSaved = DateTime.now();
      _hasUnsavedChanges = false;

      // Success
      setSuccess(true);

      if (kDebugMode) {
        log('Profile settings saved successfully (save #$_saveCount)');
      }

    } catch (e) {
      setHasErrors(true);
      setValidationErrors({
        'general': 'Failed to save settings. Please try again.'
      });

      if (kDebugMode) {
        log('Save failed: $e');
      }
    }
  }

  /// Validates conditional field requirements
  bool _validateConditionalFields() {
    final errors = <String, String>{};

    // Marketing emails only valid if email notifications enabled
    if (marketingEmails.value == true && emailNotifications.value != true) {
      errors['marketingEmails'] = 'Email notifications must be enabled to receive marketing emails';
    }

    // Weekly digest only valid if email notifications enabled
    if (weeklyDigest.value == true && emailNotifications.value != true) {
      errors['weeklyDigest'] = 'Email notifications must be enabled to receive weekly digest';
    }

    if (errors.isNotEmpty) {
      setValidationErrors(errors);
      return false;
    }

    return true;
  }

  @override
  void onReset() {
    clearValidationCache();
    _hasUnsavedChanges = false;
    _saveCount = 0;
    _lastSaved = null;

    // Reset dynamic features
    _dynamicFeatures.values.forEach((field) {
      field.setValue(false);
    });

    if (kDebugMode) {
      log('Profile settings form reset');
    }
  }

  @override
  Future<void> onValid(Map<String, dynamic>? values) async {
    if (kDebugMode) {
      log('Profile settings form is valid');
    }
  }

  /// Gets save status information
  Map<String, dynamic> getSaveStatus() {
    return {
      'hasUnsavedChanges': _hasUnsavedChanges,
      'lastSaved': _lastSaved?.toIso8601String(),
      'saveCount': _saveCount,
      'autoSaveEnabled': autoSave.value ?? false,
    };
  }

  /// Gets a map of field names to field instances for import functionality
  Map<String, AppFormField> _getFieldMap() {
    return {
      displayName.name: displayName,
      bio.name: bio,
      phoneNumber.name: phoneNumber,
      themeMode.name: themeMode,
      language.name: language,
      timeZone.name: timeZone,
      emailNotifications.name: emailNotifications,
      pushNotifications.name: pushNotifications,
      marketingEmails.name: marketingEmails,
      weeklyDigest.name: weeklyDigest,
      privacyLevel.name: privacyLevel,
      profileVisibility.name: profileVisibility,
      autoSave.name: autoSave,
      exportFormat.name: exportFormat,
      twoFactorEnabled.name: twoFactorEnabled,
      sessionTimeout.name: sessionTimeout,
    };
  }

  /// Logs performance metrics for debugging
  void _logPerformanceMetrics() {
    if (!kDebugMode) return;

    final metrics = getPerformanceMetrics();
    log('=== Profile Settings Performance ===');
    metrics.forEach((key, value) {
      log('$key: $value');
    });
    log('Form completion: ${(getCompletionPercentage() * 100).toInt()}%');
    log('Dynamic features: ${_dynamicFeatures.length}');
    log('Save status: ${getSaveStatus()}');
    log('===================================');
  }
}