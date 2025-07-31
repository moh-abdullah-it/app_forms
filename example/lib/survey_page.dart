import 'package:app_forms/app_forms.dart';
import 'package:example/forms/survey_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// SurveyPage demonstrating multi-step wizard form patterns.
/// 
/// This page showcases:
/// - Step-by-step navigation
/// - Progress tracking and persistence
/// - Conditional question logic
/// - Dynamic form generation
/// - Data validation per step
/// - Skip logic and branching
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Survey'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showSurveyAnalytics(context),
              tooltip: 'Survey Analytics',
            ),
        ],
      ),
      body: SafeArea(
        child: AppFormBuilder<SurveyForm>(
          builder: (form) {
            // Update progress animation when step changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _progressAnimationController.animateTo(form.completionPercentage);
            });

            return Column(
              children: [
                // Progress Header
                _buildProgressHeader(form, theme),
                
                // Step Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 600 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Step Header
                            _buildStepHeader(form),
                            const SizedBox(height: 24),
                            
                            // Step Content
                            _buildStepContent(form),
                            const SizedBox(height: 32),
                            
                            // Navigation
                            _buildNavigation(form),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressHeader(SurveyForm form, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: [
              Text(
                'Progress:',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(form.completionPercentage * 100).toInt()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(form.totalSteps, (index) {
              final isActive = index == form.currentStep;
              final isCompleted = form.stepCompletionStatus[index];
              final isAccessible = index <= form.currentStep;
              
              return GestureDetector(
                onTap: isAccessible ? () => _goToStep(form, index) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : isActive
                            ? theme.colorScheme.primaryContainer
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCompleted || isActive
                          ? theme.colorScheme.onPrimary
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(SurveyForm form) {
    final currentStep = form.currentStep;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getStepIcon(currentStep),
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.getStepTitle(currentStep),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    form.getStepDescription(currentStep),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '~${form.getStepEstimatedTime(currentStep)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Current Step Progress
        AppFormListener<SurveyForm>(
          updateWhen: (form) => form.currentStepCompletion != _lastStepCompletion,
          builder: (form) {
            final completion = form.currentStepCompletion;
            _lastStepCompletion = completion;
            
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step Progress',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${(completion * 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completion,
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepContent(SurveyForm form) {
    switch (form.currentStep) {
      case 0:
        return _buildStep1BasicInfo(form);
      case 1:
        return _buildStep2TechnologyUsage(form);
      case 2:
        return _buildStep3AppFormsExperience(form);
      case 3:
        return _buildStep4DevelopmentPreferences(form);
      case 4:
        return _buildStep5FeedbackCompletion(form);
      default:
        return const Center(child: Text('Invalid step'));
    }
  }

  Widget _buildStep1BasicInfo(SurveyForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Participant Name
        FormBuilderTextField(
          name: form.participantName.name,
          initialValue: form.participantName.initialValue,
          validator: form.participantName.validations,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
            helperText: 'Your name will be kept confidential',
          ),
        ),
        const SizedBox(height: 16),
        
        // Email
        FormBuilderTextField(
          name: form.participantEmail.name,
          initialValue: form.participantEmail.initialValue,
          validator: form.participantEmail.validations,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email),
            helperText: 'For survey updates only (optional follow-up)',
          ),
        ),
        const SizedBox(height: 16),
        
        // Age Group
        FormBuilderDropdown<String>(
          name: form.ageGroup.name,
          initialValue: form.ageGroup.initialValue,
          validator: form.ageGroup.validations,
          decoration: const InputDecoration(
            labelText: 'Age Group',
            prefixIcon: Icon(Icons.cake),
          ),
          items: const [
            DropdownMenuItem(value: '18-24', child: Text('18-24 years')),
            DropdownMenuItem(value: '25-34', child: Text('25-34 years')),
            DropdownMenuItem(value: '35-44', child: Text('35-44 years')),
            DropdownMenuItem(value: '45-54', child: Text('45-54 years')),
            DropdownMenuItem(value: '55+', child: Text('55+ years')),
          ],
        ),
        const SizedBox(height: 16),
        
        // Occupation
        FormBuilderTextField(
          name: form.occupation.name,
          initialValue: form.occupation.initialValue,
          validator: form.occupation.validations,
          decoration: const InputDecoration(
            labelText: 'Occupation/Role',
            prefixIcon: Icon(Icons.work),
            helperText: 'e.g., Software Developer, Product Manager, etc.',
          ),
        ),
      ],
    );
  }

  Widget _buildStep2TechnologyUsage(SurveyForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Device
        FormBuilderRadioGroup<String>(
          name: form.primaryDevice.name,
          initialValue: form.primaryDevice.initialValue,
          validator: form.primaryDevice.validations,
          decoration: const InputDecoration(
            labelText: 'Primary Development Device',
            border: InputBorder.none,
          ),
          options: const [
            FormBuilderFieldOption(value: 'desktop', child: Text('Desktop Computer')),
            FormBuilderFieldOption(value: 'laptop', child: Text('Laptop')),
            FormBuilderFieldOption(value: 'smartphone', child: Text('Smartphone (for testing)')),
            FormBuilderFieldOption(value: 'tablet', child: Text('Tablet')),
          ],
        ),
        const SizedBox(height: 24),
        
        // Daily Screen Time
        FormBuilderDropdown<String>(
          name: form.dailyScreenTime.name,
          initialValue: form.dailyScreenTime.initialValue,
          validator: form.dailyScreenTime.validations,
          decoration: const InputDecoration(
            labelText: 'Daily Development Screen Time',
            prefixIcon: Icon(Icons.schedule),
          ),
          items: const [
            DropdownMenuItem(value: '1-2 hours', child: Text('1-2 hours')),
            DropdownMenuItem(value: '2-4 hours', child: Text('2-4 hours')),
            DropdownMenuItem(value: '4-6 hours', child: Text('4-6 hours')),
            DropdownMenuItem(value: '6-8 hours', child: Text('6-8 hours')),
            DropdownMenuItem(value: '8+ hours', child: Text('8+ hours')),
          ],
        ),
        const SizedBox(height: 24),
        
        // Favorite Platforms
        FormBuilderCheckboxGroup<String>(
          name: form.favoritePlatforms.name,
          initialValue: form.favoritePlatforms.initialValue,
          decoration: const InputDecoration(
            labelText: 'Favorite Development Platforms (select all that apply)',
            border: InputBorder.none,
          ),
          options: const [
            FormBuilderFieldOption(value: 'flutter', child: Text('Flutter')),
            FormBuilderFieldOption(value: 'react_native', child: Text('React Native')),
            FormBuilderFieldOption(value: 'native_android', child: Text('Native Android')),
            FormBuilderFieldOption(value: 'native_ios', child: Text('Native iOS')),
            FormBuilderFieldOption(value: 'web', child: Text('Web Development')),
            FormBuilderFieldOption(value: 'desktop', child: Text('Desktop Applications')),
          ],
        ),
        const SizedBox(height: 24),
        
        // Coding Experience
        FormBuilderDropdown<String>(
          name: form.codingExperience.name,
          initialValue: form.codingExperience.initialValue,
          validator: form.codingExperience.validations,
          decoration: const InputDecoration(
            labelText: 'Years of Coding Experience',
            prefixIcon: Icon(Icons.code),
          ),
          items: const [
            DropdownMenuItem(value: 'less than 1', child: Text('Less than 1 year')),
            DropdownMenuItem(value: '1-2 years', child: Text('1-2 years')),
            DropdownMenuItem(value: '3-5 years', child: Text('3-5 years')),
            DropdownMenuItem(value: '6-10 years', child: Text('6-10 years')),
            DropdownMenuItem(value: '10+ years', child: Text('10+ years')),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3AppFormsExperience(SurveyForm form) {
    return AppFormListener<SurveyForm>(
      updateWhen: (form) => form.hasUsedAppForms.value != _lastHasUsedAppForms,
      builder: (form) {
        final hasUsed = form.hasUsedAppForms.value;
        _lastHasUsedAppForms = hasUsed;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Has Used App Forms
            FormBuilderRadioGroup<bool>(
              name: form.hasUsedAppForms.name,
              initialValue: form.hasUsedAppForms.initialValue,
              decoration: const InputDecoration(
                labelText: 'Have you used the app_forms package before?',
                border: InputBorder.none,
              ),
              options: const [
                FormBuilderFieldOption(value: true, child: Text('Yes, I have used it')),
                FormBuilderFieldOption(value: false, child: Text('No, this is my first time learning about it')),
              ],
            ),
            
            // Conditional questions for experienced users
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: hasUsed == true ? null : 0,
              child: AnimatedOpacity(
                opacity: hasUsed == true ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: hasUsed == true
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          Text(
                            'Great! Tell us about your experience:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Rating
                          FormBuilderSlider(
                            name: form.appFormsRating.name,
                            initialValue: form.appFormsRating.initialValue ?? 3.0,
                            min: 1.0,
                            max: 5.0,
                            divisions: 8,
                            decoration: const InputDecoration(
                              labelText: 'Overall Rating (1-5 stars)',
                              helperText: 'How would you rate your experience?',
                              border: InputBorder.none,
                            ),
                            displayValues: DisplayValues.current,
                          ),
                          const SizedBox(height: 24),
                          
                          // Favorite Features
                          FormBuilderCheckboxGroup<String>(
                            name: form.appFormsFeatures.name,
                            initialValue: form.appFormsFeatures.initialValue,
                            decoration: const InputDecoration(
                              labelText: 'Which features do you appreciate most?',
                              border: InputBorder.none,
                            ),
                            options: const [
                              FormBuilderFieldOption(value: 'validation', child: Text('Smart Validation Caching')),
                              FormBuilderFieldOption(value: 'performance', child: Text('Performance Optimizations')),
                              FormBuilderFieldOption(value: 'architecture', child: Text('Clean Architecture Pattern')),
                              FormBuilderFieldOption(value: 'flexibility', child: Text('Flexibility and Customization')),
                              FormBuilderFieldOption(value: 'documentation', child: Text('Documentation')),
                              FormBuilderFieldOption(value: 'examples', child: Text('Examples and Demos')),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Improvement Suggestions
                          FormBuilderTextField(
                            name: form.improvementSuggestions.name,
                            initialValue: form.improvementSuggestions.initialValue,
                            validator: form.improvementSuggestions.validations,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Suggestions for Improvement (Optional)',
                              helperText: 'What would make app_forms even better?',
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            
            // Information for new users
            if (hasUsed == false) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'app_forms Package Overview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'app_forms is a high-performance Flutter package for form management '
                      'with smart validation caching, conditional updates, and clean architecture patterns.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStep4DevelopmentPreferences(SurveyForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preferred Architecture
        FormBuilderDropdown<String>(
          name: form.preferredArchitecture.name,
          initialValue: form.preferredArchitecture.initialValue,
          validator: form.preferredArchitecture.validations,
          decoration: const InputDecoration(
            labelText: 'Preferred Architecture Pattern',
            prefixIcon: Icon(Icons.architecture),
          ),
          items: const [
            DropdownMenuItem(value: 'mvc', child: Text('MVC (Model-View-Controller)')),
            DropdownMenuItem(value: 'mvvm', child: Text('MVVM (Model-View-ViewModel)')),
            DropdownMenuItem(value: 'clean_architecture', child: Text('Clean Architecture')),
            DropdownMenuItem(value: 'feature_first', child: Text('Feature-First Architecture')),
            DropdownMenuItem(value: 'layered', child: Text('Layered Architecture')),
            DropdownMenuItem(value: 'other', child: Text('Other/Custom')),
          ],
        ),
        const SizedBox(height: 16),
        
        // State Management
        FormBuilderDropdown<String>(
          name: form.stateManagement.name,
          initialValue: form.stateManagement.initialValue,
          decoration: const InputDecoration(
            labelText: 'Preferred State Management',
            prefixIcon: const Icon(Icons.settings),
          ),
          items: const [
            DropdownMenuItem(value: 'bloc', child: Text('BLoC/Cubit')),
            DropdownMenuItem(value: 'provider', child: Text('Provider')),
            DropdownMenuItem(value: 'riverpod', child: Text('Riverpod')),
            DropdownMenuItem(value: 'getx', child: Text('GetX')),
            DropdownMenuItem(value: 'setState', child: Text('setState (vanilla Flutter)')),
            DropdownMenuItem(value: 'mobx', child: Text('MobX')),
            DropdownMenuItem(value: 'redux', child: Text('Redux')),
          ],
        ),
        const SizedBox(height: 24),
        
        // Testing Importance
        FormBuilderSlider(
          name: form.testingImportance.name,
          initialValue: form.testingImportance.initialValue ?? 3.0,
          min: 1.0,
          max: 5.0,
          divisions: 4,
          decoration: const InputDecoration(
            labelText: 'Importance of Testing (1=Not Important, 5=Critical)',
            helperText: 'How important is testing in your development process?',
            border: InputBorder.none,
          ),
          displayValues: DisplayValues.current,
        ),
        const SizedBox(height: 24),
        
        // Development Challenges
        FormBuilderCheckboxGroup<String>(
          name: form.developmentChallenges.name,
          initialValue: form.developmentChallenges.initialValue,
          decoration: const InputDecoration(
            labelText: 'What are your biggest development challenges?',
            border: InputBorder.none,
          ),
          options: const [
            FormBuilderFieldOption(value: 'performance', child: Text('Performance Optimization')),
            FormBuilderFieldOption(value: 'testing', child: Text('Testing and Quality Assurance')),
            FormBuilderFieldOption(value: 'architecture', child: Text('Architecture and Code Organization')),
            FormBuilderFieldOption(value: 'ui_ux', child: Text('UI/UX Design Implementation')),
            FormBuilderFieldOption(value: 'state_management', child: Text('State Management Complexity')),
            FormBuilderFieldOption(value: 'deployment', child: Text('Deployment and CI/CD')),
            FormBuilderFieldOption(value: 'team_collaboration', child: Text('Team Collaboration')),
            FormBuilderFieldOption(value: 'learning_curve', child: Text('Keeping Up with New Technologies')),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5FeedbackCompletion(SurveyForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall Satisfaction
        FormBuilderSlider(
          name: form.overallSatisfaction.name,
          initialValue: form.overallSatisfaction.initialValue ?? 3.0,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          decoration: const InputDecoration(
            labelText: 'Overall Satisfaction with Flutter Development',
            helperText: 'How satisfied are you with Flutter as a development platform?',
            border: InputBorder.none,
          ),
          displayValues: DisplayValues.current,
        ),
        const SizedBox(height: 24),
        
        // Additional Comments
        FormBuilderTextField(
          name: form.additionalComments.name,
          initialValue: form.additionalComments.initialValue,
          validator: form.additionalComments.validations,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Additional Comments (Optional)',
            helperText: 'Any other thoughts or feedback you\'d like to share?',
          ),
        ),
        const SizedBox(height: 24),
        
        // Follow-up Preferences
        FormBuilderSwitch(
          name: form.allowFollowUp.name,
          initialValue: form.allowFollowUp.initialValue,
          title: const Text('Allow Follow-up Contact'),
          subtitle: const Text('We may contact you for additional feedback or clarification'),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
        
        FormBuilderSwitch(
          name: form.subscribeUpdates.name,
          initialValue: form.subscribeUpdates.initialValue,
          title: const Text('Subscribe to Updates'),
          subtitle: const Text('Receive notifications about app_forms package updates'),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 24),
        
        // Completion Message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                Icons.celebration,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Thank You!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your feedback helps us improve the app_forms package '
                'and create better development tools for the Flutter community.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation(SurveyForm form) {
    return Row(
      children: [
        // Previous Button
        if (form.currentStep > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _previousStep(form),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          ),
        
        if (form.currentStep > 0) const SizedBox(width: 16),
        
        // Next/Submit Button
        Expanded(
          flex: 2,
          child: AppFormListener<SurveyForm>(
            updateWhen: (form) => 
                form.progressing || 
                form.hasErrors || 
                form.success ||
                form.currentStepCompletion != _lastStepCompletion,
            builder: (form) {
              final isLastStep = form.currentStep == form.totalSteps - 1;
              final canProceed = form.currentStepCompletion > 0.8; // At least 80% complete
              
              return ElevatedButton.icon(
                onPressed: form.progressing || !canProceed
                    ? null
                    : () => isLastStep ? form.submit() : _nextStep(form),
                icon: form.progressing
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isLastStep ? Icons.send : Icons.arrow_forward),
                label: Text(isLastStep ? 'Submit Survey' : 'Next Step'),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.devices;
      case 2:
        return Icons.flutter_dash;
      case 3:
        return Icons.architecture;
      case 4:
        return Icons.feedback;
      default:
        return Icons.help;
    }
  }

  void _goToStep(SurveyForm form, int step) {
    if (form.goToStep(step)) {
      setState(() {});
    }
  }

  void _nextStep(SurveyForm form) {
    if (form.nextStep()) {
      setState(() {});
    }
  }

  void _previousStep(SurveyForm form) {
    if (form.previousStep()) {
      setState(() {});
    }
  }

  void _showSurveyAnalytics(BuildContext context) {
    final form = AppForms.get<SurveyForm>();
    final progress = form.getProgressSummary();
    final analysis = form.analyzeSurveyData();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Survey Analytics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progress:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...progress.entries.map((entry) {
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
              const Text('Current Responses:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total: ${analysis['metadata']?['responsesCount'] ?? 0}'),
              if (analysis['demographics'] != null) ...[
                const SizedBox(height: 8),
                const Text('Demographics:', style: TextStyle(fontWeight: FontWeight.w600)),
                ...analysis['demographics'].entries.map((entry) {
                  return Text('${entry.key}: ${entry.value}');
                }),
              ],
            ],
          ),
        ),
        actions: [
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
double _lastStepCompletion = 0.0;
bool? _lastHasUsedAppForms;