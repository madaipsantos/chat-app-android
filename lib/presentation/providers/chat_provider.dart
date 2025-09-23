import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/services/bible_service.dart';
import 'package:yes_no_app/infrastructure/models/bible_verse_model.dart';

/// Estado da busca de versículos
enum SearchState {
  initial,
  waitingChoice,
  waitingNewSearch,
}

/// Provedor para gerenciar o estado do chat
class ChatProvider extends ChangeNotifier {
  static const Duration typingDelay = Duration(milliseconds: 800);
  
  final ScrollController chatScrollController = ScrollController();
  final List<Message> messageList = [];

  List<BibleVerseModel> _searchResults = [];
  
  ChatProvider() {
    // Iniciamos la carga de mensajes iniciales después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }
  
  Future<void> _initializeChat() async {
    final initialMessages = [
      '¡Hola!',
      'Soy tu asistente bíblico personal.',
      '¿Quieres buscar un versículo de la Biblia?',
      'Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".',
      'Si deseas salir del chat en cualquier momento, puedes escribir "SALIR"',
    ];
    
    for (final message in initialMessages) {
      // Agregar el indicador de escritura
      _addMessage(Message(
        text: '',
        fromWho: FromWho.typingIndicator,
      ));
      await moveScrollToBottom();
      
      await Future.delayed(typingDelay);
      
      // Reemplazar con el mensaje real
      messageList.removeLast();
      _addMessage(Message(
        text: message,
        fromWho: FromWho.systemChatMessage,
      ));
      
      await moveScrollToBottom();
      await Future.delayed(const Duration(milliseconds: 500)); // Pequeña pausa entre mensajes
    }
  }
  SearchState _currentState = SearchState.initial;
  bool _isJsonLoaded = true;

  // Getters
  bool get isWaitingChoice => _currentState == SearchState.waitingChoice;
  bool get isWaitingNewSearch => _currentState == SearchState.waitingNewSearch;
  List<BibleVerseModel> get searchResults => List.unmodifiable(_searchResults);

  Future<void> sendMessage(String text) async {
    if (!_isJsonLoaded) {
      _addSystemChatMessage("Cargando versos, por favor espere...");
      return;
    }

    if (text.isEmpty) return;

    _addUserChatMessage(text);

    try {
      if (isWaitingNewSearch) {
        await _handleNewSearchResponse(text);
      } else if (isWaitingChoice) {
        await _processChoice(text);
      } else {
        await _searchVerses(text);
      }
    } catch (e) {
      print('Error procesando mensaje: $e');
      _addSystemChatMessage('Ocurrió un error. Por favor, intenta de nuevo.');
    }

    await Future.delayed(const Duration(milliseconds: 50)); // Pequeña pausa
    await moveScrollToBottom();
  }

  /// Processa a escolha do usuário
Future<void> _processChoice(String text) async {
    final upperText = text.toUpperCase().trim();
    final invalidOptionsMessage = 'Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "VOLVER" para regresar a los versículos.\nEscribe "SALIR" si quieres terminar el chat.';
    
    switch (upperText) {
        case 'BUSCAR':
            _resetSearch();
            await _addSystemChatMessage('Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".');
            _currentState = SearchState.initial;
            return;
            
        case 'VOLVER':
            await _showVersesList();
            _currentState = SearchState.waitingChoice;
            return;
            
        case 'SALIR':
            await _addSystemMessages([
                '¡Hasta luego!',
                'Gracias por usar el asistente bíblico.'
            ]);
            await Future.delayed(const Duration(seconds: 1));
            exit(0);
    }

    final choice = int.tryParse(text);
    if (_isValidChoice(choice)) {
        await _showSelectedVerse(choice!);
        // Agregamos una pausa más corta para mejorar la fluidez
        await Future.delayed(const Duration(milliseconds: 300));
        _currentState = SearchState.waitingChoice;
        await _showVersesList();
    } else {
        await _addSystemMessages([
            '¡Ups! Esa opción no es válida.',
            'Por favor, elige una opción:',
            invalidOptionsMessage
        ]);
        _currentState = SearchState.waitingChoice;
    }
}

  /// Processa a resposta para uma nova busca
Future<void> _handleNewSearchResponse(String text) async {
  final response = text.toLowerCase().trim();
  
  print('Response received: $response'); // Debug
  print('Current state: $_currentState'); // Debug
  
  if (response == 'salir') {
    _addSystemChatMessage('¡Hasta luego! Gracias por usar el asistente bíblico.');
    await Future.delayed(const Duration(seconds: 1));
    exit(0);
  } else if (response == 'si' || response == 'sí') {
    _resetSearch();
    _addSystemChatMessage('Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".');
    _currentState = SearchState.initial;
  } else if (response == 'no') {
    print('Processing NO response'); // Debug
    _showVersesList();
    _currentState = SearchState.waitingChoice;
  } else {
    _addSystemChatMessage('Por favor, responda "SÍ", "NO" o "SALIR".');
    _currentState = SearchState.waitingNewSearch;
  }
  
  notifyListeners(); // Asegurar que los cambios se notifiquen
}

  /// Métodos auxiliares
  Future<void> _addSystemChatMessage(String text) async {
    // Agregar el indicador de escritura como un mensaje
    _addMessage(Message(
      text: '',
      fromWho: FromWho.typingIndicator,
    ));
    await moveScrollToBottom();
    
    await Future.delayed(typingDelay);
    
    // Reemplazar el último mensaje (indicador) con el mensaje real
    messageList.removeLast();
    _addMessage(Message(
      text: text,
      fromWho: FromWho.systemChatMessage,
    ));
    
    await moveScrollToBottom();
  }

  Future<void> _addSystemMessages(List<String> messages) async {
    for (String message in messages) {
      await _addSystemChatMessage(message);
      await Future.delayed(const Duration(seconds: 1)); // Pausa más larga entre mensajes
    }
  }

  void _addUserChatMessage(String text) {
    _addMessage(Message(
      text: text,
      fromWho: FromWho.userChatMessage,
    ));
  }

  void _addMessage(Message message) {
    messageList.add(message);
    notifyListeners();
  }

  Future<void> _searchVerses(String query) async {
    _searchResults = BibleService.buscar(query);

    if (_searchResults.isEmpty) {
      _addSystemChatMessage('No se encontraron versículos para "$query".');
    } else if (_searchResults.length == 1) {
      _addMessage(_searchResults[0].toMessageEntity());
    } else {
      _showVersesList();
    }
  }

  bool _isValidChoice(int? choice) =>
      choice != null && choice > 0 && choice <= _searchResults.length;

  Future<void> _showSelectedVerse(int choice) async {
    // Agregar el indicador de escritura
    _addMessage(Message(
      text: '',
      fromWho: FromWho.typingIndicator,
    ));
    await moveScrollToBottom();
    
    await Future.delayed(typingDelay);
    
    // Reemplazar con el mensaje real
    messageList.removeLast();
    final message = _searchResults[choice - 1].toMessageEntity();
    _addMessage(message);
    
    await moveScrollToBottom();
  }

  void _resetSearch() {
    _currentState = SearchState.initial;
    _searchResults = [];
  }

  Future<void> _showVersesList() async {
    final lista = _createVersesList();
    await _addSystemChatMessage(lista);
    _currentState = SearchState.waitingChoice;
    await moveScrollToBottom();
  }

  String _createVersesList() {
    final buffer = StringBuffer("Encontré ${_searchResults.length} versículos:\n\n");
    for (var i = 0; i < _searchResults.length; i++) {
      final verse = _searchResults[i];
      buffer.write("${i + 1}. ${verse.livro} ${verse.capitulo}:${verse.versiculo}\n");
    }
    return buffer.toString();
  }

  Future<void> moveScrollToBottom() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!chatScrollController.hasClients) return;
        
        final maxScroll = chatScrollController.position.maxScrollExtent;
        final currentScroll = chatScrollController.position.pixels;
        
        if (currentScroll < maxScroll) {
          await chatScrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error al mover el scroll: $e');
    }
  }
}
