import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class that delays the execution of a function until after
/// a specified amount of time has passed since the last time it was invoked.
///
/// This is particularly useful for optimizing performance when dealing with
/// frequently triggered events like text input changes, API calls, or
/// validation operations.
///
/// ## How it works:
/// 1. When [run] is called, any existing timer is cancelled
/// 2. A new timer is started with the specified delay
/// 3. If [run] is called again before the timer expires, the process repeats
/// 4. The action is only executed when the timer completes without interruption
///
/// ## Usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
///
/// // In a text field's onChanged callback:
/// onChanged: (value) {
///   debouncer.run(() {
///     // This will only run 500ms after the user stops typing
///     performSearch(value);
///   });
/// },
/// ```
///
/// ## Common Use Cases:
/// - Search input fields (avoid API calls on every keystroke)
/// - Form validation (reduce validation frequency)
/// - Auto-save functionality (prevent excessive save operations)
/// - Resize/scroll event handling (improve performance)
///
/// ## Performance Benefits:
/// - Reduces unnecessary function calls
/// - Prevents API spam during rapid user input
/// - Improves UI responsiveness
/// - Reduces resource consumption
class Debouncer {
  /// The delay in milliseconds before executing the debounced action.
  ///
  /// This value determines how long to wait after the last [run] call
  /// before actually executing the provided action.
  final int milliseconds;
  /// Internal timer that manages the delay mechanism.
  ///
  /// This timer is cancelled and recreated on each [run] call,
  /// ensuring only the most recent action is executed.
  Timer? _timer;
  /// Creates a new [Debouncer] with the specified delay.
  ///
  /// ## Parameters:
  /// - [milliseconds]: The delay in milliseconds before executing actions
  ///
  /// ## Example:
  /// ```dart
  /// // Create a debouncer with 250ms delay
  /// final debouncer = Debouncer(milliseconds: 250);
  ///
  /// // Create a debouncer with 1 second delay
  /// final longDebouncer = Debouncer(milliseconds: 1000);
  /// ```
  ///
  /// ## Recommended Delays:
  /// - **Search/Filter**: 300-500ms
  /// - **Form Validation**: 250-400ms  
  /// - **Auto-save**: 1000-2000ms
  /// - **API Calls**: 500-800ms
  Debouncer({required this.milliseconds});
  /// Schedules an action to run after the specified delay.
  ///
  /// If this method is called again before the delay expires,
  /// the previous action is cancelled and a new delay begins.
  /// Only the most recent action will be executed.
  ///
  /// ## Parameters:
  /// - [action]: The function to execute after the delay
  ///
  /// ## Example:
  /// ```dart
  /// final debouncer = Debouncer(milliseconds: 300);
  ///
  /// void onSearchChanged(String query) {
  ///   debouncer.run(() {
  ///     // This will only execute 300ms after the user stops typing
  ///     searchAPI(query);
  ///   });
  /// }
  ///
  /// // Multiple rapid calls:
  /// onSearchChanged('a');    // Cancelled
  /// onSearchChanged('ap');   // Cancelled  
  /// onSearchChanged('app');  // Executes after 300ms
  /// ```
  ///
  /// ## Behavior:
  /// - Cancels any pending action from previous calls
  /// - Starts a new timer with the configured delay
  /// - Executes the action when the timer completes
  /// - Thread-safe and handles rapid successive calls gracefully
  void run(VoidCallback action) {
    // Cancel any existing timer to prevent multiple executions
    cancel();
    
    // Start a new timer with the provided action
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  /// Cancels any pending debounced action.
  ///
  /// This method stops the current timer and prevents the pending
  /// action from executing. Subsequent calls to [run] will start
  /// a fresh timer.
  ///
  /// ## Example:
  /// ```dart
  /// final debouncer = Debouncer(milliseconds: 500);
  ///
  /// // Schedule an action
  /// debouncer.run(() => print('This will not execute'));
  ///
  /// // Cancel before it executes
  /// debouncer.cancel();
  /// ```
  ///
  /// ## Use Cases:
  /// - Widget disposal cleanup
  /// - Cancelling search requests when user navigates away
  /// - Stopping auto-save when manual save is triggered
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Whether there is a pending action scheduled to execute.
  ///
  /// Returns `true` if an action is currently waiting to be executed
  /// after the debounce delay, `false` otherwise.
  ///
  /// ## Example:
  /// ```dart
  /// final debouncer = Debouncer(milliseconds: 300);
  ///
  /// debouncer.run(() => print('Hello'));
  /// print(debouncer.isActive); // true
  ///
  /// // Wait 300ms...
  /// print(debouncer.isActive); // false (action executed)
  /// ```
  bool get isActive => _timer?.isActive ?? false;
  
  /// Disposes the debouncer and cancels any pending actions.
  ///
  /// This method should be called when the debouncer is no longer needed
  /// to prevent memory leaks and ensure any pending timers are properly
  /// cancelled.
  ///
  /// ## Example:
  /// ```dart
  /// class _MyWidgetState extends State<MyWidget> {
  ///   final _debouncer = Debouncer(milliseconds: 300);
  ///
  ///   @override
  ///   void dispose() {
  ///     _debouncer.dispose();
  ///     super.dispose();
  ///   }
  /// }
  /// ```
  void dispose() {
    cancel();
  }
}
