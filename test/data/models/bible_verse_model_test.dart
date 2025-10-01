import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/data/models/bible_verse_model.dart';
import 'package:asistente_biblico/core/exceptions/data_format_exception.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

void main() {
  group('BibleVerseModel', () {
    final json = {
      'livro': 'João',
      'capitulo': 3,
      'versiculo': 16,
      'texto': 'Porque Deus amou o mundo...',
    };

    test('fromJson should create a valid model', () {
      final model = BibleVerseModel.fromJson(json);
      expect(model.livro, 'João');
      expect(model.capitulo, 3);
      expect(model.versiculo, 16);
      expect(model.texto, 'Porque Deus amou o mundo...');
    });

    test('toJson should return a valid map', () {
      final model = BibleVerseModel.fromJson(json);
      expect(model.toJson(), json);
    });

    test('reference should be formatted correctly', () {
      final model = BibleVerseModel.fromJson(json);
      expect(model.reference, 'João 3:16');
    });

    test('toMessageEntity should return a valid Message', () {
      final model = BibleVerseModel.fromJson(json);
      final message = model.toMessageEntity();
      expect(message.text, 'João 3:16 - Porque Deus amou o mundo...');
      expect(message.fromWho, FromWho.systemChatMessage);
    });

    test('fromJson should throw DataFormatException on missing fields', () {
      final invalidJson = {'livro': 'João'};
      expect(() => BibleVerseModel.fromJson(invalidJson), throwsA(isA<DataFormatException>()));
    });

    test('fromJson should throw DataFormatException on wrong types', () {
      final invalidJson = {
        'livro': 123,
        'capitulo': '3',
        'versiculo': '16',
        'texto': 456,
      };
      expect(() => BibleVerseModel.fromJson(invalidJson), throwsA(isA<DataFormatException>()));
    });
  });
}
