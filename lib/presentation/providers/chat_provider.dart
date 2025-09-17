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
  static const _initialDelay = Duration(milliseconds: 100);
  static const _scrollDuration = Duration(milliseconds: 300);
  
  final ScrollController chatScrollController = ScrollController();
  final List<Message> messageList = [
    Message(text: '¡Hola!', fromWho: FromWho.systemChatMessage),
    Message(
      text: 'Soy tu asistente bíblico personal, siempre disponible. '
          '¿Qué pasaje o versículo de la Biblia te gustaría consultar?',
      fromWho: FromWho.systemChatMessage,
    ),
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
      _addSystemChatMessage("Carregando os versículos, por favor aguarde...");
      return;
    }

    if (text.isEmpty) return;

    _addUserChatMessage(text);

    if (isWaitingChoice) {
      await _processChoice(text);
    } else {
      await _searchVerses(text);
    }

    await moveScrollToBottom();
  }

  /// Processa a escolha do usuário
  Future<void> _processChoice(String text) async {
    if (isWaitingNewSearch) {
      await _handleNewSearchResponse(text);
      return;
    }

    final choice = int.tryParse(text);
    if (_isValidChoice(choice)) {
      _showSelectedVerse(choice!);
      _resetSearch();
    } else {
      _askForNewSearch();
    }
  }

  /// Processa a resposta para uma nova busca
  Future<void> _handleNewSearchResponse(String text) async {
    if (_isPositiveResponse(text)) {
      _resetForNewSearch();
    } else {
      _showSearchResultsAgain();
    }
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
      _addSystemChatMessage('Nenhum versículo encontrado para "$query".');
    } else if (_searchResults.length == 1) {
      _addMessage(_searchResults[0].toMessageEntity());
    } else {
      _showVersesList();
    }
  }

  bool _isValidChoice(int? choice) =>
      choice != null && choice > 0 && choice <= _searchResults.length;

  bool _isPositiveResponse(String text) {
    final response = text.toLowerCase();
    return response.contains('sim') ||
           response.contains('ok') ||
           response.contains('quero');
  }

  void _showSelectedVerse(int choice) {
    _addMessage(_searchResults[choice - 1].toMessageEntity());
  }

  void _resetSearch() {
    _currentState = SearchState.initial;
    _searchResults = [];
  }

  void _resetForNewSearch() {
    _resetSearch();
    _addSystemChatMessage('Ótimo! Pode fazer uma nova busca.');
  }

  void _showSearchResultsAgain() {
    final lista = _createVersesList();
    _addSystemChatMessage('$lista\nPor favor, escolha um número da lista.');
    _currentState = SearchState.waitingChoice;
  }

  void _showVersesList() {
    final lista = _createVersesList();
    _addSystemChatMessage(lista);
    _currentState = SearchState.waitingChoice;
  }

  String _createVersesList() {
    final buffer = StringBuffer("Encontrei ${_searchResults.length} versículos:\n\n");
    for (var i = 0; i < _searchResults.length; i++) {
      final verse = _searchResults[i];
      buffer.write("${i + 1}. ${verse.livro} ${verse.capitulo}:${verse.versiculo}\n");
    }
    return buffer.toString();
  }

  void _askForNewSearch() {
    _addSystemChatMessage('Essa não é uma opção válida. Você gostaria de fazer uma nova busca?');
    _currentState = SearchState.waitingNewSearch;
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(_initialDelay);
    if (!chatScrollController.hasClients) return;
    
    await chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: _scrollDuration,
      curve: Curves.easeOut,
    );
  }
}
