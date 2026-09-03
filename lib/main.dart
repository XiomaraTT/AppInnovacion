import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/riqsi_theme.dart';
import 'state/app_state.dart';

// Screens
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/onboarding/presentation/screens/initial_config_screen.dart';
import 'features/assistant/presentation/screens/main_layout.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const RiqsiApp(),
    ),
  );
}

class RiqsiApp extends StatelessWidget {
  const RiqsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riqsi Asistente Visual',
      debugShowCheckedModeBanner: false,
      theme: RiqsiTheme.darkTheme,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Switch screen according to global state flow
    switch (state.currentScreen) {
      case AppScreen.splash:
        return const SplashScreen();
      case AppScreen.onboarding:
        return const OnboardingScreen();
      case AppScreen.initialConfig:
        return const InitialConfigScreen();
      case AppScreen.mainLayout:
        return const MainLayout();
    }
  }
}
