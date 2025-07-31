import 'package:app_forms/app_forms.dart';
import 'package:example/forms/login_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Advanced LoginPage demonstrating performance optimizations.
/// 
/// This page showcases:
/// - Conditional rebuilds with updateWhen
/// - Performance monitoring UI
/// - Advanced form state handling
/// - Responsive design patterns
/// - Error handling UI
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Login Demo'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showPerformanceDialog(context),
              tooltip: 'Performance Metrics',
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 400 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  _buildHeader(theme),
                  const SizedBox(height: 32),
                  
                  // Form Section
                  _buildFormSection(),
                  const SizedBox(height: 24),
                  
                  // Actions Section
                  _buildActionsSection(),
                  const SizedBox(height: 16),
                  
                  // Status Section  
                  _buildStatusSection(),
                  
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    _buildDebugSection(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.lock_outline,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFormSection() {
    return AppFormBuilder<LoginForm>(
      builder: (form) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            FormBuilderTextField(
              name: form.email.name,
              validator: form.email.validations,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
                filled: true,
                suffixIcon: _buildEmailValidationIcon(form),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password Field
            FormBuilderTextField(
              name: form.password.name,
              validator: form.password.validations,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock_outlined),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onSubmitted: (value) {
                if (form.saveAndValidate() ?? false) {
                  form.submit();
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Remember Me Checkbox
            FormBuilderCheckbox(
              name: form.rememberMe.name,
              title: const Text('Remember me'),
              initialValue: form.rememberMe.initialValue,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Submit Button with conditional updates
        AppFormListener<LoginForm>(
          // Only rebuild when form state or validation changes
          updateWhen: (form) => 
              form.progressing || 
              form.hasErrors || 
              form.success,
          builder: (form) {
            // Use hasErrors to determine if form is valid
            // Don't call saveAndValidate during build as it triggers setState
            final isValid = !form.hasErrors;
            
            return ElevatedButton(
              onPressed: form.progressing || !isValid
                  ? null
                  : () {
                    // Validate before submit
                    if (form.saveAndValidate() ?? false) {
                      form.submit();
                    }
                  },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: form.progressing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16),
                    ),
            );
          },
        ),
        const SizedBox(height: 12),
        
        // Secondary Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _showForgotPasswordDialog(),
              child: const Text('Forgot Password?'),
            ),
            if (kDebugMode)
              TextButton(
                onPressed: () => _prefillDemoCredentials(),
                child: const Text('Demo Login'),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatusSection() {
    return AppFormListener<LoginForm>(
      // Only rebuild for status changes
      updateWhen: (form) => form.hasErrors || form.success,
      builder: (form) {
        if (form.success) {
          return _buildSuccessMessage();
        }
        
        if (form.hasErrors) {
          return _buildErrorMessages(form);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Login successful! Redirecting...',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorMessages(LoginForm form) {
    // Get field-specific errors
    final fieldErrors = <String>[];
    final state = form.state;
    
    if (state != null) {
      for (final fieldName in [form.email.name, form.password.name]) {
        final fieldState = state.fields[fieldName];
        if (fieldState?.hasError == true) {
          fieldErrors.add(fieldState!.errorText!);
        }
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Please fix the following errors:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (fieldErrors.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...fieldErrors.map((error) => Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(
                '• $error',
                style: TextStyle(color: Colors.red.shade700),
              ),
            )),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDebugSection(BuildContext context) {
    return AppFormListener<LoginForm>(
      // Update only when field values change (for completion percentage)
      updateWhen: (form) {
        final currentCompletion = form.getCompletionPercentage();
        if (currentCompletion != _lastCompletion) {
          _lastCompletion = currentCompletion;
          return true;
        }
        return false;
      },
      builder: (form) {
        final completion = form.getCompletionPercentage();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug Info',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completion,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Text('Form Completion: ${(completion * 100).toInt()}%'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text('Auto-validate: ${form.autoValidate}'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                    Chip(
                      label: Text('Fields: ${form.getPerformanceMetrics()['fields'] ?? 'N/A'}'),
                      backgroundColor: Colors.green.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget? _buildEmailValidationIcon(LoginForm form) {
    return AppFormListener<LoginForm>(
      updateWhen: (form) {
        final emailState = form.state?.fields[form.email.name];
        return emailState?.hasError != _lastEmailError;
      },
      builder: (form) {
        final emailState = form.state?.fields[form.email.name];
        final hasError = emailState?.hasError ?? false;
        final value = emailState?.value as String?;
        
        _lastEmailError = hasError;
        
        if (value?.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        
        return Icon(
          hasError ? Icons.error_outline : Icons.check_circle_outline,
          color: hasError ? Colors.red : Colors.green,
        );
      },
    );
  }
  
  void _showPerformanceDialog(BuildContext context) {
    final form = AppForms.get<LoginForm>();
    final metrics = form.getPerformanceMetrics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Metrics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metrics.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              form.clearValidationCache();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear Cache'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showForgotPasswordDialog() {
    // Implement forgot password flow
  }
  
  void _prefillDemoCredentials() {
    final form = AppForms.get<LoginForm>();
    form.updateEmailValue('demo@example.com');
    form.password.setValue('demo123456');
    form.updateFieldsValue();
  }
}

// State tracking for conditional updates
double _lastCompletion = 0.0;
bool? _lastEmailError;