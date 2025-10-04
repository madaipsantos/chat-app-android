import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:asistente_biblico/data/models/bible_verse_model.dart';
import 'package:asistente_biblico/domain/repositories/bible_repository.dart';

/// Implementation of [BibleRepository] that loads verses from a local JSON asset.
class BibleRepositoryImpl implements BibleRepository {
  /// Loads all Bible verses from the local JSON file.
  ///
  /// Throws an [Exception] if loading or parsing fails.
  @override
  Future<List<BibleVerseModel>> getAllVerses() async {
    try {
      final String response = await rootBundle.loadString('assets/versiculos.json');
      final data = jsonDecode(response) as List;
      return data.map((v) => BibleVerseModel.fromJson(v)).toList();
    } catch (e) {
      throw Exception('${ChatMessagesConstants.errorLoadVerses}: $e');
    }
  }
}