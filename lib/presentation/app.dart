import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:overlay_support/overlay_support.dart';

import '../core/theme/app_theme.dart';
import 'blocs/auth/auth_bloc.dart';
import 'widgets/auth/auth_wrapper.dart';

/// Main app widget
class App extends StatelessWidget {
  /// Constructor
  const App({
    required this.router,
    super.key,
  });

  /// Router for the app
  final GoRouter router;

  @override
  Widget build(BuildContext context) => OverlaySupport.global(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'BSocial',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
            ],
            // Wrap the app content with AuthWrapper
            builder: (context, child) =>
                AuthWrapper(child: child ?? const SizedBox.shrink()),
          ),
        ),
      );
}
