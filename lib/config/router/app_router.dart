import 'package:flutter/material.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';

/// Handles app route generation.
class AppRouter {
  /// Generates routes based on [RouteSettings].
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/chat':
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}