import 'package:flutter/material.dart';

/// Custom primary color for the app theme.
const Color _customColor = Color(0xff123456);

const List<Color> _colorThemes = [
  _customColor,
  Colors.yellow,
  Colors.blue,
  Colors.purple,
  Colors.orange,
  Colors.green,
];

/// Provides the application theme based on a selected color.
class AppTheme {
  /// Index of the selected color in [_colorThemes].
  final int selectedColor;

  /// Creates an [AppTheme] with the given [selectedColor].
  /// Throws an [AssertionError] if [selectedColor] is out of range.
  AppTheme({this.selectedColor = 0})
      : assert(
          selectedColor >= 0 && selectedColor < _colorThemes.length,
          'Selected color must be between 0 and ${_colorThemes.length - 1}',
        );

  /// Returns the [ThemeData] for the selected color.
  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[selectedColor],
    );
  }
}