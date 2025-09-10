import 'package:flutter/material.dart';

class UsuarioMessageBubble extends StatelessWidget {
  const UsuarioMessageBubble({super.key});

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Usuario--MessageBubble", style: TextStyle(color: Colors.white),),
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}