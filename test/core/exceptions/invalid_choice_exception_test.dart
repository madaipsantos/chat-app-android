import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/core/exceptions/invalid_choice_exception.dart';

void main() {
  group('InvalidChoiceException', () {
    test('default message', () {
      final exception = InvalidChoiceException();
      expect(exception.message, 'Opción inválida');
      expect(exception.toString(), 'InvalidChoiceException: Opción inválida');
    });

    test('custom message', () {
      final exception = InvalidChoiceException('No es una opción válida');
      expect(exception.message, 'No es una opción válida');
      expect(exception.toString(), 'InvalidChoiceException: No es una opción válida');
    });
  });
}
