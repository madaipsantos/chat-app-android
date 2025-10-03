import 'package:asistente_biblico/core/exceptions/bible_search_exception.dart';
import 'package:asistente_biblico/core/exceptions/invalid_choice_exception.dart';
import 'package:flutter/material.dart';
import 'package:asistente_biblico/domain/entities/message.dart';
import 'package:asistente_biblico/infrastructure/services/bible_service.dart';
import 'package:asistente_biblico/data/models/bible_verse_model.dart';
import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:asistente_biblico/core/exceptions/invalid_message_exception.dart';
import 'package:diacritic/diacritic.dart';

/// Estados possíveis durante o fluxo de busca de versículos
enum SearchState {
  initial, // Estado inicial, pronto para receber uma busca
  waitingChoice, // Esperando que o usuário escolha um versículo da lista
  waitingNewSearch, // Esperando confirmação para iniciar uma nova busca
}

/// Provedor para gerenciar o estado do chat e interações com a API bíblica
class ChatProvider extends ChangeNotifier {
  // Getters públicos para testing
  String get userName => _userName;
  SearchState get currentState => _currentState;
  // Controllers e estado
  final ScrollController chatScrollController = ScrollController();
  final List<Message> messageList = [];
  List<BibleVerseModel> _searchResults = [];
  SearchState _currentState = SearchState.initial;
  final bool _isJsonLoaded = true;
  String _userName = '';
  BuildContext? _context;
  final bool _initializeChatFlag;
  int _currentPage = 0;
  static const int _pageSize = 5;

  ChatProvider({bool initializeChat = true})
    : _initializeChatFlag = initializeChat {
    if (_initializeChatFlag) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_userName.isEmpty) {
          _initializeChat();
        }
      });
    }
  }

  /// Define o nome do usuário
  void setContext(BuildContext context) {
    _context = context;
  }

  void setUserName(String name) {
    // Capitaliza la primera letra y pone el resto en minúsculas
    _userName = name.isNotEmpty
        ? "${name[0].toUpperCase()}${name.substring(1).toLowerCase()}"
        : name;
    // Inicializamos el chat cada vez que se establece un nuevo nombre
    messageList.clear();
    _resetSearch();
    _currentState = SearchState.initial;
    if (_initializeChatFlag) {
      _initializeChat();
    }
    notifyListeners();
  }

  /// Inicializa o chat com mensagens de boas-vindas
  Future<void> _initializeChat() async {
    try {
      final initialMessages = ChatMessagesConstants.welcomeMessages
          .map(
            (msg) => msg.replaceFirst(
              '{userName}',
              _userName.isNotEmpty ? ", $_userName" : "",
            ),
          )
          .toList();
      for (final message in initialMessages) {
        await _showTypingThenMessage(message);
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      await _addSystemChatMessage(ChatMessagesConstants.errorInitChat);
    }
  }

  /// Adiciona a mensagem diretamente sem efeito de digitação
  Future<void> _showTypingThenMessage(dynamic messageContent) async {
    if (messageContent is String) {
      _addMessage(
        Message(text: messageContent, fromWho: FromWho.systemChatMessage),
      );
    } else if (messageContent is Message) {
      _addMessage(messageContent);
    }
    await moveScrollToBottom();
  }

  // Getters
  bool get isWaitingChoice => _currentState == SearchState.waitingChoice;
  bool get isWaitingNewSearch => _currentState == SearchState.waitingNewSearch;
  List<BibleVerseModel> get searchResults => List.unmodifiable(_searchResults);

  /// Processa a mensagem enviada pelo usuário
  Future<void> sendMessage(String text) async {
    try {
      if (text.trim().isEmpty) {
        throw InvalidMessageException(ChatMessagesConstants.errorEmptyMessage);
      }

      final normalizedText = removeDiacritics(text.toUpperCase().trim());

      // Verificar SALIR y BUSCAR antes de cualquier otra operación
      if (normalizedText == 'SALIR') {
        addUserChatMessage(text);
        // Mostrar mensajes de despedida
        await _addSystemMessages(ChatMessagesConstants.farewellMessages);
        await Future.delayed(const Duration(seconds: 2));

        // Limpiar completamente el chat
        messageList.clear();
        notifyListeners();

        // Esperar un momento para que se vea la limpieza
        await Future.delayed(const Duration(milliseconds: 500));

        // Reiniciar el estado
        _resetSearch();
        _currentState = SearchState.initial;

        // Redirigir a la pantalla inicial y limpiar el historial de navegación
        if (_context != null) {
          Navigator.of(_context!).pushNamedAndRemoveUntil(
            '/',
            (route) => false, // Esto removerá todas las rutas anteriores
          );
        }
        return;
      }

      if (normalizedText == 'BUSCAR') {
        addUserChatMessage(text);
        await _handleSearchCommand();
        return;
      }

      if (!_isJsonLoaded) {
        await _addSystemChatMessage(ChatMessagesConstants.loadingVerses);
        return;
      }

      addUserChatMessage(text);

      if (isWaitingNewSearch) {
        await _handleNewSearchResponse(text);
      } else if (isWaitingChoice) {
        await _processChoice(text);
      } else {
        await _searchVerses(text);
      }
    } on InvalidMessageException catch (e) {
      await _addSystemChatMessage(e.message);
    } on InvalidChoiceException catch (e) {
      await _addSystemChatMessage(e.message);
      await _addSystemMessages([
        ChatMessagesConstants.chooseOption,
        ChatMessagesConstants.invalidChoiceOptions,
      ]);
      _currentState = SearchState.waitingChoice;
    } on BibleSearchException catch (e) {
      await _addSystemChatMessage(e.message);
    } catch (e) {
      await _addSystemChatMessage(ChatMessagesConstants.errorOccurred);
    }

    await moveScrollToBottom();
  }

  /// Processa a escolha do usuário
  Future<void> _processChoice(String text) async {
    final normalizedText = removeDiacritics(text.toUpperCase().trim());

    switch (normalizedText) {
      case 'VOLVER':
        await _showVersesList();
        _currentState = SearchState.waitingChoice;
        return;

      case 'PROXIMO':
      case 'PRÓXIMO':
        if ((_currentPage + 1) * _pageSize < _searchResults.length) {
          _currentPage++;
          await _showVersesList();
        } else {
          await _addSystemChatMessage(ChatMessagesConstants.lastPageOptions);
          await _addSystemChatMessage(
            ChatMessagesConstants.lastPageNavigationOptions,
          );
        }
        return;

      case 'ANTERIOR':
        if (_currentPage > 0) {
          _currentPage--;
          await _showVersesList();
        } else {
          await _addSystemChatMessage(ChatMessagesConstants.firstPageOptions);
          await _addSystemChatMessage(
            ChatMessagesConstants.firstPageAvailableActions,
          );
        }
        return;

      case 'SALIR':
        return;
    }

    final choice = int.tryParse(text);
    if (_isValidChoice(choice)) {
      await _showSelectedVerse(choice!);
      // Agregamos una pausa más corta para mejorar la fluidez
      await Future.delayed(const Duration(milliseconds: 300));
      _currentState = SearchState.waitingChoice;
      await _showVersesList();
    } else {
      throw InvalidChoiceException(ChatMessagesConstants.errorInvalidChoice);
    }
  }

  /// Processa a resposta para uma nova busca
  Future<void> _handleNewSearchResponse(String text) async {
    final normalizedText = removeDiacritics(text.toLowerCase().trim());

    if (normalizedText == 'salir') {
      await _exitChat();
    } else if (normalizedText == 'si' || normalizedText == 'sí') {
      _resetSearch();
      await _addSystemChatMessage(ChatMessagesConstants.writeTopicExample);
      _currentState = SearchState.initial;
    } else if (normalizedText == 'no') {
      await _showVersesList();
      _currentState = SearchState.waitingChoice;
    } else {
      await _addSystemChatMessage(ChatMessagesConstants.answerYesNoExit);
      _currentState = SearchState.waitingNewSearch;
    }

    notifyListeners();
  }

  /// Finaliza o chat com mensagem de despedida
  Future<void> _exitChat() async {
    await _addSystemMessages(ChatMessagesConstants.farewellMessages);
    await Future.delayed(const Duration(seconds: 2));

    // Limpiamos completamente el chat
    messageList.clear();
    notifyListeners();

    // Esperamos un momento para que se vea la limpieza
    await Future.delayed(const Duration(milliseconds: 100));

    // Reiniciamos el estado
    _resetSearch();
    _currentState = SearchState.initial;
    _userName = ''; // Limpiamos también el nombre de usuario

    // Redirigir a la pantalla inicial y limpiar el historial de navegación
    if (_context != null) {
      try {
        Navigator.of(_context!).pushNamedAndRemoveUntil('/', (route) => false);
      } catch (e) {
        await _addSystemChatMessage(ChatMessagesConstants.errorNavigation);
      }
    }
  }

  /// Adiciona uma mensagem do sistema com efeito de digitação
  Future<void> _addSystemChatMessage(String text) async {
    await _showTypingThenMessage(text);
  }

  /// Adiciona várias mensagens do sistema em sequência
  Future<void> _addSystemMessages(List<String> messages) async {
    for (String message in messages) {
      await _addSystemChatMessage(message);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void addUserChatMessage(String text) {
    _addMessage(Message(text: text, fromWho: FromWho.userChatMessage));
  }

  void _addMessage(Message message) {
    messageList.add(message);
    notifyListeners();
  }

  Future<void> _searchVerses(String query) async {
    try {
      _searchResults = BibleService.instance.buscar(query);

      if (_searchResults.isEmpty) {
        await _addSystemChatMessage(
          ChatMessagesConstants.notFound.replaceFirst('{query}', query),
        );
      } else if (_searchResults.length == 1) {
        _addMessage(_searchResults[0].toMessageEntity());
      } else {
        await _showVersesList();
      }
    } catch (e) {
      throw BibleSearchException(ChatMessagesConstants.errorSearch);
    }
  }

  bool _isValidChoice(int? choice) {
    int start = _currentPage * _pageSize;
    int end = start + _pageSize;
    end = end > _searchResults.length ? _searchResults.length : end;
    return choice != null && choice > 0 && choice <= (end - start);
  }

  /// Mostra um versículo selecionado pelo usuário
  Future<void> _showSelectedVerse(int choice) async {
    int start = _currentPage * _pageSize;
    final verse = _searchResults[start + choice - 1];
    await _showTypingThenMessage(
      Message(
        text: verse.toMessageEntity().text,
        fromWho: FromWho.verseMessage,
      ),
    );
  }

  void _resetSearch() {
    _currentState = SearchState.initial;
    _searchResults = [];
    _currentPage = 0;
  }

  Future<void> _showVersesList() async {
    final lista = _createVersesList();
    await _addSystemChatMessage(lista);
    await _addSystemChatMessage(ChatMessagesConstants.chooseVerse);

    // Agregar opciones de navegación
    String navigationOptions = ChatMessagesConstants.listOptions;
    if (_searchResults.length > _pageSize) {
      if (_currentPage > 0) {
        navigationOptions =
            ChatMessagesConstants.previousPageOption + navigationOptions;
      }
      if ((_currentPage + 1) * _pageSize < _searchResults.length) {
        navigationOptions =
            ChatMessagesConstants.nextPageOption + navigationOptions;
      }
    }
    await _addSystemChatMessage(navigationOptions);

    _currentState = SearchState.waitingChoice;
    await moveScrollToBottom();
  }

  String _createVersesList() {
    final totalPages = (_searchResults.length / _pageSize).ceil();

    final buffer = StringBuffer(
      "Encontré ${_searchResults.length} versículos" +
          (totalPages > 1
              ? " (página ${_currentPage + 1} de $totalPages)"
              : "") +
          ":\n\n",
    );

    int start = _currentPage * _pageSize;
    int end = (_currentPage + 1) * _pageSize;
    end = end > _searchResults.length ? _searchResults.length : end;

    for (var i = start; i < end; i++) {
      final verse = _searchResults[i];
      buffer.write(
        "${i - start + 1}. ${verse.livro} ${verse.capitulo}:${verse.versiculo}\n",
      );
    }

    return buffer.toString();
  }

  /// Move o scroll para o final da lista de mensagens
  Future<void> moveScrollToBottom() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!chatScrollController.hasClients) return;

        final maxScroll = chatScrollController.position.maxScrollExtent;
        final currentScroll = chatScrollController.position.pixels;

        if (currentScroll < maxScroll) {
          chatScrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Ignora erros de scroll, pois não são críticos para a funcionalidade
    }
  }

  /// Maneja el comando BUSCAR
  Future<void> _handleSearchCommand() async {
    _resetSearch();
    await _addSystemChatMessage(ChatMessagesConstants.searchPrompt);
    _currentState = SearchState.initial;
  }
}
