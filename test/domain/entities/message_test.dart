import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';

void main() {
  group('Message Entity Tests', () {
    
    test('should create a user message correctly', () {
      final message = Message(
        text: 'Hello',
        fromWho: FromWho.userChatMessage,
      );
      
      expect(message.text, equals('Hello'));
      expect(message.fromWho, equals(FromWho.userChatMessage));
      expect(message.imageUrl, isNull);
    });

    test('should create a system message with image correctly', () {
      final message = Message(
        text: 'System message',
        fromWho: FromWho.systemChatMessage,
        imageUrl: 'https://example.com/image.jpg',
      );
      
      expect(message.text, equals('System message'));
      expect(message.fromWho, equals(FromWho.systemChatMessage));
      expect(message.imageUrl, equals('https://example.com/image.jpg'));
    });

  });
}