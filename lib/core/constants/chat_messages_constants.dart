class ChatMessagesConstants {
  static const welcomeMessages = [
    'Holá{userName}! Soy tu asistente bíblico personal.',
    'En cualquier momento, puedes escribir: ',
    'Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "SALIR" si quieres salir del chat.',
    '¿Quieres buscar un versículo bíblico?',
    'Escribe lo que tienes en mente, por ejemplo: "amor", "perdón" o "Salmo 23:1".',
  ];

  static const farewellMessages = [
    '¡Hasta luego!',
    'Gracias por usar el asistente bíblico.',
  ];

  static const searchPrompt = 'Escribe el tema o versículo que deseas buscar.';
  static const loadingVerses = 'Cargando versos, por favor espere...';
  static const notFound = 'No se encontraron versículos para "{query}".';
  static const invalidOption = '¡Ups! Esa opción no es válida.';
  static const chooseOption = 'Por favor, elige una opción:';
  static const invalidChoiceOptions =
      'Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "SALIR" si quieres terminar el chat.';
  static const answerYesNoExit = 'Por favor, responda "SÍ", "NO" o "SALIR".';
  static const writeTopicExample =
      'Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".';
  static const chooseVerse =
      "Por favor, elige un número de la lista para ver el versículo completo, o escribe una de las opciones de abajo.";
  static const listOptions =
      "Escribe 'BUSCAR' para una nueva búsqueda.\nEscribe 'SALIR' si quieres terminar el chat.";
  static const foundVerses = "Encontré {count} versículos:\n\n";
  static const errorOccurred = 'Ocurrió un error. Por favor, intenta de nuevo.';
}
