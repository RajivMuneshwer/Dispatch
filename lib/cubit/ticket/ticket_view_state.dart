part of 'ticket_view_cubit.dart';

@immutable
abstract class TicketViewState {}

class TicketViewInitial extends TicketViewState {}

class TicketViewLoading extends TicketViewState {}

abstract class TicketViewLoaded extends TicketViewState {
  final List<List<String>> formLayoutList;
  TicketViewLoaded({required this.formLayoutList});
}

class TicketViewAdded extends TicketViewLoaded {
  TicketViewAdded({required super.formLayoutList});
}

class TicketViewDeleted extends TicketViewLoaded {
  TicketViewDeleted({required super.formLayoutList});
}

class TicketViewNew extends TicketViewState {}

class TicketViewError extends TicketViewState {}
