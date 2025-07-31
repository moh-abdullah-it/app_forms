import 'package:app_forms/app_forms.dart';
import 'package:example/forms/profile_settings_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// ProfileSettingsPage demonstrating dynamic form management and real-time updates.
/// 
/// This page showcases:
/// - Dynamic field generation
/// - Conditional field visibility
/// - Real-time preference updates
/// - Auto-save functionality
/// - Data export/import
/// - Advanced validation patterns
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showPerformanceDialog(context),
              tooltip: 'Performance Metrics',
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportSettings(),
            tooltip: 'Export Settings',
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => _importSettings(),
            tooltip: 'Import Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            Tab(icon: Icon(Icons.security), text: 'Privacy & Security'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(isTablet),
            _buildNotificationsTab(isTablet),
            _buildPrivacySecurityTab(isTablet),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildProfileTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : double.infinity,
          ),
          child: AppFormBuilder<ProfileSettingsForm>(
            builder: (form) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Information Section
                  _buildSectionHeader('Personal Information', Icons.person),
                  const SizedBox(height: 16),
                  
                  // Display Name
                  FormBuilderTextField(
                    name: form.displayName.name,
                    initialValue: form.displayName.initialValue,
                    validator: form.displayName.validations,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.badge),
                      helperText: 'This name will be visible to other users',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bio with character counter
                  AppFormListener<ProfileSettingsForm>(
                    updateWhen: (form) => form.bio.value != _lastBioValue,
                    builder: (form) {
                      final currentLength = form.bio.value?.length ?? 0;
                      _lastBioValue = form.bio.value;
                      
                      return FormBuilderTextField(
                        name: form.bio.name,
                        initialValue: form.bio.initialValue,
                        validator: form.bio.validations,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: const Icon(Icons.description),
                          helperText: '$currentLength/200 characters',
                          helperStyle: TextStyle(
                            color: currentLength > 180 ? Colors.orange : null,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Number
                  FormBuilderTextField(
                    name: form.phoneNumber.name,
                    initialValue: form.phoneNumber.initialValue,
                    validator: form.phoneNumber.validations,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      prefixIcon: Icon(Icons.phone),
                      helperText: 'For account security and notifications',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Preferences Section
                  _buildSectionHeader('Preferences', Icons.settings),
                  const SizedBox(height: 16),
                  
                  // Theme Mode
                  FormBuilderDropdown<String>(
                    name: form.themeMode.name,
                    initialValue: form.themeMode.initialValue,
                    validator: form.themeMode.validations,
                    decoration: const InputDecoration(
                      labelText: 'Theme',
                      prefixIcon: Icon(Icons.palette),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System Default')),
                      DropdownMenuItem(value: 'light', child: Text('Light Mode')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark Mode')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Language
                  FormBuilderDropdown<String>(
                    name: form.language.name,
                    initialValue: form.language.initialValue,
                    validator: form.language.validations,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      prefixIcon: Icon(Icons.language),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                      DropdownMenuItem(value: 'ja', child: Text('日本語')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Time Zone
                  FormBuilderDropdown<String>(
                    name: form.timeZone.name,
                    initialValue: form.timeZone.initialValue,
                    validator: form.timeZone.validations,
                    decoration: const InputDecoration(
                      labelText: 'Time Zone',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'America/New_York', child: Text('Eastern Time (ET)')),
                      DropdownMenuItem(value: 'America/Chicago', child: Text('Central Time (CT)')),
                      DropdownMenuItem(value: 'America/Denver', child: Text('Mountain Time (MT)')),
                      DropdownMenuItem(value: 'America/Los_Angeles', child: Text('Pacific Time (PT)')),
                      DropdownMenuItem(value: 'Europe/London', child: Text('Greenwich Mean Time (GMT)')),
                      DropdownMenuItem(value: 'Europe/Berlin', child: Text('Central European Time (CET)')),
                      DropdownMenuItem(value: 'Asia/Tokyo', child: Text('Japan Standard Time (JST)')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Dynamic Features Section
                  _buildDynamicFeaturesSection(form),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : double.infinity,
          ),
          child: AppFormBuilder<ProfileSettingsForm>(
            builder: (form) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Notification Preferences Section
                  _buildSectionHeader('Notification Preferences', Icons.notifications),
                  const SizedBox(height: 16),
                  
                  // Email Notifications
                  FormBuilderSwitch(
                    name: form.emailNotifications.name,
                    initialValue: form.emailNotifications.initialValue,
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive notifications via email'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                  
                  // Conditional email options
                  AppFormListener<ProfileSettingsForm>(
                    updateWhen: (form) => form.emailNotifications.value != _lastEmailNotifications,
                    builder: (form) {
                      final emailEnabled = form.emailNotifications.value ?? false;
                      _lastEmailNotifications = emailEnabled;
                      
                      return AnimatedOpacity(
                        opacity: emailEnabled ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              child: Column(
                                children: [
                                  FormBuilderSwitch(
                                    name: form.marketingEmails.name,
                                    initialValue: form.marketingEmails.initialValue,
                                    enabled: emailEnabled,
                                    title: const Text('Marketing Emails'),
                                    subtitle: const Text('Product updates and promotions'),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  FormBuilderSwitch(
                                    name: form.weeklyDigest.name,
                                    initialValue: form.weeklyDigest.initialValue,
                                    enabled: emailEnabled,
                                    title: const Text('Weekly Digest'),
                                    subtitle: const Text('Summary of your activity'),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Push Notifications
                  FormBuilderSwitch(
                    name: form.pushNotifications.name,
                    initialValue: form.pushNotifications.initialValue,
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive notifications on your device'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Auto-Save Section
                  _buildSectionHeader('Auto-Save', Icons.save),
                  const SizedBox(height: 16),
                  
                  FormBuilderSwitch(
                    name: form.autoSave.name,
                    initialValue: form.autoSave.initialValue,
                    title: const Text('Auto-Save Settings'),
                    subtitle: const Text('Automatically save changes as you make them'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                  
                  // Save Status
                  AppFormListener<ProfileSettingsForm>(
                    updateWhen: (form) {
                      final status = form.getSaveStatus();
                      return status['hasUnsavedChanges'] != _lastUnsavedChanges;
                    },
                    builder: (form) {
                      final status = form.getSaveStatus();
                      final hasChanges = status['hasUnsavedChanges'] as bool;
                      final lastSaved = status['lastSaved'] as String?;
                      
                      _lastUnsavedChanges = hasChanges;
                      
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hasChanges 
                              ? Colors.orange.shade50 
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasChanges 
                                ? Colors.orange.shade200 
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasChanges ? Icons.warning : Icons.check_circle,
                              color: hasChanges ? Colors.orange : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasChanges
                                    ? 'You have unsaved changes'
                                    : lastSaved != null
                                        ? 'Settings saved'
                                        : 'No changes made',
                                style: TextStyle(
                                  color: hasChanges ? Colors.orange.shade700 : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySecurityTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : double.infinity,
          ),
          child: AppFormBuilder<ProfileSettingsForm>(
            builder: (form) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Privacy Section
                  _buildSectionHeader('Privacy Settings', Icons.privacy_tip),
                  const SizedBox(height: 16),
                  
                  // Privacy Level
                  FormBuilderDropdown<String>(
                    name: form.privacyLevel.name,
                    initialValue: form.privacyLevel.initialValue,
                    validator: form.privacyLevel.validations,
                    decoration: const InputDecoration(
                      labelText: 'Privacy Level',
                      prefixIcon: Icon(Icons.shield),
                      helperText: 'Controls who can see your activity',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'public', child: Text('Public')),
                      DropdownMenuItem(value: 'friends', child: Text('Friends Only')),
                      DropdownMenuItem(value: 'private', child: Text('Private')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Profile Visibility
                  FormBuilderDropdown<String>(
                    name: form.profileVisibility.name,
                    initialValue: form.profileVisibility.initialValue,
                    validator: form.profileVisibility.validations,
                    decoration: const InputDecoration(
                      labelText: 'Profile Visibility',
                      prefixIcon: Icon(Icons.visibility),
                      helperText: 'Who can see your profile information',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'public', child: Text('Everyone')),
                      DropdownMenuItem(value: 'registered', child: Text('Registered Users')),
                      DropdownMenuItem(value: 'friends', child: Text('Friends Only')),
                      DropdownMenuItem(value: 'private', child: Text('Only Me')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Security Section
                  _buildSectionHeader('Security Settings', Icons.security),
                  const SizedBox(height: 16),
                  
                  // Two-Factor Authentication
                  FormBuilderSwitch(
                    name: form.twoFactorEnabled.name,
                    initialValue: form.twoFactorEnabled.initialValue,
                    title: const Text('Two-Factor Authentication'),
                    subtitle: const Text('Add an extra layer of security to your account'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Session Timeout
                  FormBuilderTextField(
                    name: form.sessionTimeout.name,
                    initialValue: form.sessionTimeout.initialValue?.toString(),
                    validator: form.sessionTimeout.validations,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Session Timeout',
                      helperText: 'Automatically log out after inactivity',
                      border: InputBorder.none,
                    ),
                  ),
                  
                  // Session timeout display
                  AppFormListener<ProfileSettingsForm>(
                    updateWhen: (form) => form.sessionTimeout.value != _lastSessionTimeout,
                    builder: (form) {
                      final timeout = form.sessionTimeout.value ?? 30;
                      _lastSessionTimeout = timeout;
                      
                      return Container(
                        margin: const EdgeInsets.only(top: 8, left: 16),
                        child: Text(
                          timeout >= 60 
                              ? '${(timeout / 60).toStringAsFixed(1)} hours'
                              : '$timeout minutes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Data Management Section
                  _buildSectionHeader('Data Management', Icons.storage),
                  const SizedBox(height: 16),
                  
                  // Export Format
                  FormBuilderDropdown<String>(
                    name: form.exportFormat.name,
                    initialValue: form.exportFormat.initialValue,
                    decoration: const InputDecoration(
                      labelText: 'Export Format',
                      prefixIcon: Icon(Icons.download),
                      helperText: 'Format for data exports',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'json', child: Text('JSON')),
                      DropdownMenuItem(value: 'csv', child: Text('CSV')),
                      DropdownMenuItem(value: 'xml', child: Text('XML')),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFeaturesSection(ProfileSettingsForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Advanced Features', Icons.science),
        const SizedBox(height: 16),
        
        AppFormListener<ProfileSettingsForm>(
          updateWhen: (form) => form.getDynamicFeatureStates() != _lastFeatureStates,
          builder: (form) {
            final features = form.getDynamicFeatureStates();
            _lastFeatureStates = Map.from(features);
            
            return Column(
              children: features.entries.map((entry) {
                return FormBuilderSwitch(
                  name: entry.key,
                  initialValue: entry.value,
                  title: Text(_getFeatureDisplayName(entry.key)),
                  subtitle: Text(_getFeatureDescription(entry.key)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    form.updateDynamicFeature(entry.key, value ?? false);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _resetForm(),
                child: const Text('Reset to Defaults'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: AppFormListener<ProfileSettingsForm>(
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
                    child: form.progressing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save Settings'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureDisplayName(String key) {
    final displayNames = {
      'darkModeSchedule': 'Dark Mode Schedule',
      'advancedSearch': 'Advanced Search',
      'betaFeatures': 'Beta Features',
      'analyticsTracking': 'Analytics Tracking',
      'locationServices': 'Location Services',
      'voiceCommands': 'Voice Commands',
    };
    return displayNames[key] ?? key;
  }

  String _getFeatureDescription(String key) {
    final descriptions = {
      'darkModeSchedule': 'Automatically switch to dark mode at sunset',
      'advancedSearch': 'Enable advanced search and filtering options',
      'betaFeatures': 'Access experimental features (may be unstable)',
      'analyticsTracking': 'Help improve the app with usage analytics',
      'locationServices': 'Use location for enhanced features',
      'voiceCommands': 'Control the app with voice commands',
    };
    return descriptions[key] ?? 'Toggle this feature';
  }

  void _exportSettings() {
    final form = AppForms.get<ProfileSettingsForm>();
    final settings = form.exportSettings();
    
    // In a real app, you'd save to file or share
    if (kDebugMode) {
      print('Exported settings: $settings');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings exported to debug console')),
    );
  }

  void _importSettings() {
    // In a real app, you'd show file picker or import dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality would open file picker')),
    );
  }

  void _resetForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppForms.get<ProfileSettingsForm>().reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPerformanceDialog(BuildContext context) {
    final form = AppForms.get<ProfileSettingsForm>();
    final metrics = form.getPerformanceMetrics();
    final saveStatus = form.getSaveStatus();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Settings Performance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Performance Metrics:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...metrics.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
              const Divider(),
              const Text('Save Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...saveStatus.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Completion'),
                  Text('${(form.getCompletionPercentage() * 100).toInt()}%', 
                       style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dynamic Features'),
                  Text('${form.getDynamicFeatureStates().length}', 
                       style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
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
}

// State tracking for conditional updates
String? _lastBioValue;
bool? _lastEmailNotifications;
bool? _lastUnsavedChanges;
int? _lastSessionTimeout;
Map<String, bool> _lastFeatureStates = {};