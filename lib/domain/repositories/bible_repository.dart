import '../../data/models/bible_verse_model.dart';

/// Abstract repository for loading Bible verses.
abstract class BibleRepository {
  /// Loads all Bible verses.
  Future<List<BibleVerseModel>> getAllVerses();
}