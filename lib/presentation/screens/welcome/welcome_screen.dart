import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asistente_biblico/presentation/providers/chat_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _onEntrarPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<ChatProvider>().setUserName(_nomeController.text.trim());
      Navigator.pushReplacementNamed(context, '/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary,
              colors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 100,
                    color: colors.onPrimary,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    ChatMessagesConstants.welcomeTitle ,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      hintText: ChatMessagesConstants.hintEnterName,
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: colors.primary,
                      ),
                      hintStyle: TextStyle(
                        color: colors.primary.withOpacity(0.7),
                      ),
                    ),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return ChatMessagesConstants.errorEnterName;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onEntrarPressed(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onEntrarPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Empezar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}