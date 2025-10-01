import 'package:flutter/material.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case '/chat':
        return MaterialPageRoute(builder: (_) => ChatScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
