class InvalidChoiceException implements Exception {
  final String message;
  InvalidChoiceException([this.message = 'Opción inválida']);
  @override
  String toString() => 'InvalidChoiceException: $message';
}
