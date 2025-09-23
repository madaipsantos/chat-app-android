import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        'Escribiendo...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
