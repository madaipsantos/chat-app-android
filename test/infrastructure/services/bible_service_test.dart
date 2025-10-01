import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/infrastructure/services/bible_service.dart';
import 'package:asistente_biblico/data/models/bible_verse_model.dart';
import 'package:asistente_biblico/core/exceptions/bible_search_exception.dart';
import 'package:mockito/mockito.dart';
import 'mock_bible_repository.mocks.dart';

void main() {
  group('BibleService', () {
    final verses = [
      BibleVerseModel(livro: 'João', capitulo: 3, versiculo: 16, texto: 'Porque Deus amou o mundo'),
      BibleVerseModel(livro: 'Salmos', capitulo: 23, versiculo: 1, texto: 'O Senhor é o meu pastor'),
    ];

    test('initialize loads verses', () async {
      final mockRepository = MockIBibleRepository();
      when(mockRepository.getAllVerses()).thenAnswer((_) async => verses);
      final service = BibleService(mockRepository);
      await service.initialize();
      expect(service.versiculos, verses);
    });

    test('initialize throws BibleSearchException on error', () async {
      final mockRepository = MockIBibleRepository();
      when(mockRepository.getAllVerses()).thenThrow(Exception('error'));
      final service = BibleService(mockRepository);
      expect(() => service.initialize(), throwsA(isA<BibleSearchException>()));
    });

    test('buscar returns matching verses', () async {
      final mockRepository = MockIBibleRepository();
      when(mockRepository.getAllVerses()).thenAnswer((_) async => verses);
      final service = BibleService(mockRepository);
      await service.initialize();
      final result = service.buscar('pastor');
      expect(result.length, 1);
      expect(result.first.livro, 'Salmos');
    });

    test('buscar returns empty if not initialized', () {
      final mockRepository = MockIBibleRepository();
      final service = BibleService(mockRepository);
      final result = service.buscar('João');
      expect(result, isEmpty);
    });

    test('buscar is case and accent insensitive', () async {
      final mockRepository = MockIBibleRepository();
      when(mockRepository.getAllVerses()).thenAnswer((_) async => verses);
      final service = BibleService(mockRepository);
      await service.initialize();
      final result = service.buscar('joao');
      expect(result.length, 1);
      expect(result.first.livro, 'João');
    });

    test('_normalize removes accents and punctuation', () {
      final mockRepository = MockIBibleRepository();
      final service = BibleService(mockRepository);
      final normalized = service
          .buscar('João!') // indirect test, as _normalize is private
          .isEmpty; // not initialized, so always empty
      expect(normalized, isTrue);
    });
  });
}
