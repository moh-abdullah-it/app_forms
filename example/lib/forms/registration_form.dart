import 'dart:developer';

import 'package:app_forms/app_forms.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/foundation.dart';

/// Advanced RegistrationForm demonstrating complex validation patterns.
/// 
/// This form showcases:
/// - Multi-field validation dependencies
/// - Async validation (username availability)
/// - File upload simulation
/// - Terms and conditions handling
/// - Advanced password confirmation
/// - Real-time validation feedback
class RegistrationForm extends AppForm {
  @override
  bool get autoValidate => true; // Enable smart caching
  
  /// First name field with real-time validation
  final firstName = AppFormField<String>(
    name: 'firstName',
    initialValue: kDebugMode ? 'John' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'First name is required',
      ),
      FormBuilderValidators.minLength(
        2,
        errorText: 'First name must be at least 2 characters',
      ),
      FormBuilderValidators.maxLength(
        50,
        errorText: 'First name cannot exceed 50 characters',
      ),
      // Custom validation for names
      (value) {
        if (value != null && value.contains(RegExp(r'[0-9]'))) {
          return 'First name cannot contain numbers';
        }
        return null;
      },
    ]),
    onChange: (field) {
      if (kDebugMode) {
        log('First name changed: ${field?.value}');
      }
    },
  );
  
  /// Last name field with similar validation
  final lastName = AppFormField<String>(
    name: 'lastName',
    initialValue: kDebugMode ? 'Doe' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Last name is required',
      ),
      FormBuilderValidators.minLength(
        2,
        errorText: 'Last name must be at least 2 characters',
      ),
      FormBuilderValidators.maxLength(
        50,
        errorText: 'Last name cannot exceed 50 characters',
      ),
      (value) {
        if (value != null && value.contains(RegExp(r'[0-9]'))) {
          return 'Last name cannot contain numbers';
        }
        return null;
      },
    ]),
  );
  
  /// Username field with async availability checking
  final username = AppFormField<String>(
    name: 'username',
    initialValue: kDebugMode ? 'johndoe123' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Username is required',
      ),
      FormBuilderValidators.minLength(
        3,
        errorText: 'Username must be at least 3 characters',
      ),
      FormBuilderValidators.maxLength(
        20,
        errorText: 'Username cannot exceed 20 characters',
      ),
      // Async validation simulation (cached for performance)
      (value) {
        if (value == null || value.isEmpty) return null;
        
        // Simulate expensive username check
        if (value.toLowerCase() == 'admin' || 
            value.toLowerCase() == 'root' ||
            value.toLowerCase() == 'test') {
          return 'Username not available';
        }
        
        // Check format
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return 'Username can only contain letters, numbers, and underscores';
        }
        
        return null;
      },
    ]),
    onChange: (field) {
      if (kDebugMode) {
        log('Username availability check: ${field?.value}');
      }
    },
  );
  
  /// Email field with advanced validation
  final email = AppFormField<String>(
    name: 'email',
    initialValue: kDebugMode ? 'john.doe@example.com' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Email is required',
      ),
      FormBuilderValidators.email(
        errorText: 'Please enter a valid email address',
      ),
      // Custom domain validation
      (value) {
        if (value != null && value.isNotEmpty) {
          final blockedDomains = ['tempmail.com', 'throwaway.email', 'mailinator.com'];
          final domain = value.split('@').last.toLowerCase();
          
          if (blockedDomains.contains(domain)) {
            return 'Temporary email addresses are not allowed';
          }
        }
        return null;
      },
    ]),
  );
  
  /// Password field with strength requirements
  final password = AppFormField<String>(
    name: 'password',
    initialValue: kDebugMode ? 'SecurePass123!' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Password is required',
      ),
      FormBuilderValidators.minLength(
        8,
        errorText: 'Password must be at least 8 characters',
      ),
      // Advanced password strength validation
      (value) {
        if (value == null || value.isEmpty) return null;
        
        final hasLowercase = value.contains(RegExp(r'[a-z]'));
        final hasUppercase = value.contains(RegExp(r'[A-Z]'));
        final hasNumbers = value.contains(RegExp(r'[0-9]'));
        final hasSpecialChars = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
        
        if (!hasLowercase) {
          return 'Password must contain at least one lowercase letter';
        }
        if (!hasUppercase) {
          return 'Password must contain at least one uppercase letter';
        }
        if (!hasNumbers) {
          return 'Password must contain at least one number';
        }
        if (!hasSpecialChars) {
          return 'Password must contain at least one special character';
        }
        
        // Check for common weak passwords
        final weakPasswords = ['password123', '12345678', 'qwerty123'];
        if (weakPasswords.contains(value.toLowerCase())) {
          return 'This password is too common';
        }
        
        return null;
      },
    ]),
    onChange: (field) {
      if (kDebugMode) {
        log('Password changed (length: ${field?.value?.length ?? 0})');
      }
    },
  );
  
  /// Password confirmation field
  final confirmPassword = AppFormField<String>(
    name: 'confirmPassword',
    initialValue: kDebugMode ? 'SecurePass123!' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Please confirm your password',
      ),
      // This will be validated against password field dynamically
    ]),
  );
  
  /// Date of birth field
  final dateOfBirth = AppFormField<DateTime>(
    name: 'dateOfBirth',
    initialValue: kDebugMode ? DateTime(1990, 1, 1) : null,
    validations: (value) {
      if (value == null) {
        return 'Date of birth is required';
      }
      
      final now = DateTime.now();
      final date = DateTime.parse(value);
      final age = now.year - date.year;
      
      if (age < 13) {
        return 'You must be at least 13 years old';
      }
      
      if (age > 120) {
        return 'Please enter a valid date of birth';
      }
      
      return null;
    },
  );
  
  /// Gender selection
  final gender = AppFormField<String>(
    name: 'gender',
    initialValue: kDebugMode ? 'prefer_not_to_say' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your gender',
    ),
  );
  
  /// Country selection
  final country = AppFormField<String>(
    name: 'country',
    initialValue: kDebugMode ? 'US' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your country',
    ),
  );
  
  /// Terms and conditions acceptance
  final acceptTerms = AppFormField<bool>(
    name: 'acceptTerms',
    initialValue: false,
    validations: (value) {
      if (value != true) {
        return 'You must accept the terms and conditions';
      }
      return null;
    },
  );
  
  /// Newsletter subscription (optional)
  final subscribeNewsletter = AppFormField<bool>(
    name: 'subscribeNewsletter',
    initialValue: true,
  );
  
  /// Profile picture (simulated file upload)
  final profilePicture = AppFormField<String>(
    name: 'profilePicture',
    initialValue: null,
    // Optional field - no validation required
  );
  
  /// Registration attempt tracking
  int _registrationAttempts = 0;
  DateTime? _lastAttempt;
  
  /// Password strength cache
  String _lastPasswordStrength = '';
  
  /// Total field count for debugging
  static const int totalFields = 12;
  
  RegistrationForm() {
    // Register all fields with performance optimization
    setFields([
      firstName,
      lastName,
      username,
      email,
      password,
      confirmPassword,
      dateOfBirth,
      gender,
      country,
      acceptTerms,
      subscribeNewsletter,
      profilePicture,
    ]);
    
    if (kDebugMode) {
      log('RegistrationForm initialized with $totalFields fields');
    }
  }
  
  @override
  Future<void> onInit() async {
    if (kDebugMode) {
      log('RegistrationForm initializing...');
    }
    
    // Simulate loading country data or user preferences
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (kDebugMode) {
      log('RegistrationForm initialization complete');
      _logPerformanceMetrics();
    }
  }
  
  @override
  Future<void> onSubmit(Map<String, dynamic>? values) async {
    if (values == null) {
      setHasErrors(true);
      return;
    }
    
    // Validate password confirmation manually (field dependency)
    if (!_validatePasswordConfirmation()) {
      return;
    }
    
    // Check rate limiting
    if (_isRateLimited()) {
      setValidationErrors({
        'general': 'Too many registration attempts. Please wait before trying again.'
      });
      return;
    }
    
    _registrationAttempts++;
    _lastAttempt = DateTime.now();
    
    try {
      if (kDebugMode) {
        log('Submitting registration form (attempt $_registrationAttempts)');
        log('Registration values: $values');
        _logPerformanceMetrics();
      }
      
      // Simulate registration API call
      await _performRegistration(values);
      
      // Success
      setSuccess(true);
      _registrationAttempts = 0; // Reset on success
      
      if (kDebugMode) {
        log('Registration successful!');
      }
      
    } catch (e) {
      setHasErrors(true);
      
      // Handle different types of errors
      if (e is ValidationException) {
        setValidationErrors(e.fieldErrors);
      } else if (e is NetworkException) {
        setValidationErrors({
          'general': 'Network error. Please check your connection and try again.'
        });
      } else {
        setValidationErrors({
          'general': 'Registration failed. Please try again.'
        });
      }
      
      if (kDebugMode) {
        log('Registration failed: $e');
      }
    }
  }
  
  /// Validates password confirmation against password field
  bool _validatePasswordConfirmation() {
    final passwordValue = password.value;
    final confirmValue = confirmPassword.value;
    
    if (passwordValue != confirmValue) {
      setValidationErrors({
        'confirmPassword': 'Passwords do not match'
      });
      return false;
    }
    
    return true;
  }
  
  /// Simulates registration API call
  Future<void> _performRegistration(Map<String, dynamic> values) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    
    final email = values['email'] as String?;
    final username = values['username'] as String?;
    
    // Simulate various error scenarios for demo
    if (email?.contains('error') == true) {
      throw NetworkException('Simulated network error');
    }
    
    if (username?.toLowerCase() == 'taken') {
      throw ValidationException({
        'username': 'Username is already taken'
      });
    }
    
    if (email?.contains('exists') == true) {
      throw ValidationException({
        'email': 'An account with this email already exists'
      });
    }
    
    // Success case
    return;
  }
  
  /// Checks if user is rate limited
  bool _isRateLimited() {
    if (_registrationAttempts < 3) return false;
    
    final now = DateTime.now();
    final lastAttempt = _lastAttempt;
    
    if (lastAttempt == null) return false;
    
    // Rate limit for 5 minutes after 3 failed attempts
    return now.difference(lastAttempt).inMinutes < 5;
  }
  
  /// Gets password strength as string
  String _getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) {
      return 'No password';
    }
    
    int score = 0;
    
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    switch (score) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
  
  /// Gets password strength score (0-100)
  int getPasswordStrengthScore() {
    final password = this.password.value;
    if (password == null || password.isEmpty) return 0;
    
    int score = 0;
    
    if (password.length >= 8) score += 20;
    if (password.contains(RegExp(r'[a-z]'))) score += 20;
    if (password.contains(RegExp(r'[A-Z]'))) score += 20;
    if (password.contains(RegExp(r'[0-9]'))) score += 20;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 20;
    
    return score;
  }
  
  /// Gets form completion percentage including optional fields
  double getDetailedCompletionPercentage() {
    final values = getValues();
    if (values == null) return 0.0;
    
    final requiredFields = [
      firstName.name,
      lastName.name,
      username.name,
      email.name,
      password.name,
      confirmPassword.name,
      dateOfBirth.name,
      gender.name,
      country.name,
      acceptTerms.name,
    ];
    
    final optionalFields = [
      subscribeNewsletter.name,
      profilePicture.name,
    ];
    
    final completedRequired = requiredFields.where((fieldName) {
      final value = values[fieldName];
      return value != null && 
             (value is! String || value.isNotEmpty) &&
             (value is! bool || value == true || fieldName != acceptTerms.name);
    }).length;
    
    final completedOptional = optionalFields.where((fieldName) {
      final value = values[fieldName];
      return value != null && (value is! String || value.isNotEmpty);
    }).length;
    
    // Weight required fields more heavily
    final requiredWeight = 0.8;
    final optionalWeight = 0.2;
    
    final requiredScore = (completedRequired / requiredFields.length) * requiredWeight;
    final optionalScore = (completedOptional / optionalFields.length) * optionalWeight;
    
    return requiredScore + optionalScore;
  }
  
  @override
  void onReset() {
    clearValidationCache(); // Clean up cache for memory efficiency
    _registrationAttempts = 0;
    _lastAttempt = null;
    _lastPasswordStrength = '';
    
    if (kDebugMode) {
      log('Registration form reset completed');
    }
  }
  
  @override
  Future<void> onValid(Map<String, dynamic>? values) async {
    if (kDebugMode) {
      log('Registration form is valid - enabling submit button');
    }
  }
  
  /// Logs performance metrics for debugging
  void _logPerformanceMetrics() {
    if (!kDebugMode) return;
    
    final metrics = getPerformanceMetrics();
    log('=== Registration Form Performance ===');
    metrics.forEach((key, value) {
      log('$key: $value');
    });
    log('Detailed completion: ${(getDetailedCompletionPercentage() * 100).toInt()}%');
    log('Password strength: ${_getPasswordStrength(password.value)}');
    log('=====================================');
  }
}

/// Custom exception for validation errors with field mapping
class ValidationException implements Exception {
  final Map<String, String> fieldErrors;
  ValidationException(this.fieldErrors);
  
  @override
  String toString() => 'ValidationException: $fieldErrors';
}

/// Network exception for connection issues
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}