import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/screens/admin_screen.dart';
import 'package:dispatch/screens/dispatch_requestee_list_screen.dart';
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

          case '/dispatch':
            return MaterialPageRoute(
                builder: (_) => const DispatchRequesteeListScreen());

          case '/ticket':
            if (args is TicketViewWithData) {
              return MaterialPageRoute(
                builder: (_) => TicketScreen(ticketViewWithData: args),
              );
            }

          case '/':
            return MaterialPageRoute(
              builder: (_) => const AdminScreen(),
            );
        }
        return null;
      },
      initialRoute: '/',
    );
  }
}
