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
    print(ticketViewWithData.formLayoutList);
    return BlocProvider(
      create: (context) => TicketViewCubit(ticketViewWithData),
      child: Scaffold(
        appBar: ticketAppBar(context),
        body: DispatchForm(),
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
///
///
///
///COMPLETE
///fix the new ticket state to loaded ticket
///make the round trip state
///Make animations
///put a cancel button at the top
///
///COMPLETE August 3
///update the ticket in realtime to cancelled or with more/less info
///
///
//////Simplify the way the ticket is built

