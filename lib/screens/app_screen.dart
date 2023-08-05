import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/screens/dispatch_message_list_screen.dart';
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
          case '/messages':
            return MaterialPageRoute(builder: (_) => const MessageScreen());

          case '/':
            return MaterialPageRoute(
                builder: (_) => const DispatchUsersListScreen());

          case '/ticket':
            if (args is TicketViewWithData) {
              return MaterialPageRoute(
                builder: (_) => TicketScreen(ticketViewWithData: args),
              );
            }
        }
        return null;
      },
      initialRoute: '/',
    );
  }
}
