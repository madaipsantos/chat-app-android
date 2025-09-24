import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/bible_verse_model.dart';
import 'package:yes_no_app/infrastructure/services/bible_service.dart';
import 'package:yes_no_app/infrastructure/repositories/bible_repository.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

// Mock do BibleRepository
class MockBibleRepository implements IBibleRepository {
  @override
  Future<List<BibleVerseModel>> getAllVerses() async {
    return [
      BibleVerseModel(
        livro: "1 João",
        capitulo: 4,
        versiculo: 8,
        texto: "Deus é amor",
      ),
    ];
  }
}

// Mock do BibleService
class MockBibleService extends BibleService {
  MockBibleService() : super(MockBibleRepository());

  @override
  List<BibleVerseModel> buscar(String query) {
    if (query.toLowerCase() == 'amor') {
      return [
        BibleVerseModel(
          livro: "1 João",
          capitulo: 4,
          versiculo: 8,
          texto: "Deus é amor",
        ),
      ];
    }
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ChatProvider Tests', () {
    late ChatProvider provider;

    setUp(() {
      provider = ChatProvider();
    });

    test('should initialize with message list', () {
      expect(provider.messageList, isNotNull);
    });

    test('should have correct initial state', () {
      expect(provider.isWaitingChoice, isFalse);
      expect(provider.isWaitingNewSearch, isFalse);
      expect(provider.searchResults, isEmpty);
    });

    test('should add user message correctly', () async {
      await provider.sendMessage('Olá');
      
      final userMessages = provider.messageList.where(
        (msg) => msg.fromWho == FromWho.userChatMessage && msg.text == 'Olá'
      );
      expect(userMessages.isNotEmpty, true);
    });

    test('should handle empty message', () async {
      final initialLength = provider.messageList.length;
      await provider.sendMessage('');
      
      expect(provider.messageList.length, initialLength);
    });

    test('should have a valid ScrollController', () {
      expect(provider.chatScrollController, isA<ScrollController>());
    });
  });
}