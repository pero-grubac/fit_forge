import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handle(Object error, StackTrace? stack) {
    // U debug modu loguj sve detalje
    if (kDebugMode) {
      print('=== ERROR ===');
      print('Error: $error');
      print('Stack: $stack');
      print('=============');
    }

    // Jednog dana Crashlytics, Sentry ili nesto dzabe sto se nadje
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }
}
