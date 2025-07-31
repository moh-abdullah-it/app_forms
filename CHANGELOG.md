## 0.7.1
### 🐛 Critical Bug Fixes
* **FIX**: Resolved "setState() called during build" error in AppFormListener
* **FIX**: Fixed listener registration timing to prevent build-phase state changes
* **FIX**: Moved form validation from build-time to action callbacks to prevent setState conflicts
* **IMPROVEMENT**: Added proper widget lifecycle management with dispose() method
* **IMPROVEMENT**: Enhanced type safety with AppFormListenerInterface
* **IMPROVEMENT**: Added mounted checks to prevent memory leaks and unsafe state updates

### 📋 Technical Details
* Fixed AppFormListener registration timing using WidgetsBinding.instance.addPostFrameCallback()
* Replaced build-time saveAndValidate() calls with hasErrors property checks
* Updated example apps to follow best practices for form validation timing
* Added proper cleanup in widget disposal to prevent memory leaks

## 0.7.0
### 🎉 Major Documentation & Architecture Improvements
* **BREAKING**: Enhanced professional README with comprehensive feature documentation
* **NEW**: Added CLAUDE.md for improved development workflow and AI assistance
* **FEATURE**: Complete API documentation with advanced usage examples
* **FEATURE**: Added comprehensive testing guidelines and examples
* **DOCS**: Added configuration options and customization guide
* **DOCS**: Added performance optimization details (debouncing, state management)

## 0.6.0
* **UPDATE**: Update dependencies `flutter_form_builder: ^10.1.0`
* **IMPROVEMENT**: Enhanced package stability

## 0.5.0
* **FEATURE**: Modify listener to form
* **FEATURE**: Modify listener to form field
* **IMPROVEMENT**: Modify `AppFormListener` implementation
* **ENHANCEMENT**: Better state management integration

## 0.0.1
* **INITIAL**: Initial release of app_forms package
* **FEATURE**: Basic form architecture with clean separation of concerns
* **FEATURE**: Dependency injection system for forms
* **FEATURE**: Integration with flutter_form_builder
