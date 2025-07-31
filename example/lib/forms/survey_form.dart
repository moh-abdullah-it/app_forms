import 'dart:developer';

import 'package:app_forms/app_forms.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/foundation.dart';

/// Advanced SurveyForm demonstrating multi-step wizard patterns.
/// 
/// This form showcases:
/// - Multi-step form navigation
/// - Conditional question logic
/// - Progress persistence across steps
/// - Dynamic question generation
/// - Data aggregation and analysis
/// - Step-by-step validation
/// - Skip logic and branching
class SurveyForm extends AppForm {
  @override
  bool get autoValidate => false; // Manual validation per step

  /// Current step in the survey
  int _currentStep = 0;
  
  /// Total number of steps
  static const int _totalSteps = 5;
  
  /// Step completion tracking
  final List<bool> _stepCompleted = List.filled(_totalSteps, false);
  
  /// Survey responses for analysis
  final Map<String, dynamic> _responses = {};

  // Step 1: Basic Information
  final participantName = AppFormField<String>(
    name: 'participantName',
    initialValue: kDebugMode ? 'Survey Participant' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Please enter your name',
      ),
      FormBuilderValidators.minLength(
        2,
        errorText: 'Name must be at least 2 characters',
      ),
    ]),
  );

  final participantEmail = AppFormField<String>(
    name: 'participantEmail',
    initialValue: kDebugMode ? 'participant@example.com' : '',
    validations: FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Email is required',
      ),
      FormBuilderValidators.email(
        errorText: 'Please enter a valid email address',
      ),
    ]),
  );

  final ageGroup = AppFormField<String>(
    name: 'ageGroup',
    initialValue: kDebugMode ? '25-34' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your age group',
    ),
  );

  final occupation = AppFormField<String>(
    name: 'occupation',
    initialValue: kDebugMode ? 'Software Developer' : '',
    validations: FormBuilderValidators.required(
      errorText: 'Please enter your occupation',
    ),
  );

  // Step 2: Technology Usage
  final primaryDevice = AppFormField<String>(
    name: 'primaryDevice',
    initialValue: kDebugMode ? 'smartphone' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your primary device',
    ),
  );

  final dailyScreenTime = AppFormField<String>(
    name: 'dailyScreenTime',
    initialValue: kDebugMode ? '4-6 hours' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your daily screen time',
    ),
  );

  final favoritePlatforms = AppFormField<List<String>>(
    name: 'favoritePlatforms',
    initialValue: kDebugMode ? ['flutter', 'web'] : [],
    validations: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select at least one platform';
      }
      return null;
    },
  );

  final codingExperience = AppFormField<String>(
    name: 'codingExperience',
    initialValue: kDebugMode ? '3-5 years' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your coding experience',
    ),
  );

  // Step 3: App Forms Experience (Conditional)
  final hasUsedAppForms = AppFormField<bool>(
    name: 'hasUsedAppForms',
    initialValue: kDebugMode ? true : null,
    validations: (value) {
      if (value == null) {
        return 'Please indicate if you have used app_forms before';
      }
      return null;
    },
  );

  // Conditional fields (only shown if hasUsedAppForms is true)
  final appFormsRating = AppFormField<double>(
    name: 'appFormsRating',
    initialValue: kDebugMode ? 4.5 : null,
    validations: (value) {
      // Conditional validation will be handled in validateCurrentStep
      return null;
    },
  );

  final appFormsFeatures = AppFormField<List<String>>(
    name: 'appFormsFeatures',
    initialValue: kDebugMode ? ['validation', 'performance'] : [],
    validations: (value) {
      // Conditional validation will be handled in validateCurrentStep
      return null;
    },
  );

  final improvementSuggestions = AppFormField<String>(
    name: 'improvementSuggestions',
    initialValue: kDebugMode ? 'More examples and documentation would be helpful.' : '',
    // Optional field
  );

  // Step 4: Development Preferences
  final preferredArchitecture = AppFormField<String>(
    name: 'preferredArchitecture',
    initialValue: kDebugMode ? 'clean_architecture' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your preferred architecture',
    ),
  );

  final stateManagement = AppFormField<String>(
    name: 'stateManagement',
    initialValue: kDebugMode ? 'bloc' : null,
    validations: FormBuilderValidators.required(
      errorText: 'Please select your preferred state management',
    ),
  );

  final testingImportance = AppFormField<double>(
    name: 'testingImportance',
    initialValue: kDebugMode ? 4.0 : null,
    validations: (value) {
      if (value == null) {
        return 'Please rate the importance of testing';
      }
      return null;
    },
  );

  final developmentChallenges = AppFormField<List<String>>(
    name: 'developmentChallenges',
    initialValue: kDebugMode ? ['performance', 'testing'] : [],
    validations: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select at least one challenge';
      }
      return null;
    },
  );

  // Step 5: Feedback and Completion
  final overallSatisfaction = AppFormField<double>(
    name: 'overallSatisfaction',
    initialValue: kDebugMode ? 4.2 : null,
    validations: (value) {
      if (value == null) {
        return 'Please rate your overall satisfaction';
      }
      return null;
    },
  );

  final additionalComments = AppFormField<String>(
    name: 'additionalComments',
    initialValue: kDebugMode ? 'Great package! Looking forward to more features.' : '',
    // Optional field
  );

  final allowFollowUp = AppFormField<bool>(
    name: 'allowFollowUp',
    initialValue: false,
  );

  final subscribeUpdates = AppFormField<bool>(
    name: 'subscribeUpdates',
    initialValue: true,
  );

  /// Survey metadata
  DateTime? _startTime;
  DateTime? _stepStartTime;
  final Map<int, Duration> _stepDurations = {};
  int _totalQuestions = 0;

  SurveyForm() {
    // Register all fields
    setFields([
      // Step 1
      participantName,
      participantEmail,
      ageGroup,
      occupation,
      // Step 2
      primaryDevice,
      dailyScreenTime,
      favoritePlatforms,
      codingExperience,
      // Step 3
      hasUsedAppForms,
      appFormsRating,
      appFormsFeatures,
      improvementSuggestions,
      // Step 4
      preferredArchitecture,
      stateManagement,
      testingImportance,
      developmentChallenges,
      // Step 5
      overallSatisfaction,
      additionalComments,
      allowFollowUp,
      subscribeUpdates,
    ]);

    _totalQuestions = 22; // Total number of questions in the survey

    if (kDebugMode) {
      log('SurveyForm initialized with $_totalQuestions questions across $_totalSteps steps');
    }
  }

  @override
  Future<void> onInit() async {
    if (kDebugMode) {
      log('SurveyForm initializing...');
    }

    _startTime = DateTime.now();
    _stepStartTime = DateTime.now();

    // Load any saved progress
    await _loadSavedProgress();

    if (kDebugMode) {
      log('SurveyForm initialization complete');
      _logSurveyMetrics();
    }
  }

  /// Loads saved survey progress
  Future<void> _loadSavedProgress() async {
    try {
      // Simulate loading from local storage
      await Future.delayed(const Duration(milliseconds: 100));

      if (kDebugMode) {
        // Simulate partially completed survey
        _currentStep = 1;
        _stepCompleted[0] = true;
        
        // Pre-fill some responses
        _responses['participantName'] = participantName.initialValue;
        _responses['participantEmail'] = participantEmail.initialValue;
        _responses['ageGroup'] = ageGroup.initialValue;
        
        log('Loaded saved survey progress: Step $_currentStep');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error loading saved progress: $e');
      }
    }
  }

  /// Gets the current step number (0-based)
  int get currentStep => _currentStep;

  /// Gets the total number of steps
  int get totalSteps => _totalSteps;

  /// Gets step completion status
  List<bool> get stepCompletionStatus => List.from(_stepCompleted);

  /// Gets overall completion percentage
  double get completionPercentage {
    final completedSteps = _stepCompleted.where((completed) => completed).length;
    return completedSteps / _totalSteps;
  }

  /// Gets current step completion percentage
  double get currentStepCompletion {
    final stepFields = _getFieldsForStep(_currentStep);
    if (stepFields.isEmpty) return 1.0;

    final values = getValues();
    if (values == null) return 0.0;

    int completedFields = 0;
    for (final field in stepFields) {
      final value = values[field.name];
      if (value != null && _isFieldValueComplete(value)) {
        completedFields++;
      }
    }

    return completedFields / stepFields.length;
  }

  /// Gets fields for a specific step
  List<AppFormField> _getFieldsForStep(int step) {
    switch (step) {
      case 0:
        return [participantName, participantEmail, ageGroup, occupation];
      case 1:
        return [primaryDevice, dailyScreenTime, favoritePlatforms, codingExperience];
      case 2:
        // Conditional step based on hasUsedAppForms
        final baseFields = <AppFormField>[hasUsedAppForms];
        if (hasUsedAppForms.value == true) {
          baseFields.addAll([appFormsRating, appFormsFeatures, improvementSuggestions]);
        }
        return baseFields;
      case 3:
        return [preferredArchitecture, stateManagement, testingImportance, developmentChallenges];
      case 4:
        return [overallSatisfaction, additionalComments, allowFollowUp, subscribeUpdates];
      default:
        return [];
    }
  }

  /// Checks if a field value is considered complete
  bool _isFieldValueComplete(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is bool) return true; // Booleans are always complete
    if (value is num) return true; // Numbers are always complete
    return true;
  }

  /// Validates the current step
  bool validateCurrentStep() {
    final stepFields = _getFieldsForStep(_currentStep);
    bool isValid = true;
    final errors = <String, String>{};

    for (final field in stepFields) {
      // Handle field validation
      final validation = field.validations;
      if (validation != null) {
        final error = validation(field.value);
        if (error != null) {
          errors[field.name] = error;
          isValid = false;
        }
      }
      
      // Handle conditional validations for step 2
      if (_currentStep == 2) {
        final hasUsed = hasUsedAppForms.value;
        if (hasUsed == true) {
          if (field.name == appFormsRating.name && field.value == null) {
            errors[field.name] = 'Please rate your experience';
            isValid = false;
          }
          if (field.name == appFormsFeatures.name && 
              (field.value == null || (field.value as List<String>).isEmpty)) {
            errors[field.name] = 'Please select at least one feature you appreciate';
            isValid = false;
          }
        }
      }
    }

    if (!isValid) {
      setValidationErrors(errors);
    } else {
      setValidationErrors(null);
    }

    return isValid;
  }

  /// Moves to the next step
  bool nextStep() {
    if (!validateCurrentStep()) {
      return false;
    }

    // Record step completion time
    if (_stepStartTime != null) {
      _stepDurations[_currentStep] = DateTime.now().difference(_stepStartTime!);
    }

    // Mark current step as completed
    _stepCompleted[_currentStep] = true;

    // Save responses for current step
    _saveCurrentStepResponses();

    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      _stepStartTime = DateTime.now();
      
      if (kDebugMode) {
        log('Advanced to step $_currentStep');
      }
      
      return true;
    }

    return false;
  }

  /// Moves to the previous step
  bool previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _stepStartTime = DateTime.now();
      
      if (kDebugMode) {
        log('Returned to step $_currentStep');
      }
      
      return true;
    }
    return false;
  }

  /// Jumps to a specific step (if accessible)
  bool goToStep(int step) {
    if (step < 0 || step >= _totalSteps) {
      return false;
    }

    // Can only go to completed steps or the next step
    if (step <= _currentStep || (step == _currentStep + 1 && _stepCompleted[_currentStep])) {
      _currentStep = step;
      _stepStartTime = DateTime.now();
      
      if (kDebugMode) {
        log('Jumped to step $_currentStep');
      }
      
      return true;
    }

    return false;
  }

  /// Saves current step responses
  void _saveCurrentStepResponses() {
    final values = getValues();
    if (values != null) {
      final stepFields = _getFieldsForStep(_currentStep);
      for (final field in stepFields) {
        final value = values[field.name];
        if (value != null) {
          _responses[field.name] = value;
        }
      }
    }

    if (kDebugMode) {
      log('Saved responses for step $_currentStep: ${_responses.keys.length} total responses');
    }
  }

  /// Gets step title
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Technology Usage';
      case 2:
        return 'App Forms Experience';
      case 3:
        return 'Development Preferences';
      case 4:
        return 'Feedback & Completion';
      default:
        return 'Step ${step + 1}';
    }
  }

  /// Gets step description
  String getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Tell us a bit about yourself';
      case 1:
        return 'Share your technology and development habits';
      case 2:
        return 'Let us know about your experience with app_forms';
      case 3:
        return 'Share your development preferences and challenges';
      case 4:
        return 'Final thoughts and feedback';
      default:
        return 'Survey step ${step + 1}';
    }
  }

  /// Gets estimated time for step
  String getStepEstimatedTime(int step) {
    switch (step) {
      case 0:
        return '2 min';
      case 1:
        return '3 min';
      case 2:
        return '2-4 min'; // Conditional
      case 3:
        return '3 min';
      case 4:
        return '2 min';
      default:
        return '2-3 min';
    }
  }

  /// Checks if step should be skipped based on previous answers
  bool shouldSkipStep(int step) {
    // Skip app_forms experience questions if user hasn't used it
    if (step == 2 && hasUsedAppForms.value == false) {
      return false; // Don't skip, but show minimal questions
    }
    return false;
  }

  /// Gets conditional questions count for current step
  int getConditionalQuestionsCount() {
    if (_currentStep == 2 && hasUsedAppForms.value == true) {
      return 3; // Additional questions for experienced users
    }
    return 0;
  }

  /// Analyzes survey responses
  Map<String, dynamic> analyzeSurveyData() {
    final analysis = <String, dynamic>{};
    
    // Basic demographics
    analysis['demographics'] = {
      'ageGroup': _responses['ageGroup'],
      'occupation': _responses['occupation'],
    };
    
    // Technology usage patterns
    analysis['technologyUsage'] = {
      'primaryDevice': _responses['primaryDevice'],
      'screenTime': _responses['dailyScreenTime'],
      'platforms': _responses['favoritePlatforms'],
      'experience': _responses['codingExperience'],
    };
    
    // App forms feedback
    if (_responses['hasUsedAppForms'] == true) {
      analysis['appFormsFeedback'] = {
        'rating': _responses['appFormsRating'],
        'favoriteFeatures': _responses['appFormsFeatures'],
        'suggestions': _responses['improvementSuggestions'],
      };
    }
    
    // Development preferences
    analysis['developmentPreferences'] = {
      'architecture': _responses['preferredArchitecture'],
      'stateManagement': _responses['stateManagement'],
      'testingImportance': _responses['testingImportance'],
      'challenges': _responses['developmentChallenges'],
    };
    
    // Overall feedback
    analysis['overallFeedback'] = {
      'satisfaction': _responses['overallSatisfaction'],
      'comments': _responses['additionalComments'],
      'followUpAllowed': _responses['allowFollowUp'],
      'subscribeUpdates': _responses['subscribeUpdates'],
    };
    
    // Survey metadata
    analysis['metadata'] = {
      'totalTime': _startTime != null ? DateTime.now().difference(_startTime!) : null,
      'stepDurations': _stepDurations,
      'completionRate': completionPercentage,
      'totalQuestions': _totalQuestions,
      'responsesCount': _responses.length,
    };
    
    return analysis;
  }

  @override
  Future<void> onSubmit(Map<String, dynamic>? values) async {
    if (values == null) {
      setHasErrors(true);
      return;
    }

    try {
      if (kDebugMode) {
        log('Submitting survey form...');
        _logSurveyMetrics();
      }

      // Final validation
      if (!validateCurrentStep()) {
        return;
      }

      // Save final responses
      _saveCurrentStepResponses();

      // Simulate survey submission
      await _submitSurvey();

      // Mark as completed
      _stepCompleted[_currentStep] = true;
      setSuccess(true);

      if (kDebugMode) {
        log('Survey submitted successfully!');
        log('Analysis: ${analyzeSurveyData()}');
      }

    } catch (e) {
      setHasErrors(true);
      setValidationErrors({
        'general': 'Failed to submit survey. Please try again.'
      });

      if (kDebugMode) {
        log('Survey submission failed: $e');
      }
    }
  }

  /// Simulates survey submission
  Future<void> _submitSurvey() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different outcomes
    final email = _responses['participantEmail'] as String?;
    if (email?.contains('error') == true) {
      throw Exception('Simulated submission error');
    }

    // Success case
    return;
  }

  @override
  void onReset() {
    clearValidationCache();
    _currentStep = 0;
    _stepCompleted.fillRange(0, _totalSteps, false);
    _responses.clear();
    _stepDurations.clear();
    _startTime = null;
    _stepStartTime = null;

    if (kDebugMode) {
      log('Survey form reset to initial state');
    }
  }

  @override
  Future<void> onValid(Map<String, dynamic>? values) async {
    if (kDebugMode) {
      log('Current step validation passed');
    }
  }

  /// Gets survey progress summary
  Map<String, dynamic> getProgressSummary() {
    return {
      'currentStep': _currentStep + 1,
      'totalSteps': _totalSteps,
      'completionPercentage': completionPercentage,
      'currentStepCompletion': currentStepCompletion,
      'stepCompletionStatus': _stepCompleted,
      'responsesCount': _responses.length,
      'totalQuestions': _totalQuestions,
      'estimatedTimeRemaining': _getEstimatedTimeRemaining(),
    };
  }

  /// Estimates remaining time
  String _getEstimatedTimeRemaining() {
    final remainingSteps = _totalSteps - _currentStep - 1;
    if (remainingSteps <= 0) return '0 min';
    
    final avgTimePerStep = 2.5; // minutes
    final estimatedMinutes = (remainingSteps * avgTimePerStep).round();
    
    if (estimatedMinutes < 1) return '< 1 min';
    return '$estimatedMinutes min';
  }

  /// Logs survey metrics for debugging
  void _logSurveyMetrics() {
    if (!kDebugMode) return;

    final metrics = getPerformanceMetrics();
    final progress = getProgressSummary();
    
    log('=== Survey Form Metrics ===');
    metrics.forEach((key, value) {
      log('$key: $value');
    });
    log('=== Progress Summary ===');
    progress.forEach((key, value) {
      log('$key: $value');
    });
    log('========================');
  }
}