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
    return BlocProvider(
      create: (context) => TicketViewCubit(ticketViewWithData),
      child: Scaffold(
        appBar: ticketAppBar(context, ticketViewWithData.ticketMessage),
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
