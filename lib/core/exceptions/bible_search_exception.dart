class BibleSearchException implements Exception {
  final String message;
  BibleSearchException([this.message = 'Error al buscar versículos']);
  @override
  String toString() => 'BibleSearchException: $message';
}
