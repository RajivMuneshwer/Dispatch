import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/ticket_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const MessageScreen());

          case '/ticket':
            if (args is List<List<String>>) {
              return MaterialPageRoute(
                builder: (_) => TicketScreen(newFormLayoutList: args),
              );
            }
        }
        return null;
      },
      initialRoute: '/', // The initial route when the app starts
    );
  }
}
