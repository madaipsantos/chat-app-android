class DataFormatException implements Exception {
  final String message;
  DataFormatException([this.message = 'Error de formato de datos']);
  @override
  String toString() => 'DataFormatException: $message';
}
