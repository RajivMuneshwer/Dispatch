import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/user_objects.dart';
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
          case '/message':
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

          case '/all':
            if (args
                case {
                  "type": UserType userType,
                  "database": AppDatabase database,
                  "title": String title
                }) {
              return MaterialPageRoute(
                  builder: (_) => switch (userType) {
                        UserType.admin => AllUserListScreen<Admin>(
                            database: database,
                            title: title,
                          ),
                        UserType.dispatcher => AllUserListScreen<Dispatcher>(
                            database: database,
                            title: title,
                          ),
                        UserType.requestee => AllUserListScreen<Requestee>(
                            database: database,
                            title: title,
                          ),
                        UserType.error => errorScreen(context),
                      });
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
