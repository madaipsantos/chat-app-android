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
  static const chooseOption = 'Por favor, elige una opción:';
  static const invalidChoiceOptions = 'Escribe "BUSCAR" para una nueva búsqueda.\nEscribe "VOLVER" para volver a la lista.\nEscribe "SALIR" si quieres terminar el chat.';
  static const answerYesNoExit = 'Por favor, responda "SÍ", "NO" o "SALIR".';
  static const writeTopicExample = 'Escribe lo que tengas en mente, por ejemplo: "amor", "perdón" o "Salmos 23:1".';
  static const chooseVerse = "Elige un número de la lista, o escribe una de las opciones de abajo:";
  static const listOptions = "Escribe 'BUSCAR' para una nueva búsqueda.\nEscribe 'SALIR' si quieres terminar el chat.";
  static const foundVerses = "Encontré {count} versículos:\n\n";
  static const errorOccurred = 'Ocurrió un error. Por favor, intenta de nuevo.';
  static const chatTitle = 'Asistente Bíblico';
  static const welcomeTitle = 'Bienvenido al\n Asistente Bíblico';
  static const hintEnterName = 'Introduce tu nombre';
  static const messageFieldHint = "Busca por tema, palabra o referencia bíblica…";
  static const previousPageOption = "Escribe 'ANTERIOR' para ver la página anterior.\n";
  static const nextPageOption = "Escribe 'PRÓXIMO' para ver la siguiente página.\n";
  static const firstPageAvailableActions = "Escribe 'PRÓXIMO' para ver la siguiente página.\nEscribe 'BUSCAR' para una nueva búsqueda.\nEscribe 'SALIR' si quieres terminar el chat.";
  static const lastPageNavigationOptions = "Escribe 'ANTERIOR' para ver la página anterior.\nEscribe 'BUSCAR' para una nueva búsqueda.\nEscribe 'SALIR' si quieres terminar el chat.";
  static const firstPageOptions = "Ya estás en la primera página.";
  static const lastPageOptions = "Ya estás en la última página.";
  static const errorEnterName = 'Por favor, introduzca su nombre';

  static const String errorInitChat = 'Ocurrió un error al iniciar el chat.';
  static const String errorEmptyMessage = 'El mensaje no puede estar vacío';
  static const String errorInvalidChoice = '¡Ups! Esa opción no es válida.';
  static const String errorSearch = 'Error al buscar versículos';
  static const String errorNavigation = 'No se pudo navegar a la pantalla inicial.';
  static const String errorInitService = 'Fallo al inicializar el servicio de la Biblia.';
  static const String errorMissingFields = 'Faltan campos requeridos en el versículo.';
  static const String errorWrongTypes = 'Tipos de datos incorrectos en el versículo.';
  static const String errorFormatVerse = 'Error de formato en el versículo.';
  static const String errorLoadVerses = 'Fallo al cargar los versículos.';
  
}