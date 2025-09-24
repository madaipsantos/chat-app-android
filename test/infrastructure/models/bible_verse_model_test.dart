import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/bible_verse_model.dart';

void main() {
  group('BibleVerseModel Tests', () {
    final testJson = {
      "livro": "João",
      "capitulo": 3,
      "versiculo": 16,
      "texto": "Porque Deus amou o mundo de tal maneira...",
    };

    test('should create BibleVerseModel correctly', () {
      final verse = BibleVerseModel(
        livro: "João",
        capitulo: 3,
        versiculo: 16,
        texto: "Porque Deus amou o mundo de tal maneira...",
      );

      expect(verse.livro, "João");
      expect(verse.capitulo, 3);
      expect(verse.versiculo, 16);
      expect(verse.texto, "Porque Deus amou o mundo de tal maneira...");
    });

    test('should create BibleVerseModel from JSON correctly', () {
      final verse = BibleVerseModel.fromJson(testJson);

      expect(verse.livro, "João");
      expect(verse.capitulo, 3);
      expect(verse.versiculo, 16);
      expect(verse.texto, "Porque Deus amou o mundo de tal maneira...");
    });

    test('should convert BibleVerseModel to JSON correctly', () {
      final verse = BibleVerseModel(
        livro: "João",
        capitulo: 3,
        versiculo: 16,
        texto: "Porque Deus amou o mundo de tal maneira...",
      );

      final json = verse.toJson();

      expect(json["livro"], "João");
      expect(json["capitulo"], 3);
      expect(json["versiculo"], 16);
      expect(json["texto"], "Porque Deus amou o mundo de tal maneira...");
    });

    test('should generate reference correctly', () {
      final verse = BibleVerseModel(
        livro: "João",
        capitulo: 3,
        versiculo: 16,
        texto: "Porque Deus amou o mundo de tal maneira...",
      );

      expect(verse.reference, "João 3:16");
    });

    test('should convert to Message entity correctly', () {
      final verse = BibleVerseModel(
        livro: "João",
        capitulo: 3,
        versiculo: 16,
        texto: "Porque Deus amou o mundo de tal maneira...",
      );

      final message = verse.toMessageEntity();

      expect(message.text, "João 3:16 - Porque Deus amou o mundo de tal maneira...");
      expect(message.fromWho, FromWho.systemChatMessage);
      expect(message.imageUrl, isNull);
    });

    test('should implement Equatable correctly', () {
      final verse1 = BibleVerseModel(
        livro: "João",
        capitulo: 3,
        versiculo: 16,
        texto: "Porque Deus amou o mundo de tal maneira...",
      );

      final verse2 = BibleVerseModel(
        livro: "João",
        capitulo: 3,
        versiculo: 16,
        texto: "Porque Deus amou o mundo de tal maneira...",
      );

      expect(verse1, equals(verse2));
    });
  });
}