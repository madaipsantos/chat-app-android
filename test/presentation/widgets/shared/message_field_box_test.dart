import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/presentation/widgets/shared/message_field_box.dart';
import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';

void main() {
  testWidgets('MessageFieldBox muestra el hint y envía el mensaje', (tester) async {
    String? enviado;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageFieldBox(
            onValue: (value) => enviado = value,
          ),
        ),
      ),
    );

    // El hint debe estar visible
    expect(find.text(ChatMessagesConstants.messageFieldHint), findsOneWidget);

    // Escribir texto y presionar el botón de enviar
    await tester.enterText(find.byType(TextFormField), 'Hola mundo');
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pump();

    // El callback debe haberse llamado
    expect(enviado, 'Hola mundo');
    // El campo debe estar vacío
    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.controller?.text ?? '', '');
  });

  testWidgets('MessageFieldBox no envía mensaje vacío', (tester) async {
    String? enviado;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageFieldBox(
            onValue: (value) => enviado = value,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pump();
    expect(enviado, isNull);
  });
}
