import 'package:app_forms/app_forms.dart';
import 'package:example/forms/registration_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Advanced RegistrationPage demonstrating complex form patterns.
/// 
/// This page showcases:
/// - Multi-field validation dependencies
/// - Dynamic validation feedback
/// - Password strength indicators
/// - File upload simulation
/// - Progress tracking
/// - Advanced error handling
class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  
                  // Progress Section
                  _buildProgressSection(context),
                  const SizedBox(height: 24),
                  
                  // Form Section
                  _buildFormSection(context),
                  const SizedBox(height: 24),
                  
                  // Actions Section
                  _buildActionsSection(context),
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
          Icons.person_add_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Create Your Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in your details to get started',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressSection(BuildContext context) {
    return AppFormListener<RegistrationForm>(
      // Update when form completion changes
      updateWhen: (form) {
        final currentCompletion = form.getDetailedCompletionPercentage();
        if (currentCompletion != _lastCompletion) {
          _lastCompletion = currentCompletion;
          return true;
        }
        return false;
      },
      builder: (form) {
        final completion = form.getDetailedCompletionPercentage();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registration Progress',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${(completion * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completion,
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFormSection(BuildContext context) {
    return AppFormBuilder<RegistrationForm>(
      builder: (form) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Personal Information Section  
            _buildSectionHeader('Personal Information', context),
            const SizedBox(height: 16),
            
            // Name Fields
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: form.firstName.name,
                    validator: form.firstName.validations,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderTextField(
                    name: form.lastName.name,
                    validator: form.lastName.validations,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date of Birth
            FormBuilderDateTimePicker(
              name: form.dateOfBirth.name,
              inputType: InputType.date,
              initialDate: DateTime.now().subtract(const Duration(days: 6570)), // ~18 years
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gender Selection
            FormBuilderDropdown<String>(
              name: form.gender.name,
              validator: form.gender.validations,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
                DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
              ],
            ),
            const SizedBox(height: 16),
            
            // Country Selection
            FormBuilderDropdown<String>(
              name: form.country.name,
              validator: form.country.validations,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
              ),
              items: const [
                DropdownMenuItem(value: 'US', child: Text('United States')),
                DropdownMenuItem(value: 'CA', child: Text('Canada')),
                DropdownMenuItem(value: 'UK', child: Text('United Kingdom')),
                DropdownMenuItem(value: 'AU', child: Text('Australia')),
                DropdownMenuItem(value: 'DE', child: Text('Germany')),
                DropdownMenuItem(value: 'FR', child: Text('France')),
                DropdownMenuItem(value: 'JP', child: Text('Japan')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
            ),
            const SizedBox(height: 24),
            
            // Account Information Section
            _buildSectionHeader('Account Information', context),
            const SizedBox(height: 16),
            
            // Username Field with availability check
            FormBuilderTextField(
              name: form.username.name,
              validator: form.username.validations,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a unique username',
                prefixIcon: const Icon(Icons.alternate_email),
                suffixIcon: _buildUsernameValidationIcon(form),
              ),
            ),
            const SizedBox(height: 16),
            
            // Email Field
            FormBuilderTextField(
              name: form.email.name,
              validator: form.email.validations,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: _buildEmailValidationIcon(form),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password Field with strength indicator
            FormBuilderTextField(
              name: form.password.name,
              validator: form.password.validations,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Create a strong password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            const SizedBox(height: 8),
            
            // Password Strength Indicator
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 16),
            
            // Confirm Password Field
            FormBuilderTextField(
              name: form.confirmPassword.name,
              validator: form.confirmPassword.validations,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: _buildPasswordMatchIcon(form),
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Section
            _buildSectionHeader('Profile (Optional)', context),
            const SizedBox(height: 16),
            
            // Profile Picture Upload Simulation
            _buildProfilePictureUpload(form, context),
            const SizedBox(height: 24),
            
            // Terms and Conditions
            FormBuilderCheckbox(
              name: form.acceptTerms.name,
              title: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Newsletter Subscription
            FormBuilderCheckbox(
              name: form.subscribeNewsletter.name,
              title: const Text('Subscribe to our newsletter for updates and promotions'),
              initialValue: form.subscribeNewsletter.initialValue,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  Widget _buildPasswordStrengthIndicator() {
    return AppFormListener<RegistrationForm>(
      updateWhen: (form) {
        final currentStrength = form.getPasswordStrengthScore();
        if (currentStrength != _lastPasswordStrength) {
          _lastPasswordStrength = currentStrength;
          return true;
        }
        return false;
      },
      builder: (form) {
        final strength = form.getPasswordStrengthScore();
        final password = form.password.value;
        
        if (password == null || password.isEmpty) {
          return const SizedBox.shrink();
        }
        
        Color strengthColor;
        String strengthText;
        
        if (strength < 40) {
          strengthColor = Colors.red;
          strengthText = 'Weak';
        } else if (strength < 60) {
          strengthColor = Colors.orange;
          strengthText = 'Fair';
        } else if (strength < 80) {
          strengthColor = Colors.yellow.shade700;
          strengthText = 'Good';
        } else {
          strengthColor = Colors.green;
          strengthText = 'Strong';
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password Strength: $strengthText',
                  style: TextStyle(
                    color: strengthColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$strength%',
                  style: TextStyle(
                    color: strengthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: strength / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildProfilePictureUpload(RegistrationForm form, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload Profile Picture',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'JPG, PNG or GIF (max 5MB)',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _simulateFileUpload(form, context),
            child: const Text('Choose File'),
          ),
          // Show selected file
          AppFormListener<RegistrationForm>(
            updateWhen: (form) => form.profilePicture.value != _lastProfilePicture,
            builder: (form) {
              final fileName = form.profilePicture.value;
              _lastProfilePicture = fileName;
              
              if (fileName != null && fileName.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Submit Button
        AppFormListener<RegistrationForm>(
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
                      'Create Account',
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Already have an account?'),
            ),
            if (kDebugMode)
              TextButton(
                onPressed: () => _prefillDemoData(context),
                child: const Text('Fill Demo Data'),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatusSection() {
    return AppFormListener<RegistrationForm>(
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
              'Account created successfully! Please check your email to verify your account.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorMessages(RegistrationForm form) {
    final fieldErrors = <String>[];
    final state = form.state;
    
    if (state != null) {
      final fieldNames = [
        form.firstName.name,
        form.lastName.name,
        form.username.name,
        form.email.name,
        form.password.name,
        form.confirmPassword.name,
      ];
      
      for (final fieldName in fieldNames) {
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
            ...fieldErrors.take(3).map((error) => Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(
                '• $error',
                style: TextStyle(color: Colors.red.shade700),
              ),
            )),
            if (fieldErrors.length > 3)
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 4),
                child: Text(
                  '• ... and ${fieldErrors.length - 3} more errors',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDebugSection(BuildContext context) {
    return AppFormListener<RegistrationForm>(
      updateWhen: (form) {
        final currentCompletion = form.getDetailedCompletionPercentage();
        if (currentCompletion != _lastDebugCompletion) {
          _lastDebugCompletion = currentCompletion;
          return true;
        }
        return false;
      },
      builder: (form) {
        final completion = form.getDetailedCompletionPercentage();
        final passwordStrength = form.getPasswordStrengthScore();
        
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Completion: ${(completion * 100).toInt()}%'),
                    Text('Password: $passwordStrength%'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fields: ${form.getPerformanceMetrics()['fields'] ?? 'N/A'}'),
                    Text('Auto-validate: ${form.autoValidate}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget? _buildUsernameValidationIcon(RegistrationForm form) {
    return AppFormListener<RegistrationForm>(
      updateWhen: (form) {
        final usernameState = form.state?.fields[form.username.name];
        return usernameState?.hasError != _lastUsernameError;
      },
      builder: (form) {
        final usernameState = form.state?.fields[form.username.name];
        final hasError = usernameState?.hasError ?? false;
        final value = usernameState?.value as String?;
        
        _lastUsernameError = hasError;
        
        if (value?.isEmpty ?? true) return const SizedBox.shrink();
        
        return Icon(
          hasError ? Icons.error_outline : Icons.check_circle_outline,
          color: hasError ? Colors.red : Colors.green,
        );
      },
    );
  }
  
  Widget? _buildEmailValidationIcon(RegistrationForm form) {
    return AppFormListener<RegistrationForm>(
      updateWhen: (form) {
        final emailState = form.state?.fields[form.email.name];
        return emailState?.hasError != _lastEmailError;
      },
      builder: (form) {
        final emailState = form.state?.fields[form.email.name];
        final hasError = emailState?.hasError ?? false;
        final value = emailState?.value as String?;
        
        _lastEmailError = hasError;
        
        if (value?.isEmpty ?? true) return const SizedBox.shrink();
        
        return Icon(
          hasError ? Icons.error_outline : Icons.check_circle_outline,
          color: hasError ? Colors.red : Colors.green,
        );
      },
    );
  }
  
  Widget? _buildPasswordMatchIcon(RegistrationForm form) {
    return AppFormListener<RegistrationForm>(
      updateWhen: (form) {
        final passwordValue = form.password.value;
        final confirmValue = form.confirmPassword.value;
        final currentMatch = passwordValue == confirmValue && 
                           confirmValue != null && 
                           confirmValue.isNotEmpty;
        
        if (currentMatch != _lastPasswordMatch) {
          _lastPasswordMatch = currentMatch;
          return true;
        }
        return false;
      },
      builder: (form) {
        final passwordValue = form.password.value;
        final confirmValue = form.confirmPassword.value;
        
        if (confirmValue?.isEmpty ?? true) return const SizedBox.shrink();
        
        final matches = passwordValue == confirmValue;
        
        return Icon(
          matches ? Icons.check_circle_outline : Icons.error_outline,
          color: matches ? Colors.green : Colors.red,
        );
      },
    );
  }
  
  void _simulateFileUpload(RegistrationForm form, BuildContext context) {
    // Simulate file picker
    final files = ['profile_pic.jpg', 'avatar.png', 'photo.gif'];
    final selectedFile = files[(DateTime.now().millisecond) % files.length];
    
    form.profilePicture.setValue(selectedFile);
    form.updateFieldsValue();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $selectedFile')),
    );
  }
  
  void _showPerformanceDialog(BuildContext context) {
    final form = AppForms.get<RegistrationForm>();
    final metrics = form.getPerformanceMetrics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Form Metrics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...metrics.entries.map((entry) {
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
              }),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Completion'),
                    Text(
                      '${(form.getDetailedCompletionPercentage() * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Password Strength'),
                    Text(
                      '${form.getPasswordStrengthScore()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
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
  
  void _prefillDemoData(BuildContext context) {
    final form = AppForms.get<RegistrationForm>();
    
    form.firstName.setValue('John');
    form.lastName.setValue('Doe');
    form.username.setValue('johndoe123');
    form.email.setValue('john.doe@example.com');
    form.password.setValue('SecurePass123!');
    form.confirmPassword.setValue('SecurePass123!');
    form.dateOfBirth.setValue(DateTime(1990, 1, 1));
    form.gender.setValue('male');
    form.country.setValue('US');
    form.acceptTerms.setValue(true);
    
    form.updateFieldsValue();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo data filled')),
    );
  }
}

// State tracking for conditional updates
double _lastCompletion = 0.0;
int _lastPasswordStrength = 0;
double _lastDebugCompletion = 0.0;
bool? _lastUsernameError;
bool? _lastEmailError;
bool? _lastPasswordMatch;
String? _lastProfilePicture;