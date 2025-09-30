class InvalidMessageException implements Exception {
  final String message;
  InvalidMessageException([this.message = 'Mensaje inválido']);
  @override
  String toString() => 'InvalidMessageException: $message';
}
