import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/infrastructure/services/bible_service.dart';
import 'package:yes_no_app/data/models/bible_verse_model.dart';
import 'package:yes_no_app/domain/repositories/bible_repository.dart';

// Mock do BibleRepository
class MockBibleRepository implements IBibleRepository {
  final List<BibleVerseModel> _mockVerses = [
    BibleVerseModel(
      livro: "João",
      capitulo: 3,
      versiculo: 16,
      texto: "Porque Deus amou o mundo de tal maneira...",
    ),
    BibleVerseModel(
      livro: "Salmos",
      capitulo: 23,
      versiculo: 1,
      texto: "O Senhor é meu pastor e nada me faltará",
    ),
    BibleVerseModel(
      livro: "Mateus",
      capitulo: 5,
      versiculo: 3,
      texto: "Bem-aventurados os pobres de espírito",
    ),
  ];

  @override
  Future<List<BibleVerseModel>> getAllVerses() async {
    return _mockVerses;
  }
}

void main() {
  group('BibleService Tests', () {
    late BibleService service;
    late MockBibleRepository mockRepository;

    setUp(() async {
      mockRepository = MockBibleRepository();
      service = BibleService(mockRepository);
      await service.initialize();
    });

    test('should initialize service correctly', () {
      expect(service.versiculos.length, 3);
    });

    test('should search verses correctly - exact match', () {
      final results = service.buscar('Deus');
      expect(results.length, 1);
      expect(results[0].texto.contains('Deus'), true);
    });

    test('should search verses correctly - ignore case', () {
      final results = service.buscar('deus');
      expect(results.length, 1);
      expect(results[0].texto.contains('Deus'), true);
    });

    test('should search verses correctly - ignore diacritics', () {
      final results = service.buscar('Bem-aventurados');
      expect(results.length, 1);
      expect(results[0].texto.contains('Bem-aventurados'), true);
    });

    test('should search verses by book name', () {
      final results = service.buscar('João');
      expect(results.length, 1);
      expect(results[0].livro, 'João');
    });

    test('should return empty list for empty query', () {
      final results = service.buscar('');
      expect(results, isEmpty);
    });

    test('should return empty list for query with only spaces', () {
      final results = service.buscar('   ');
      expect(results, isEmpty);
    });

    test('should handle multiple words in query', () {
      final results = service.buscar('Senhor pastor');
      expect(results.length, 1);
      expect(results[0].texto.contains('Senhor'), true);
      expect(results[0].texto.contains('pastor'), true);
    });
  });
}