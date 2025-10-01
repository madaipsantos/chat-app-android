import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/core/exceptions/data_format_exception.dart';

void main() {
  group('DataFormatException', () {
    test('default message', () {
      final exception = DataFormatException();
      expect(exception.message, 'Error de formato de datos');
      expect(exception.toString(), 'DataFormatException: Error de formato de datos');
    });

    test('custom message', () {
      final exception = DataFormatException('Formato inválido en el campo X');
      expect(exception.message, 'Formato inválido en el campo X');
      expect(exception.toString(), 'DataFormatException: Formato inválido en el campo X');
    });
  });
}
