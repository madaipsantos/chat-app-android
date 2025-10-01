import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/core/exceptions/bible_search_exception.dart';

void main() {
  group('BibleSearchException', () {
    test('default message', () {
      final exception = BibleSearchException();
      expect(exception.message, 'Error al buscar versículos');
      expect(exception.toString(), 'BibleSearchException: Error al buscar versículos');
    });

    test('custom message', () {
      final exception = BibleSearchException('No se encontró el versículo');
      expect(exception.message, 'No se encontró el versículo');
      expect(exception.toString(), 'BibleSearchException: No se encontró el versículo');
    });
  });
}
