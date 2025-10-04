import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:asistente_biblico/core/exceptions/bible_search_exception.dart';
import 'package:asistente_biblico/data/models/bible_verse_model.dart';
import 'package:asistente_biblico/domain/repositories/bible_repository.dart';
import 'package:asistente_biblico/infrastructure/repositories/bible_repository_impl.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Bible verse data and search operations.
class BibleService {
  final BibleRepository _repository;
  List<BibleVerseModel> _versiculos = [];
  bool _initialized = false;

  /// Singleton instance of [BibleService].
  static final BibleService instance = BibleService._internal(BibleRepositoryImpl());

  /// Constructor for dependency injection and testing.
  @visibleForTesting
  BibleService(this._repository);

  /// Private constructor for singleton.
  BibleService._internal(this._repository);

  /// Returns the loaded list of Bible verses.
  List<BibleVerseModel> get versiculos => _versiculos;

  /// Loads all Bible verses from the repository if not already initialized.
  /// Throws [BibleSearchException] if loading fails.
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

  /// Searches for verses by word or phrase, and ignoring accents, case, and punctuation.
  /// Returns a list of [BibleVerseModel] matching the query.
  /// Throws [BibleSearchException] if search fails.
  List<BibleVerseModel> buscar(String query) {
    try {
      if (query.isEmpty || !_initialized) return [];

      final normalizedQuery = _normalize(query);
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

      if (queryWords.isEmpty) return [];

      return _versiculos.where((v) {
        final normalizedTexto = _normalize(v.texto);
        final normalizedLivro = _normalize(v.livro);

        final textoWords = normalizedTexto.split(RegExp(r'\s+'));
        final livroWords = normalizedLivro.split(RegExp(r'\s+'));

        return queryWords.any((word) =>
            textoWords.contains(word) || livroWords.contains(word));
      }).toList();
    } catch (e) {
      throw BibleSearchException(ChatMessagesConstants.errorSearch);
    }
  }

  /// Normalizes text: lowercase, removes accents and punctuation.
  String _normalize(String text) {
    String temp = text.toLowerCase();
    temp = removeDiacritics(temp);
    temp = temp.replaceAll(RegExp(r'[^\w\s]'), '');
    return temp;
  }
}