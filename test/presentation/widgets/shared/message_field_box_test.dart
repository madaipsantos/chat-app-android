import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/shared/message_field_box.dart';

void main() {
  testWidgets('MessageFieldBox shows text field with correct properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageFieldBox(
            onValue: (text) {},
          ),
        ),
      ),
    );

    // Verifica si existe un TextFormField
    expect(find.byType(TextFormField), findsOneWidget);

    // Verifica el hint text
    expect(find.text('Busca por tema, palabra o referencia bíblica…'), findsOneWidget);

    // Verifica si existe el botón de enviar
    expect(find.byIcon(Icons.send_outlined), findsOneWidget);
  });

  testWidgets('MessageFieldBox handles text input and submission', (WidgetTester tester) async {
    String? submittedText;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageFieldBox(
            onValue: (text) {
              submittedText = text;
            },
          ),
        ),
      ),
    );

    // Ingresa texto en el campo
    await tester.enterText(find.byType(TextFormField), 'Hola mundo');
    await tester.pump();

    // Simula presionar el botón de enviar
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pump();

    // Verifica que el texto fue enviado correctamente
    expect(submittedText, 'Hola mundo');

    // Verifica que el campo se limpió después del envío
    expect(find.text('Hola mundo'), findsNothing);
  });

  testWidgets('MessageFieldBox handles empty text submission', (WidgetTester tester) async {
    bool wasCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageFieldBox(
            onValue: (text) {
              wasCalled = true;
            },
          ),
        ),
      ),
    );

    // Intenta enviar texto vacío
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pump();

    // Verifica que el callback no fue llamado
    expect(wasCalled, false);
  });

  testWidgets('MessageFieldBox handles focus', (WidgetTester tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageFieldBox(
            onValue: (text) {},
            focusNode: focusNode,
          ),
        ),
      ),
    );

    // Verifica que el widget fue construido con el FocusNode
    expect(find.byType(TextFormField), findsOneWidget);

    // Verifica que el FocusNode está asociado al widget
    expect(focusNode.hasFocus, false);
    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(focusNode.hasFocus, true);
  });
}