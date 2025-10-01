import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

void main() {
  group('Message', () {
    test('should create a Message with required fields', () {
      final message = Message(
        text: 'Hola',
        fromWho: FromWho.userChatMessage,
      );
      expect(message.text, 'Hola');
      expect(message.fromWho, FromWho.userChatMessage);
      expect(message.imageUrl, isNull);
    });

    test('should create a Message with imageUrl', () {
      final message = Message(
        text: 'Imagen',
        imageUrl: 'http://test.com/image.png',
        fromWho: FromWho.systemChatMessage,
      );
      expect(message.imageUrl, 'http://test.com/image.png');
      expect(message.fromWho, FromWho.systemChatMessage);
    });

    test('should support all FromWho enum values', () {
      expect(FromWho.values.length, 3);
      expect(FromWho.userChatMessage.toString(), contains('userChatMessage'));
      expect(FromWho.systemChatMessage.toString(), contains('systemChatMessage'));
      expect(FromWho.verseMessage.toString(), contains('verseMessage'));
    });

    test('should compare Message objects by reference', () {
      final m1 = Message(text: 'A', fromWho: FromWho.verseMessage);
      final m2 = Message(text: 'A', fromWho: FromWho.verseMessage);
      expect(m1 == m2, isFalse); // No override of ==
    });
  });
}
