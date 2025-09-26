import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/bible_verse_model.dart';

abstract class IBibleRepository {
  Future<List<BibleVerseModel>> getAllVerses();
}

class BibleRepository implements IBibleRepository {
  @override
  Future<List<BibleVerseModel>> getAllVerses() async {
    try {
      final String response = await rootBundle.loadString('assets/versiculos.json');
      final data = jsonDecode(response) as List;
      return data.map((v) => BibleVerseModel.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar versículos: $e');
    }
  }
}
