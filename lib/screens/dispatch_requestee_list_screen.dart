import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatch/cubit/msgInfo/msg_info_cubit.dart';
import 'package:dispatch/database/dispatcher_message_info_database.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class DispatcherHomeScreen extends StatefulWidget {
  final Dispatcher dispatcher;
  const DispatcherHomeScreen({
    super.key,
    required this.dispatcher,
  });

  @override
  State<DispatcherHomeScreen> createState() => _DispatcherHomeScreenState();
}

class _DispatcherHomeScreenState extends State<DispatcherHomeScreen> {
  int currentIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    screens = [
      RequesteeInfoList(
        dispatcher: widget.dispatcher,
      ),
      DriverInfoList(
        dispatcher: widget.dispatcher,
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: StyleProvider(
        style: NavStyle(),
        child: ConvexAppBar(
          color: Settings.onPrimary,
          backgroundColor: Settings.primaryColor,
          curveSize: 75,
          top: -20,
          style: TabStyle.react,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            TabItem(
              icon: FontAwesomeIcons.user,
              title: 'Requestees',
            ),
            TabItem(
              icon: FontAwesomeIcons.carSide,
              title: 'Drivers',
            ),
          ],
        ),
      ),
    );
  }
}

class NavStyle extends StyleHook {
  @override
  double get activeIconMargin => 0;

  @override
  double get activeIconSize => 30;

  @override
  double? get iconSize => 20;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 14, color: color);
  }
}

const duration = Duration(microseconds: 100);

class DriverInfoList extends StatefulWidget {
  final Dispatcher dispatcher;
  const DriverInfoList({
    super.key,
    required this.dispatcher,
  });

  @override
  State<DriverInfoList> createState() => _DriverInfoListState();
}

class _DriverInfoListState extends State<DriverInfoList> {
  List<StreamSubscription<DatabaseEvent>> subscriptions = [];

  @override
  void dispose() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drivers"),
      ),
      body: BlocProvider(
        create: (context) => MsgInfoCubit(
          dispatcherMessageInfoDatabase:
              DispatcherMessageInfoDatabase(dispatcher: widget.dispatcher),
        ),
        child: BlocBuilder<MsgInfoCubit, MsgInfoState>(
          builder: (context, state) {
            switch (state) {
              case MsgInfoInitial():
                subscriptions =
                    context.read<MsgInfoCubit>().driverOnChangedSub();

                context.read<MsgInfoCubit>().loadDrivers();
                return Container();

              case MsgInfoLoaded():
                return InfoList(
                    users: state.users,
                    onTapForUser: (user) => () {
                          decreaseAmntOfSentMessages(
                            receiver: widget.dispatcher,
                            sender: user,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DispatcherMessageScreen<Driver>(
                                dispatcher: widget.dispatcher,
                                receiver: (user as Driver),
                              ),
                            ),
                          );
                        });
            }
          },
        ),
      ),
    );
  }
}

class RequesteeInfoList extends StatefulWidget {
  final Dispatcher dispatcher;
  const RequesteeInfoList({
    super.key,
    required this.dispatcher,
  });

  @override
  State<RequesteeInfoList> createState() => _RequesteeInfoListState();
}

class _RequesteeInfoListState extends State<RequesteeInfoList> {
  List<StreamSubscription<DatabaseEvent>> subscriptions = [];

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requestees")),
      body: BlocProvider(
        create: (context) => MsgInfoCubit(
          dispatcherMessageInfoDatabase:
              DispatcherMessageInfoDatabase(dispatcher: widget.dispatcher),
        ),
        child: BlocBuilder<MsgInfoCubit, MsgInfoState>(
          builder: (context, state) {
            switch (state) {
              case MsgInfoInitial():
                subscriptions =
                    context.read<MsgInfoCubit>().requesteeOnChangeSub();

                context.read<MsgInfoCubit>().loadRequestees();
                return Container();

              case MsgInfoLoaded():
                return InfoList(
                  users: state.users,
                  onTapForUser: (user) => () {
                    decreaseAmntOfSentMessages(
                      receiver: widget.dispatcher,
                      sender: user,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DispatcherMessageScreen<Requestee>(
                          dispatcher: widget.dispatcher,
                          receiver: (user as Requestee),
                        ),
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class InfoList extends StatelessWidget {
  final List<User> users;
  final void Function() Function(User) onTapForUser;
  const InfoList({super.key, required this.users, required this.onTapForUser});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user_ = users[index];
        return UserProfileRowV2(
          onTap: onTapForUser(users[index]),
          children: MessageInfoRowFactory().make(user_),
        );
      },
    );
  }
}

void decreaseAmntOfSentMessages({
  required User receiver,
  required User sender,
}) {
  var receiver_ = receiver;
  if (receiver_ is! Dispatcher) {
    return;
  }

  FirebaseFunctions.instance.httpsCallable('decreaseMessageSent').call({
    "companyid": Settings.companyid,
    "designation": switch (sender) {
      Requestee() => "requestees",
      Dispatcher() => "dispatchers",
      Driver() => "drivers",
      Admin() => "admin",
      BaseUser() => "base"
    },
    "dispatcherid": receiver_.id,
    "designateeid": sender.id,
  });
}
