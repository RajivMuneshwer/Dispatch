import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketScreen extends StatelessWidget {
  final List<List<String>> newFormLayoutList;
  const TicketScreen({
    super.key,
    required this.newFormLayoutList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ticketAppBar(context),
      body: BlocProvider(
        create: (context) => TicketViewCubit(newFormLayoutList),
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
        } else if (state is TicketViewEditable) {
          return FormList(
            formKey: _formKey,
            formLayoutList: state.formLayoutList,
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

