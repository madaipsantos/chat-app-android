import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/config/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('should create AppTheme with default color', () {
      final appTheme = AppTheme();
      expect(appTheme.selectedColor, equals(0));
    });

    test('should create AppTheme with specific color index', () {
      final appTheme = AppTheme(selectedColor: 2);
      expect(appTheme.selectedColor, equals(2));
    });

    test('should throw assertion error when color index is out of range', () {
      expect(
        () => AppTheme(selectedColor: 10),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => AppTheme(selectedColor: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should create ThemeData with Material 3', () {
      final appTheme = AppTheme();
      final themeData = appTheme.theme();
      
      expect(themeData, isA<ThemeData>());
      expect(themeData.useMaterial3, isTrue);
    });
  });
}