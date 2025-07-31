import 'package:app_forms/app_forms.dart';
import 'package:example/forms/login_form.dart';
import 'package:example/forms/registration_form.dart';
import 'package:example/forms/profile_settings_form.dart';
import 'package:example/forms/survey_form.dart';
import 'package:example/home_page.dart';
import 'package:example/login_page.dart';
import 'package:example/registration_page.dart';
import 'package:example/profile_settings_page.dart';
import 'package:example/survey_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Advanced example demonstrating app_forms performance features.
/// 
/// This example showcases:
/// - Performance-optimized form initialization
/// - Advanced form patterns and validations
/// - Conditional UI updates
/// - Performance monitoring and debugging
/// - Error handling and state management
void main() {
  // Configure debug settings
  if (kDebugMode) {
    debugPrint('=== App Forms Advanced Example ===');
    debugPrint('Initializing forms with performance optimizations...');
  }
  
  // Inject forms with performance optimization
  _initializeForms();
  
  runApp(const AdvancedFormsDemoApp());
}

/// Initializes forms with performance best practices
void _initializeForms() {
  final forms = [
    LoginForm(),
    RegistrationForm(),
    ProfileSettingsForm(),
    SurveyForm(),
    // Add more forms here as needed
  ];
  
  AppForms.injectForms(forms);
  
  if (kDebugMode) {
    debugPrint('Injected ${forms.length} forms into global registry');
  }
}

/// Advanced Forms Demo App showcasing performance optimizations.
class AdvancedFormsDemoApp extends StatelessWidget {
  const AdvancedFormsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Forms - Advanced Demo',
      debugShowCheckedModeBanner: kDebugMode,
      
      // Modern Material 3 theme with performance considerations
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      
      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          // Fix text scaling for consistent UI
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
      
      home: const HomePage(),
      
      // Error handling for production apps
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: _onUnknownRoute,
    );
  }
  
  /// Creates a light theme optimized for forms
  ThemeData _buildLightTheme() {
    const primaryColor = Colors.deepPurple;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // Form-specific theme customizations
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      cardTheme: const CardThemeData(
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),
    );
  }
  
  /// Creates a dark theme optimized for forms
  ThemeData _buildDarkTheme() {
    const primaryColor = Colors.deepPurple;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      
      // Dark theme form customizations
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  /// Handles route generation for navigation
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (context) => const RegistrationPage(),
          settings: settings,
        );
      case '/profile-settings':
        return MaterialPageRoute(
          builder: (context) => const ProfileSettingsPage(),
          settings: settings,
        );
      case '/survey':
        return MaterialPageRoute(
          builder: (context) => const SurveyPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }
  
  /// Handles unknown routes
  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Page "${settings.name}" not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
