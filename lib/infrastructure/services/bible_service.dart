import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_verse_model.dart';
import 'package:diacritic/diacritic.dart'; // para remover acentos

class BibleService {
  static List<BibleVerseModel> versiculos = [];

  /// Carrega o JSON dos assets
  static Future<void> carregarVersiculos() async {
    final String response =
        await rootBundle.loadString('assets/versiculos.json');
    final data = jsonDecode(response) as List;
    versiculos = data.map((v) => BibleVerseModel.fromJson(v)).toList();
  }

  /// Busca por palavra ou frase, ignorando acentos, maiúsculas e pontuação
  static List<BibleVerseModel> buscar(String query) {
    final normalizedQuery = _normalize(query);

    return versiculos.where((v) {
      final normalizedTexto = _normalize(v.texto);
      final normalizedLivro = _normalize(v.livro);
      // Retorna true se o versículo contém qualquer palavra da query
      final queryWords = normalizedQuery.split(' ');
      return queryWords.any((word) =>
          normalizedTexto.contains(word) || normalizedLivro.contains(word));
    }).toList();
  }

  /// Normaliza texto: minúsculas, remove acentos e pontuação
  static String _normalize(String text) {
    String temp = text.toLowerCase();
    temp = removeDiacritics(temp); // remove acentos
    temp = temp.replaceAll(RegExp(r'[^\w\s]'), ''); // remove pontuação
    return temp;
  }
}
