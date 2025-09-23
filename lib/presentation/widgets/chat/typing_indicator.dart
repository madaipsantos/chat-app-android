import 'package:flutter/material.dart';

/// Um widget que exibe um indicador de digitação.
/// 
/// Pode ser personalizado com diferentes estilos e textos.
class TypingIndicator extends StatefulWidget {
  /// Texto a ser exibido no indicador de digitação.
  final String text;
  
  /// Estilo do texto do indicador.
  final TextStyle? textStyle;
  
  /// Padding ao redor do indicador de digitação.
  final EdgeInsetsGeometry padding;
  
  /// Define se deve mostrar os pontos animados.
  final bool showDots;

  const TypingIndicator({
    super.key,
    this.text = 'Escribiendo',
    this.textStyle,
    this.padding = const EdgeInsets.only(left: 20, bottom: 8),
    this.showDots = true,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _dots = ['', '.', '..', '...'];
  int _currentDotIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentDotIndex = (_currentDotIndex + 1) % _dots.length;
        });
        _controller.forward(from: 0.0);
      }
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 12,
      fontStyle: FontStyle.italic,
    );
    
    return Padding(
      padding: widget.padding,
      child: Text(
        widget.showDots 
            ? '${widget.text}${_dots[_currentDotIndex]}' 
            : widget.text,
        style: widget.textStyle ?? defaultStyle,
      ),
    );
  }
}
