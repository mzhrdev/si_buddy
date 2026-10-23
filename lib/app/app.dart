import 'package:flutter/material.dart';

import '../features/onboarding/presentation/screens/splash_screen.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SI Buddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashDesignScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      );
}
