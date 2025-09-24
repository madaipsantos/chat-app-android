import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:yes_no_app/infrastructure/repositories/bible_repository.dart';
import 'package:yes_no_app/infrastructure/models/bible_verse_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BibleRepository Tests', () {
    late BibleRepository repository;
    final validJsonResponse = '''
      [
        {
          "livro": "João",
          "capitulo": 3,
          "versiculo": 16,
          "texto": "Porque Deus amou o mundo de tal maneira..."
        },
        {
          "livro": "Salmos",
          "capitulo": 23,
          "versiculo": 1,
          "texto": "O Senhor é meu pastor..."
        }
      ]
    ''';

    setUp(() {
      repository = BibleRepository();
    });

    test('should get all verses correctly', () async {
      // Configure mock para retornar JSON válido
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        return ByteData.view(Uint8List.fromList(utf8.encode(validJsonResponse)).buffer);
      });

      final verses = await repository.getAllVerses();

      expect(verses, isA<List<BibleVerseModel>>());
      expect(verses.length, 2);
      
      expect(verses[0].livro, 'João');
      expect(verses[0].capitulo, 3);
      expect(verses[0].versiculo, 16);
      expect(verses[0].texto, 'Porque Deus amou o mundo de tal maneira...');

      expect(verses[1].livro, 'Salmos');
      expect(verses[1].capitulo, 23);
      expect(verses[1].versiculo, 1);
      expect(verses[1].texto, 'O Senhor é meu pastor...');
    });

    test('should throw exception when json is invalid', () async {
      // Configure mock para retornar JSON inválido
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        return ByteData.view(Uint8List.fromList(utf8.encode('{ invalid json }')).buffer);
      });

      try {
        await repository.getAllVerses();
        fail('Should throw an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });
  });
}