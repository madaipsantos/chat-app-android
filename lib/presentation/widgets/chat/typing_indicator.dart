import 'package:flutter/material.dart';

/// A widget that displays a typing indicator.
/// Can be customized with different styles and texts.
class TypingIndicator extends StatefulWidget {
  /// Text to display in the typing indicator.
  final String text;

  /// Text style for the indicator.
  final TextStyle? textStyle;

  /// Padding around the typing indicator.
  final EdgeInsetsGeometry padding;

  /// Whether to show animated dots.
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