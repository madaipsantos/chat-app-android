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
  final ScrollController chatScrollController = ScrollController();
  final List<Message> messageList = [
    Message(text: '¡Hola!', fromWho: FromWho.systemChatMessage),
    Message(text: 'Soy tu asistente bíblico personal.', fromWho: FromWho.systemChatMessage,),
    Message(text: '¿Quieres buscar un versículo de la Biblia?', fromWho: FromWho.systemChatMessage),
    Message(text: 'Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".', fromWho: FromWho.systemChatMessage),
    Message(text: 'Si deseas salir del chat en cualquier momento, puedes escribir "SALIR', fromWho: FromWho.systemChatMessage),
  ];

  List<BibleVerseModel> _searchResults = [];
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
    
    if (upperText == 'BUSCAR') {
        _resetSearch();
        _addSystemChatMessage('Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".');
        _currentState = SearchState.initial;
        return;
    }
    
    if (upperText == 'VOLVER') {
        _showVersesList();
        _currentState = SearchState.waitingChoice;
        return;
    }
    
    if (upperText == 'SALIR') {
        _addSystemChatMessage('¡Hasta luego! Gracias por usar el asistente bíblico.');
        await Future.delayed(const Duration(seconds: 1));
        exit(0);
    }

    final choice = int.tryParse(text);
    if (_isValidChoice(choice)) {
        _showSelectedVerse(choice!);
        _currentState = SearchState.waitingChoice;
        _showVersesList();
    } else {
        _addSystemChatMessage('¡Ups! Esa opción no es válida.');
        _addSystemChatMessage('Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "VOLVER" para regresar a los versículos.\nEscribe "SALIR" si quieres terminar el chat.');
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
  void _addSystemChatMessage(String text) {
    _addMessage(Message(
      text: text,
      fromWho: FromWho.systemChatMessage,
    ));
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

  void _showSelectedVerse(int choice) {
    _addMessage(_searchResults[choice - 1].toMessageEntity());
  }

  void _resetSearch() {
    _currentState = SearchState.initial;
    _searchResults = [];
  }

  void _showVersesList() {
    final lista = _createVersesList();
    _addSystemChatMessage(lista);
    _currentState = SearchState.waitingChoice;
  }

  String _createVersesList() {
    final buffer = StringBuffer("Encontré ${_searchResults.length} versículos:\n\n");
    for (var i = 0; i < _searchResults.length; i++) {
      final verse = _searchResults[i];
      buffer.write("${i + 1}. ${verse.livro} ${verse.capitulo}:${verse.versiculo}\n");
    }
    return buffer.toString();
  }

  void _askForNewSearch() {
    _currentState = SearchState.waitingNewSearch; // Actualizar el estado primero
    _addSystemChatMessage('¡Ups! Esa opción no es válida.');
    _addSystemChatMessage('Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "VOLVER" para egresar a la lista de versículos.\nEscribe "SALIR" si quieres terminar el chat.');
    notifyListeners(); // Asegurar que los cambios se notifiquen
  }

  Future<void> moveScrollToBottom() async {
    try {
      // Usar addPostFrameCallback para evitar builds durante el frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!chatScrollController.hasClients) return;
        
        // Obtener las posiciones de scroll de manera segura
        final maxScroll = chatScrollController.position.maxScrollExtent;
        final currentScroll = chatScrollController.position.pixels;
        
        // Solo hacer scroll si es necesario
        if (currentScroll < maxScroll) {
          await chatScrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 100), // Reducir duración
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error al mover el scroll: $e');
    }
  }
}
