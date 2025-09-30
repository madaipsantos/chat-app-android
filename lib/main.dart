import 'package:flutter/material.dart';
import 'package:asistente_biblico/config/theme/app_theme.dart';
import 'package:asistente_biblico/infrastructure/services/bible_service.dart';
import 'package:asistente_biblico/presentation/providers/chat_provider.dart';
import 'package:asistente_biblico/presentation/screens/welcome/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BibleService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Asistente Bíblico',
        debugShowCheckedModeBanner: false,
        theme: AppTheme(selectedColor: 2).theme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
        }
      ),
    );
  }
}
