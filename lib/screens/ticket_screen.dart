import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketScreen extends StatelessWidget {
  final TicketViewWithData ticketViewWithData;
  const TicketScreen({
    super.key,
    required this.ticketViewWithData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ticketAppBar(context),
      body: BlocProvider(
        create: (context) => TicketViewCubit(ticketViewWithData),
        child: DispatchForm(),
      ),
    );
  }
}

class DispatchForm extends StatelessWidget {
  DispatchForm({super.key});

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is TicketViewInitial) {
          context.read<TicketViewCubit>().initialize();
          return loading();
        } else if (state is TicketViewWithData) {
          return Ticket(
            formKey: _formKey,
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
///Connect the message type to the layout 
///This means that clicking on the icon in the messages
///gives the ticket in the correct state
///i.e confirmed, cancelled, submitted
///
///After the messages give the correct type layout
///the user should be able to affect the state if it is not cancelled or confirmed
///i.e the user should be able to edit it and be able to update the same message in place
///
///Connect to the database and update it
///Update the messages cubit as well
///
///COMPLETE
///fix the new ticket state to loaded ticket
///make the round trip state
///Make animations
///put a cancel button at the top
///
///
//////Simplify the way the ticket is built

