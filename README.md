
# Asistente Bíblico 📖🤖

Asistente Bíblico es una aplicación Flutter que permite a los usuarios buscar versículos bíblicos y recibir respuestas interactivas a través de un chat amigable. Ideal para estudios, devocionales y consultas rápidas sobre la Biblia.

## ✨ Características

- 🔍 Búsqueda de versículos bíblicos por palabra clave, tema o referencia.
- 💬 Interfaz de chat para interactuar con el asistente.
- 📚 Respuestas contextuales y sugerencias de lectura.
- 📱 Compatible con Android.

## 📸 Capturas de Pantalla

<!-- Ejemplo de cómo agregar capturas de pantalla reales: -->
![Pantalla principal](assets/images/screenshot1.png)
![Chat en acción](assets/images/screenshot2.png)

<!-- Cambia los nombres de archivo y el texto alternativo según tus imágenes -->

## 🚀 Instalación

1. Clona el repositorio:
	```sh
	git clone https://github.com/madaipsantos/chat-app-android.git
	```
2. Instala las dependencias:
	```sh
	flutter pub get
	```
3. Ejecuta la app:
	```sh
	flutter run
	```

## 🛠️ Uso

- Escribe una referencia bíblica o un tema en el chat.
- El asistente responderá con el versículo.
- Ejemplo:  
  - `Juan 3:16`
  - `Amor.`
  - `Perdón`

## 📂 Estructura del Proyecto

```
├── android/                # Proyecto nativo Android
│   ├── app/
│   └── ...
├── assets/                 # Recursos estáticos (imágenes, JSON, etc.)
│   ├── images/
│   └── versiculos.json
├── lib/                    # Código fuente principal de Flutter
│   ├── main.dart           # Punto de entrada
│   ├── config/             # Configuración (temas, rutas)
│   ├── core/               # Constantes, excepciones
│   ├── data/               # Modelos de datos
│   ├── domain/             # Entidades y repositorios
│   ├── infrastructure/     # Servicios y repositorios
│   └── presentation/       # UI, pantallas, widgets, providers
├── test/                   # Pruebas unitarias y de widgets
│   └── ...
├── pubspec.yaml            # Configuración de dependencias
├── README.md
└── ...
```

## 📦 Dependencias

- [Flutter](https://flutter.dev/) (framework principal)
- [provider](https://pub.dev/packages/provider) (gestión de estado)
- [diacritic](https://pub.dev/packages/diacritic) (manejo de acentos y caracteres especiales)
- [equatable](https://pub.dev/packages/equatable) (comparación de objetos)


## 🧪 Testing

Para ejecutar los tests:
```sh
flutter test
```

## 👤 Contacto

Desarrollado por [Madai P. Santos](mailto:madaipinto@gmail.com).

---
