import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/services/bible_service.dart';
import 'package:yes_no_app/data/models/bible_verse_model.dart';

/// Estados possíveis durante o fluxo de busca de versículos
enum SearchState {
  initial, // Estado inicial, pronto para receber uma busca
  waitingChoice, // Esperando que o usuário escolha um versículo da lista
  waitingNewSearch, // Esperando confirmação para iniciar uma nova busca
}

/// Provedor para gerenciar o estado do chat e interações com a API bíblica
class ChatProvider extends ChangeNotifier {
  // Controllers e estado
  final ScrollController chatScrollController = ScrollController();
  final List<Message> messageList = [];
  List<BibleVerseModel> _searchResults = [];
  SearchState _currentState = SearchState.initial;
  final bool _isJsonLoaded = true;
  String _userName = '';
  BuildContext? _context;

  ChatProvider({bool initializeChat = true}) {
    if (initializeChat) {
      // Iniciamos la carga de mensajes iniciales después de que el widget esté construido
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
    _initializeChat();
    notifyListeners();
  }

  /// Inicializa o chat com mensagens de boas-vindas
  Future<void> _initializeChat() async {
    final initialMessages = [
      'Holá${_userName.isNotEmpty ? ", $_userName" : ""}! Soy tu asistente bíblico personal.',      
      'En cualquier momento, puedes escribir: ',
      'Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "SALIR" si quieres salir del chat.',
      '¿Quieres buscar un versículo bíblico?',
      'Escribe lo que tienes en mente, por ejemplo: "amor", "perdón" o "Salmo 23:1".',
    ];

    for (final message in initialMessages) {
      await _showTypingThenMessage(message);
      await Future.delayed(const Duration(milliseconds: 300));
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
    if (text.isEmpty) return;

    final upperText = text.toUpperCase().trim();

    // Verificar SALIR y BUSCAR antes de cualquier otra operación
    if (upperText == 'SALIR') {
      _addUserChatMessage(text);
      // Mostrar mensajes de despedida
      await _addSystemMessages([
        '¡Hasta luego!',
        'Gracias por usar el asistente bíblico.',
      ]);
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

    if (upperText == 'BUSCAR') {
      _addUserChatMessage(text);
      await _handleSearchCommand();
      return;
    }

    if (!_isJsonLoaded) {
      await _addSystemChatMessage("Cargando versos, por favor espere...");
      return;
    }

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
      await _addSystemChatMessage(
        'Ocurrió un error. Por favor, intenta de nuevo.',
      );
    }

    await moveScrollToBottom();
  }

  /// Processa a escolha do usuário
  Future<void> _processChoice(String text) async {
    final upperText = text.toUpperCase().trim();
    final invalidOptionsMessage =
        'Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "SALIR" si quieres terminar el chat.';

    switch (upperText) {
      case 'VOLVER':
        await _showVersesList();
        _currentState = SearchState.waitingChoice;
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
      await _addSystemMessages([
        '¡Ups! Esa opción no es válida.',
        'Por favor, elige una opción:',
        invalidOptionsMessage,
      ]);
      _currentState = SearchState.waitingChoice;
    }
  }

  /// Processa a resposta para uma nova busca
  Future<void> _handleNewSearchResponse(String text) async {
    final response = text.toLowerCase().trim();

    if (response == 'salir') {
      await _exitChat();
    } else if (response == 'si' || response == 'sí') {
      _resetSearch();
      await _addSystemChatMessage(
        'Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".',
      );
      _currentState = SearchState.initial;
    } else if (response == 'no') {
      await _showVersesList();
      _currentState = SearchState.waitingChoice;
    } else {
      await _addSystemChatMessage('Por favor, responda "SÍ", "NO" o "SALIR".');
      _currentState = SearchState.waitingNewSearch;
    }

    notifyListeners();
  }

  /// Finaliza o chat com mensagem de despedida
  Future<void> _exitChat() async {
    await _addSystemMessages([
      '¡Hasta luego!',
      'Gracias por usar el asistente bíblico.',
    ]);
    await Future.delayed(const Duration(seconds: 2));

    // Limpiamos completamente el chat
    messageList.clear();
    notifyListeners();

    // Esperamos un momento para que se vea la limpieza
    await Future.delayed(const Duration(milliseconds: 300));

    // Reiniciamos el estado
    _resetSearch();
    _currentState = SearchState.initial;
    _userName = ''; // Limpiamos también el nombre de usuario

    // Redirigir a la pantalla inicial y limpiar el historial de navegación
    if (_context != null) {
      Navigator.of(_context!).pushNamedAndRemoveUntil('/', (route) => false);
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

  void _addUserChatMessage(String text) {
    _addMessage(Message(text: text, fromWho: FromWho.userChatMessage));
  }

  void _addMessage(Message message) {
    messageList.add(message);
    notifyListeners();
  }

  Future<void> _searchVerses(String query) async {
    _searchResults = BibleService.instance.buscar(query);

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

  /// Mostra um versículo selecionado pelo usuário
  Future<void> _showSelectedVerse(int choice) async {
    final verse = _searchResults[choice - 1];
    await _showTypingThenMessage(Message(
      text: verse.toMessageEntity().text,
      fromWho: FromWho.verseMessage,
    ));
  }

  void _resetSearch() {
    _currentState = SearchState.initial;
    _searchResults = [];
  }

  Future<void> _showVersesList() async {
    final lista = _createVersesList();
    await _addSystemChatMessage(lista);
    await _addSystemChatMessage("Por favor, elige un número de la lista para ver el versículo completo, o escribe una de las opciones de abajo.");
    await _addSystemChatMessage("Escribe 'BUSCAR' para una nueva búsqueda.\nEscribe 'SALIR' si quieres terminar el chat.");
    // Mostrar mensajes de navegación si hay más de una página

    _currentState = SearchState.waitingChoice;
    await moveScrollToBottom();
  }

  String _createVersesList() {
    final buffer = StringBuffer(
      "Encontré ${_searchResults.length} versículos:\n\n",
    );

    for (var i = 0; i < _searchResults.length; i++) {
      final verse = _searchResults[i];
      buffer.write(
        "${i + 1}. ${verse.livro} ${verse.capitulo}:${verse.versiculo}\n",
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
    await _addSystemChatMessage('Escribe el tema o versículo que deseas buscar.');
    _currentState = SearchState.initial;
  }
}
