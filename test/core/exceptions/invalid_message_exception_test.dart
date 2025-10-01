import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/core/exceptions/invalid_message_exception.dart';

void main() {
  group('InvalidMessageException', () {
    test('default message', () {
      final exception = InvalidMessageException();
      expect(exception.message, 'Mensaje inválido');
      expect(exception.toString(), 'InvalidMessageException: Mensaje inválido');
    });

    test('custom message', () {
      final exception = InvalidMessageException('Mensaje vacío');
      expect(exception.message, 'Mensaje vacío');
      expect(exception.toString(), 'InvalidMessageException: Mensaje vacío');
    });
  });
}
