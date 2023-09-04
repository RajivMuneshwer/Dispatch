import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/admin_screen.dart';
import 'package:dispatch/screens/dispatch_requestee_list_screen.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/ticket_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  String initialRoute(User user) {
    return switch (user) {
      Requestee() => '/requestee',
      Dispatcher() => '/dispatcher',
      Admin() => '/admin',
      Driver() => '/driver',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/requestee':
            return MaterialPageRoute(
              builder: (_) => RequesteeMessageScreen(
                user: Settings.user as Requestee,
              ),
            );

          case '/driver':
            return MaterialPageRoute(
              builder: (_) => DriverMessageScreen(
                user: Settings.user as Driver,
              ),
            );

          case '/dispatcher':
            return MaterialPageRoute(
              builder: (_) => DispatcherHomeScreen(
                dispatcher: Settings.user as Dispatcher,
              ),
            );

          case '/admin':
            return MaterialPageRoute(
              builder: (_) => AdminScreen(
                admin: Settings.user as Admin,
              ),
            );

          case '/ticket':
            if (args is TicketViewWithData) {
              return MaterialPageRoute(
                builder: (_) => TicketScreen(ticketViewWithData: args),
              );
            }
        }
        return null;
      },
      initialRoute: initialRoute(Settings.user),
    );
  }
}
