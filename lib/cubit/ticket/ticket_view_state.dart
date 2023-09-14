part of 'ticket_view_cubit.dart';

@immutable
abstract class TicketViewState {}

class TicketViewInitial extends TicketViewState {}

class TicketViewLoading extends TicketViewState {}

class TicketViewWithData extends TicketViewState {
  final List<List<String>> formLayoutList;
  final TicketMessage ticketMessage;
  final Color color;
  final bool animate;
  final MessagesViewState messagesState;
  TicketViewWithData({
    required this.formLayoutList,
    required this.ticketMessage,
    required this.color,
    required this.animate,
    required this.messagesState,
  });
}

class TicketViewSubmitted extends TicketViewWithData {
  TicketViewSubmitted({
    required super.formLayoutList,
    required super.ticketMessage,
    required super.messagesState,
    super.color = const Color(0xff2D569B),
    super.animate = true,
  });
}

class TicketViewCanceled extends TicketViewWithData {
  TicketViewCanceled({
    required super.formLayoutList,
    required super.ticketMessage,
    required super.messagesState,
    super.color = Colors.red,
    super.animate = false,
  });
}

class TicketViewConfirmed extends TicketViewWithData {
  TicketViewConfirmed({
    required super.formLayoutList,
    required super.ticketMessage,
    required super.messagesState,
    super.color = Colors.green,
    super.animate = false,
  });
}

class TicketViewError extends TicketViewState {}
