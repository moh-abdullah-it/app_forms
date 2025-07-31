import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Home page showcasing different form examples and performance features.
/// 
/// This page demonstrates:
/// - Navigation to different form examples
/// - Performance comparison data
/// - Feature showcase
/// - Best practices guide
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Forms - Advanced Demo'),
        backgroundColor: theme.colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Section
                  _buildHeroSection(theme),
                  const SizedBox(height: 32),
                  
                  // Performance Highlights
                  _buildPerformanceSection(theme),
                  const SizedBox(height: 32),
                  
                  // Form Examples
                  _buildFormExamplesSection(context, theme),
                  const SizedBox(height: 32),
                  
                  // Features Section
                  _buildFeaturesSection(theme),
                  const SizedBox(height: 32),
                  
                  // Footer
                  _buildFooter(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeroSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.rocket_launch,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'App Forms Advanced Demo',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Experience high-performance Flutter forms with smart caching, '
                'conditional updates, and advanced validation patterns.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance Highlights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '60-80%',
                    'Faster Validation',
                    'Smart caching reduces redundant validations',
                    Icons.cached,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    '60fps',
                    'Smooth UI',
                    'Dual debouncing for optimal performance',
                    Icons.timeline,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '50-70%',
                    'Fewer Rebuilds',
                    'Conditional updates prevent unnecessary renders',
                    Icons.update,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Auto',
                    'Memory Management',
                    'Automatic cache cleanup prevents leaks',
                    Icons.memory,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricCard(String value, String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormExamplesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.list_alt,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Form Examples',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Login Form Example
        _buildFormCard(
          context,
          'Advanced Login Form',
          'Demonstrates smart validation caching, rate limiting, '
          'and conditional UI updates with performance monitoring.',
          Icons.login,
          Colors.blue,
          () => Navigator.of(context).pushNamed('/login'),
          [
            'Smart validation caching',
            'Rate limiting & security',
            'Conditional rebuilds',
            'Performance metrics',
          ],
        ),
        const SizedBox(height: 16),
        
        // Registration Form Example
        _buildFormCard(
          context,
          'Complex Registration Form',
          'Showcases multi-field validation, password strength indicators, '
          'async validation, and comprehensive error handling.',
          Icons.person_add,
          Colors.green,
          () => Navigator.of(context).pushNamed('/register'),
          [
            'Multi-field validation',
            'Password strength tracking',
            'Async username checking',
            'Progress indicators',
          ],
        ),
        const SizedBox(height: 16),
        
        // Profile Settings Form Example  
        _buildFormCard(
          context,
          'Profile Settings Form',
          'Dynamic form fields, real-time updates, preferences management, '
          'and auto-save functionality with advanced validation patterns.',
          Icons.settings,
          Colors.orange,
          () => Navigator.of(context).pushNamed('/profile-settings'),
          [
            'Dynamic field generation',
            'Real-time preferences',
            'Auto-save functionality',
            'Data export/import',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Multi-Step Survey Form Example
        _buildFormCard(
          context,
          'Multi-Step Survey Form',
          'Wizard-style form with step validation, progress tracking, '
          'conditional questions, and comprehensive data aggregation.',
          Icons.quiz,
          Colors.purple,
          () => Navigator.of(context).pushNamed('/survey'),
          [
            'Step-by-step validation',
            'Progress persistence',
            'Conditional questions',
            'Data aggregation',
          ],
        ),
      ],
    );
  }
  
  Widget _buildFormCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    List<String> features,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildComingSoonCard(
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> features,
  ) {
    return Card(
      elevation: 2,
      child: Opacity(
        opacity: 0.7,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.grey, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'COMING SOON',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeaturesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Key Features',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildFeatureCard(
              'Smart Caching',
              'Validation results are cached to prevent redundant operations',
              Icons.cached,
              Colors.blue,
            ),
            _buildFeatureCard(
              'Conditional Updates',
              'UI rebuilds only when necessary using updateWhen callbacks',
              Icons.update,
              Colors.green,
            ),
            _buildFeatureCard(
              'Memory Management',
              'Automatic cache cleanup and resource disposal',
              Icons.memory,
              Colors.orange,
            ),
            _buildFeatureCard(
              'Performance Metrics',
              'Built-in monitoring and debugging capabilities',
              Icons.analytics,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '🚀 App Forms Package',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'High-performance Flutter forms with clean architecture patterns',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.code,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Version 0.7.0',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.bug_report,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Debug Mode',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}