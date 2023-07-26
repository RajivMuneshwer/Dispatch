import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => TicketViewCubit([]),
        child: Scaffold(
          appBar: ticketAppBar(),
          body: DispatchForm(),
        ),
      ),
    );
  }
}

AppBar ticketAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    title: const Padding(
      padding: EdgeInsets.only(
        left: 16.0,
      ),
      child: Text(
        "Ticket",
        style: TextStyle(
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {},
        child: const Text(
          "Cancel",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w400,
            fontSize: 14.5,
          ),
        ),
      ),
      const SizedBox(
        width: 20,
      ),
    ],
  );
}

class DispatchForm extends StatelessWidget {
  DispatchForm({super.key});

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    const lineOffset = 0.05;
    final double xOffset = MediaQuery.of(context).size.width * lineOffset;
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is TicketViewInitial) {
          context.read<TicketViewCubit>().initialize();
          return loading();
        } else if (state is TicketViewLoaded) {
          return FormList(
            formKey: _formKey,
            formLayoutList: state.formLayoutList,
            xOffset: xOffset,
          );
        } else {
          return loading();
        }
      },
    );
  }
}
////TODO
///
///COMPLETE
///fix the new ticket state to loaded ticket
///make the round trip state
///Make animations
///put a cancel button at the top

