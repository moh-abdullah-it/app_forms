import 'dart:developer';

import 'package:app_forms/app_forms.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/foundation.dart';

/// Advanced LoginForm demonstrating performance optimizations and best practices.
/// 
/// This form showcases:
/// - Smart validation caching
/// - Performance monitoring
/// - Advanced field management
/// - Error handling patterns
/// - Memory management
class LoginForm extends AppForm {
  @override
  bool get autoValidate => true; // Enable smart caching

  /// Email field with advanced validation and performance monitoring
  final email = AppFormField<String>(
    name: 'email',
    initialValue: kDebugMode ? 'demo@example.com' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Email is required for login',
      ),
      FormBuilderValidators.email(
        errorText: 'Please enter a valid email address',
      ),
      // Custom validation with expensive operation (automatically cached)
      (value) {
        if (value != null && value.contains('spam')) {
          return 'Email domain not allowed';
        }
        return null;
      },
    ]),
    onChange: (field) {
      if (kDebugMode) {
        log('Email changed: ${field?.value} (Valid: ${field?.isValid})');
      }
    },
    onValid: (field) {
      if (kDebugMode) {
        log('Email validated successfully: ${field?.value}');
      }
    },
  );

  /// Password field with strength validation
  final password = AppFormField<String>(
    name: 'password',
    initialValue: kDebugMode ? 'demo123456' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Password is required',
      ),
      FormBuilderValidators.minLength(
        6,
        errorText: 'Password must be at least 6 characters',
      ),
      // Custom strength validation (cached for performance)
      (value) {
        if (value == null || value.isEmpty) return null;
        
        // Simulate expensive password strength check
        final hasLetter = value.contains(RegExp(r'[a-zA-Z]'));
        final hasNumber = value.contains(RegExp(r'[0-9]'));
        
        if (!hasLetter || !hasNumber) {
          return 'Password must contain letters and numbers';
        }
        return null;
      },
    ]),
    onChange: (field) {
      if (kDebugMode) {
        log('Password changed (length: ${field?.value?.length ?? 0})');
      }
    },
    onValid: (field) {
      if (kDebugMode) {
        log('Password meets requirements');
      }
    },
  );

  /// Remember me checkbox for enhanced UX
  final rememberMe = AppFormField<bool>(
    name: 'rememberMe',
    initialValue: false,
    onChange: (field) {
      if (kDebugMode) {
        log('Remember me: ${field?.value}');
      }
    },
  );

  /// Tracks login attempts for security
  int _loginAttempts = 0;
  DateTime? _lastAttempt;
  
  /// Current API loading state
  bool _isAuthenticating = false;

  LoginForm() {
    // Register all fields with performance optimization
    setFields([email, password, rememberMe]);
    
    if (kDebugMode) {
      log('LoginForm initialized with fields');
    }
  }

  @override
  Future<void> onInit() async {
    if (kDebugMode) {
      log('LoginForm initializing...');
    }
    
    // Simulate loading user preferences or saved credentials
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Load saved email if "remember me" was checked previously
    await _loadSavedCredentials();
    
    if (kDebugMode) {
      log('LoginForm initialization complete');
      _logPerformanceMetrics();
    }
  }
  
  /// Loads saved credentials from secure storage (simulated)
  Future<void> _loadSavedCredentials() async {
    try {
      // Simulate loading from secure storage
      await Future.delayed(const Duration(milliseconds: 50));
      
      // In a real app, you'd load from FlutterSecureStorage or similar
      final savedEmail = kDebugMode ? 'saved@example.com' : null;
      
      if (savedEmail != null && savedEmail.isNotEmpty) {
        email.value = savedEmail;
        rememberMe.value = true;
        updateFieldsValue(); // Sync with UI
        
        if (kDebugMode) {
          log('Loaded saved email: $savedEmail');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error loading saved credentials: $e');
      }
    }
  }

  /// Updates email value with validation (demonstrates programmatic field updates)
  void updateEmailValue(String newEmail) {
    email.value = newEmail;
    updateFieldsValue();
    
    if (kDebugMode) {
      log('Email updated programmatically to: $newEmail');
    }
  }
  
  /// Demonstrates advanced field operations
  void clearForm() {
    reset();
    clearValidationCache(); // Free memory
    _loginAttempts = 0;
    _lastAttempt = null;
    
    if (kDebugMode) {
      log('Form cleared and cache cleaned');
    }
  }
  
  /// Gets current form completion percentage
  double getCompletionPercentage() {
    final values = getValues();
    if (values == null) return 0.0;
    
    final requiredFields = [email.name, password.name];
    final completedFields = requiredFields.where((fieldName) {
      final value = values[fieldName];
      return value != null && value.toString().isNotEmpty;
    }).length;
    
    return completedFields / requiredFields.length;
  }

  @override
  Future<void> onSubmit(Map<String, dynamic>? values) async {
    if (values == null) {
      setHasErrors(true);
      return;
    }
    
    // Check rate limiting
    if (_isRateLimited()) {
      setValidationErrors({
        'general': 'Too many login attempts. Please wait before trying again.'
      });
      return;
    }
    
    _isAuthenticating = true;
    _loginAttempts++;
    _lastAttempt = DateTime.now();
    
    try {
      if (kDebugMode) {
        log('Submitting login form (attempt $_loginAttempts)');
        log('Form values: $values');
        _logPerformanceMetrics();
      }
      
      // Simulate API call with realistic timing
      await _performLogin(values);
      
      // Success
      setSuccess(true);
      _loginAttempts = 0; // Reset on success
      
      if (kDebugMode) {
        log('Login successful!');
      }
      
    } catch (e) {
      setHasErrors(true);
      
      // Handle different types of errors
      if (e is AuthenticationException) {
        setValidationErrors({
          'email': 'Invalid email or password',
          'password': 'Invalid email or password',
        });
      } else if (e is NetworkException) {
        setValidationErrors({
          'general': 'Network error. Please check your connection.'
        });
      } else {
        setValidationErrors({
          'general': 'Login failed. Please try again.'
        });
      }
      
      if (kDebugMode) {
        log('Login failed: $e');
      }
    } finally {
      _isAuthenticating = false;
    }
  }
  
  /// Simulates realistic login API call
  Future<void> _performLogin(Map<String, dynamic> values) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    final email = values['email'] as String?;
    final password = values['password'] as String?;
    
    // Simulate different scenarios for demo
    if (email == 'demo@example.com' && password == 'demo123456') {
      // Success case
      return;
    } else if (email?.contains('network') == true) {
      throw NetworkException('Simulated network error');
    } else {
      throw AuthenticationException('Invalid credentials');
    }
  }
  
  /// Checks if user is rate limited
  bool _isRateLimited() {
    if (_loginAttempts < 3) return false;
    
    final now = DateTime.now();
    final lastAttempt = _lastAttempt;
    
    if (lastAttempt == null) return false;
    
    // Rate limit for 30 seconds after 3 failed attempts
    return now.difference(lastAttempt).inSeconds < 30;
  }
  
  @override
  void onReset() {
    clearValidationCache(); // Clean up cache for memory efficiency
    _loginAttempts = 0;
    _lastAttempt = null;
    
    if (kDebugMode) {
      log('Form reset completed');
    }
  }
  
  @override
  Future<void> onValid(Map<String, dynamic>? values) async {
    if (kDebugMode) {
      log('Form is valid - enabling submit button');
    }
  }
  
  /// Logs performance metrics for debugging
  void _logPerformanceMetrics() {
    if (!kDebugMode) return;
    
    final metrics = getPerformanceMetrics();
    log('=== Performance Metrics ===');
    metrics.forEach((key, value) {
      log('$key: $value');
    });
    log('Form completion: ${(getCompletionPercentage() * 100).toInt()}%');
    log('========================');
  }
}

/// Custom exception classes for better error handling
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

