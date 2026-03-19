import 'package:flutter/material.dart';
import 'package:cyberops/screens/login_screen.dart';
import 'package:cyberops/screens/dashboard_screen.dart';
import 'package:cyberops/screens/achievements_screen.dart';
import 'package:cyberops/screens/scenario_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/dashboard':
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] ?? -1;
        final isGuest = args?['isGuest'] ?? false;
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(userId: userId, isGuest: isGuest),
        );

      case '/achievements':
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] ?? -1;
        return MaterialPageRoute(
          builder: (_) => AchievementsScreen(userId: userId),
        );

      case '/scenarios':
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] ?? -1;
        return MaterialPageRoute(
          builder: (_) => ScenarioScreen(userId: userId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 — Page not found')),
          ),
        );
    }
  }
}
