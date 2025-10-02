import '../../data/models/bible_verse_model.dart';

abstract class BibleRepository {
  Future<List<BibleVerseModel>> getAllVerses();
}
