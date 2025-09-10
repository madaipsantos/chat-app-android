import 'package:flutter/material.dart';

const Color _customColor = Color(0xff123456);

const List<Color> _colorThemes = [
  _customColor,
  Colors.yellow,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
    : assert(
        selectedColor >= 0 && selectedColor < _colorThemes.length,
        'Selected color must be between 0 and ${_colorThemes.length - 1}',
      );

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[selectedColor],
    );
  }
}
