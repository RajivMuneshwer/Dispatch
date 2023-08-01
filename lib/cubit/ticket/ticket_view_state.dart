part of 'ticket_view_cubit.dart';

@immutable
abstract class TicketViewState {}

class TicketViewInitial extends TicketViewState {}

class TicketViewLoading extends TicketViewState {}

abstract class TicketViewEditable extends TicketViewState {
  final List<List<String>> formLayoutList;
  TicketViewEditable({required this.formLayoutList});
}

class TicketViewAdded extends TicketViewEditable {
  TicketViewAdded({required super.formLayoutList});
}

class TicketViewDeleted extends TicketViewEditable {
  TicketViewDeleted({required super.formLayoutList});
}

abstract class TicketViewNotEditable extends TicketViewState {
  final List<List<String>> formLayoutList;
  final Color colors;
  TicketViewNotEditable({
    required this.formLayoutList,
    required this.colors,
  });
}

class TicketViewCanceled extends TicketViewNotEditable {
  TicketViewCanceled({
    required super.formLayoutList,
    super.colors = Colors.red,
  });
}

class TicketViewConfirmed extends TicketViewNotEditable {
  TicketViewConfirmed({
    required super.formLayoutList,
    super.colors = Colors.green,
  });
}

class TicketViewError extends TicketViewState {}
