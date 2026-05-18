import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/error_handler.dart';
import 'data/local/database_helper.dart';

void main() async {
  final binding =WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  FlutterError.onError = (details) {
    ErrorHandler.handle(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.handle(error, stack);
    return true;
  };

  await DatabaseHelper.instance.initialize();

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      child: const FitForgeApp(),
    ),
  );
}

class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
      ProviderBase provider,
      Object error,
      StackTrace stackTrace,
      ProviderContainer container,
      ) {
    ErrorHandler.handle(error, stackTrace);
  }
}

class FitForgeApp extends ConsumerWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    FlutterNativeSplash.remove();
    return MaterialApp.router(
      title: 'FitForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}