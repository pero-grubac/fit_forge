import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handle(Object error, StackTrace? stack) {
    // Log full details in debug builds
    if (kDebugMode) {
      print('=== ERROR ===');
      print('Error: $error');
      print('Stack: $stack');
      print('=============');
    }

    // Hook for a crash reporter (Crashlytics, Sentry, ...) later
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }
}
