import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:dispatch/screens/admin_screen.dart';
import 'package:dispatch/screens/dispatch_requestee_list_screen.dart';
import 'package:dispatch/screens/driver_info_screen.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/ticket_screen.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String initialRoute(User user) {
    return switch (user) {
      Requestee() => '/requestee',
      Dispatcher() => '/dispatcher',
      Admin() => '/admin',
      Driver() => '/driver',
      BaseUser() => '/base',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Settings.primaryColor,
          onPrimary: Settings.onPrimary,
          secondary: Settings.secondaryColor,
          onSecondary: Settings.onSecondary,
          error: Colors.red,
          onError: Colors.white,
          background: Settings.primaryColor,
          onBackground: Settings.onPrimary,
          surface: Colors.white,
          onSurface: Settings.secondaryColor,
        ),
      ),
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
              builder: (_) => DriverFormScreen(
                driver: Settings.user as Driver,
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
