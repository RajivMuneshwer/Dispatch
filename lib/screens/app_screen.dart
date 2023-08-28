import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/admin_screen.dart';
import 'package:dispatch/screens/dispatch_requestee_list_screen.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/ticket_screen.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/requestee':
            return MaterialPageRoute(
              builder: (_) => RequesteeMessageScreen(
                user: Requestee(
                  id: 1691793872626,
                  name: "Rajiv Muneshwer",
                  sortBy: "Rajiv Muneshwer",
                ),
                dispatcher: Dispatcher(
                  id: 1691793507356,
                  name: "Tasha",
                  sortBy: "Tasha",
                  tel: const PhoneNumber(
                    isoCode: IsoCode.GY,
                    nsn: "6082356",
                  ),
                ),
              ),
            );

          case '/':
            return MaterialPageRoute(builder: (_) => DispatcherHomeScreen());

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
                        UserType.driver => AllUserListScreen<Driver>(
                            database: database,
                            title: title,
                          ),
                        UserType.error => errorScreen(context),
                      });
            }

          case '/admin':
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
