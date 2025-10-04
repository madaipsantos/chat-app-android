import 'package:asistente_biblico/core/exceptions/bible_search_exception.dart';
import 'package:asistente_biblico/core/exceptions/invalid_choice_exception.dart';
import 'package:flutter/material.dart';
import 'package:asistente_biblico/domain/entities/message.dart';
import 'package:asistente_biblico/infrastructure/services/bible_service.dart';
import 'package:asistente_biblico/data/models/bible_verse_model.dart';
import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:asistente_biblico/core/exceptions/invalid_message_exception.dart';
import 'package:diacritic/diacritic.dart';

/// Number of verses to show per page in the chat.
const int kPageSize = 5;

/// Possible states during the verse search flow.
enum SearchState {
  initial, // Ready to receive a search
  waitingChoice, // Waiting for user to choose a verse from the list
  waitingNewSearch, // Waiting for confirmation to start a new search
}

/// Provider to manage chat state and interactions with the Bible API.
class ChatProvider extends ChangeNotifier {
  // Public getters
  String get userName => _userName;
  SearchState get currentState => _currentState;
  List<BibleVerseModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isWaitingChoice => _currentState == SearchState.waitingChoice;
  bool get isWaitingNewSearch => _currentState == SearchState.waitingNewSearch;

  // Public fields
  final ScrollController chatScrollController = ScrollController();
  final List<Message> messageList = [];

  // Private fields
  List<BibleVerseModel> _searchResults = [];
  SearchState _currentState = SearchState.initial;
  final bool _isJsonLoaded = true;
  String _userName = '';
  BuildContext? _context;
  final bool _initializeChatFlag;
  int _currentPage = 0;

  /// Creates a [ChatProvider].
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

  /// Sets the context for navigation.
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Sets the user name and initializes the chat.
  void setUserName(String name) {
    _userName = name.isNotEmpty
        ? "${name[0].toUpperCase()}${name.substring(1).toLowerCase()}"
        : name;
    messageList.clear();
    _resetSearch();
    _currentState = SearchState.initial;
    if (_initializeChatFlag) {
      _initializeChat();
    }
    notifyListeners();
  }

  /// Processes the message sent by the user.
  Future<void> sendMessage(String text) async {
    try {
      if (text.trim().isEmpty) {
        throw InvalidMessageException(ChatMessagesConstants.errorEmptyMessage);
      }

      final normalizedText = removeDiacritics(text.toUpperCase().trim());

      // Handle exit and search commands first
      if (normalizedText == 'SALIR') {
        addUserChatMessage(text);
        await _addSystemMessages(ChatMessagesConstants.farewellMessages);
        await Future.delayed(const Duration(seconds: 2));
        messageList.clear();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
        _resetSearch();
        _currentState = SearchState.initial;
        if (_context != null) {
          Navigator.of(
            _context!,
          ).pushNamedAndRemoveUntil('/', (route) => false);
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
    } catch (_) {
      await _addSystemChatMessage(ChatMessagesConstants.errorOccurred);
    }

    await moveScrollToBottom();
  }

  /// Adds a user message to the chat.
  void addUserChatMessage(String text) {
    _addMessage(Message(text: text, fromWho: FromWho.userChatMessage));
  }

  /// Moves the scroll to the bottom of the chat.
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
    } catch (_) {
      // Ignore scroll errors, not critical for functionality
    }
  }

  // ===========================
  // Private methods below
  // ===========================

  /// Initializes the chat with welcome messages.
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
    } catch (_) {
      await _addSystemChatMessage(ChatMessagesConstants.errorInitChat);
    }
  }

  /// Shows a message with typing effect.
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

  /// Adds a message to the chat and notifies listeners.
  void _addMessage(Message message) {
    messageList.add(message);
    notifyListeners();
  }

  /// Handles the user's choice from the list of verses.
  Future<void> _processChoice(String text) async {
    final normalizedText = removeDiacritics(text.toUpperCase().trim());

    switch (normalizedText) {
      case 'VOLVER':
        await _showVersesList();
        _currentState = SearchState.waitingChoice;
        return;
      case 'PROXIMO':
      case 'PRÓXIMO':
        if ((_currentPage + 1) * kPageSize < _searchResults.length) {
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
      await Future.delayed(const Duration(milliseconds: 300));
      _currentState = SearchState.waitingChoice;
      await _showVersesList();
    } else {
      throw InvalidChoiceException(ChatMessagesConstants.errorInvalidChoice);
    }
  }

  /// Handles the response for a new search.
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

  /// Ends the chat with a farewell message and resets state.
  Future<void> _exitChat() async {
    await _addSystemMessages(ChatMessagesConstants.farewellMessages);
    await Future.delayed(const Duration(seconds: 2));
    messageList.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _resetSearch();
    _currentState = SearchState.initial;
    _userName = '';
    if (_context != null) {
      try {
        Navigator.of(_context!).pushNamedAndRemoveUntil('/', (route) => false);
      } catch (_) {
        await _addSystemChatMessage(ChatMessagesConstants.errorNavigation);
      }
    }
  }

  /// Adds a system message with typing effect.
  Future<void> _addSystemChatMessage(String text) async {
    await _showTypingThenMessage(text);
  }

  /// Adds multiple system messages in sequence.
  Future<void> _addSystemMessages(List<String> messages) async {
    for (String message in messages) {
      await _addSystemChatMessage(message);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Searches for verses matching the query.
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
    } catch (_) {
      throw BibleSearchException(ChatMessagesConstants.errorSearch);
    }
  }

  /// Checks if the user's choice is valid for the current page.
  bool _isValidChoice(int? choice) {
    int start = _currentPage * kPageSize;
    int end = start + kPageSize;
    end = end > _searchResults.length ? _searchResults.length : end;
    return choice != null && choice > 0 && choice <= (end - start);
  }

  /// Shows the selected verse.
  Future<void> _showSelectedVerse(int choice) async {
    int start = _currentPage * kPageSize;
    final verse = _searchResults[start + choice - 1];
    await _showTypingThenMessage(
      Message(
        text: verse.toMessageEntity().text,
        fromWho: FromWho.verseMessage,
      ),
    );
  }

  /// Resets the search state and results.
  void _resetSearch() {
    _currentState = SearchState.initial;
    _searchResults = [];
    _currentPage = 0;
  }

  /// Shows the list of verses for the current page.
  Future<void> _showVersesList() async {
    final listText = _createVersesList();
    await _addSystemChatMessage(listText);
    await _addSystemChatMessage(ChatMessagesConstants.chooseVerse);

    // Add navigation options
    String navigationOptions = ChatMessagesConstants.listOptions;
    if (_searchResults.length > kPageSize) {
      if (_currentPage > 0) {
        navigationOptions =
            ChatMessagesConstants.previousPageOption + navigationOptions;
      }
      if ((_currentPage + 1) * kPageSize < _searchResults.length) {
        navigationOptions =
            ChatMessagesConstants.nextPageOption + navigationOptions;
      }
    }
    await _addSystemChatMessage(navigationOptions);

    _currentState = SearchState.waitingChoice;
    await moveScrollToBottom();
  }

  /// Creates the list of verses for the current page.
  String _createVersesList() {
    final totalPages = (_searchResults.length / kPageSize).ceil();

    final buffer = StringBuffer(
      "Encontré ${_searchResults.length} versículos" +
          (totalPages > 1
              ? " (página ${_currentPage + 1} de $totalPages)"
              : "") +
          ":\n\n",
    );

    int start = _currentPage * kPageSize;
    int end = (_currentPage + 1) * kPageSize;
    end = end > _searchResults.length ? _searchResults.length : end;

    for (var i = start; i < end; i++) {
      final verse = _searchResults[i];
      buffer.write(
        "${i - start + 1}. ${verse.livro} ${verse.capitulo}:${verse.versiculo}\n",
      );
    }

    return buffer.toString();
  }

  /// Handles the BUSCAR command.
  Future<void> _handleSearchCommand() async {
    _resetSearch();
    await _addSystemChatMessage(ChatMessagesConstants.searchPrompt);
    _currentState = SearchState.initial;
  }
}
