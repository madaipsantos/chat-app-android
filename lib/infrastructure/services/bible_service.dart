import '../../core/constants/chat_messages_constants.dart';
import '../../core/exceptions/bible_search_exception.dart';
import '../../data/models/bible_verse_model.dart';
import '../../domain/repositories/bible_repository.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';

class BibleService {
  final IBibleRepository _repository;
  List<BibleVerseModel> _versiculos = [];
  bool _initialized = false;
  
  // Singleton instance
  static final BibleService instance = BibleService._internal(BibleRepository());
  
  // Constructor for testing
  @visibleForTesting
  BibleService(this._repository);

  // Private constructor
  BibleService._internal(this._repository);

  // Getter para versículos
  List<BibleVerseModel> get versiculos => _versiculos;

  /// Carrega o JSON dos assets
  Future<void> initialize() async {
    if (!_initialized) {
      try {
        _versiculos = await _repository.getAllVerses();
        _initialized = true;
      } catch (e) {
  throw BibleSearchException(ChatMessagesConstants.errorInitService);
      }
    }
  }

  /// Busca por palavra ou frase, ignorando acentos, maiúsculas e pontuação
  List<BibleVerseModel> buscar(String query) {
    try {
      if (query.isEmpty || !_initialized) return [];

      final normalizedQuery = _normalize(query);
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

      if (queryWords.isEmpty) return [];

      return _versiculos.where((v) {
        final normalizedTexto = _normalize(v.texto);
        final normalizedLivro = _normalize(v.livro);

        return queryWords.any((word) =>
            normalizedTexto.contains(word) || normalizedLivro.contains(word));
      }).toList();
    } catch (e) {
  throw BibleSearchException(ChatMessagesConstants.errorSearch);
    }
  }

  /// Normaliza texto: minúsculas, remove acentos e pontuação
  String _normalize(String text) {
    String temp = text.toLowerCase();
    temp = removeDiacritics(temp);
    temp = temp.replaceAll(RegExp(r'[^\w\s]'), '');
    return temp;
  }
}
