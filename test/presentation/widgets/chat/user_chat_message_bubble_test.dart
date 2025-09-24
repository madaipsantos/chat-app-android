import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/user_chat_message_bubble.dart';
import 'package:yes_no_app/domain/entities/message.dart';

void main() {
  testWidgets('UserChatMessageBubble displays message text correctly', (WidgetTester tester) async {
    final message = Message(
      text: 'Hello World!',
      fromWho: FromWho.userChatMessage,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserChatMessageBubble(
            message: message,
          ),
        ),
      ),
    );

    expect(find.text('Hello World!'), findsOneWidget);

    final column = tester.widget<Column>(find.byType(Column));
    expect(column.crossAxisAlignment, CrossAxisAlignment.end);

    final textWidget = tester.widget<Text>(find.text('Hello World!'));
    expect(textWidget.style?.color, Colors.white);

    expect(find.byType(SizedBox), findsOneWidget);
  });
}