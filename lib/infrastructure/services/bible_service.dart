import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_verse_model.dart';

class BibleService {
  static List<BibleVerseModel> versiculos = [];

  static Future<void> carregarVersiculos() async {
    final String response =
        await rootBundle.loadString('assets/versiculos.json');
    final data = jsonDecode(response) as List;
    versiculos = data.map((v) => BibleVerseModel.fromJson(v)).toList();
  }

  static List<BibleVerseModel> buscar(String query) {
    query = query.toLowerCase();
    return versiculos.where((v) {
      return v.texto.toLowerCase().contains(query) ||
          v.livro.toLowerCase().contains(query);
    }).toList();
  }
}
