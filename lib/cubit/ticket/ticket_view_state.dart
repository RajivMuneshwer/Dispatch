part of 'ticket_view_cubit.dart';

@immutable
abstract class TicketViewState {}

class TicketViewInitial extends TicketViewState {}

class TicketViewLoading extends TicketViewState {}

class TicketViewWithData extends TicketViewState {
  final List<List<String>> formLayoutList;
  final int id;
  final Color color;
  final bool enabled;
  final bool animate;
  final BottomButtonType bottomButtonType;
  TicketViewWithData({
    required this.formLayoutList,
    required this.id,
    required this.color,
    required this.enabled,
    required this.animate,
    required this.bottomButtonType,
  });
}

class TicketViewSubmitted extends TicketViewWithData {
  TicketViewSubmitted({
    required super.formLayoutList,
    required super.id,
    super.color = Colors.blue,
    super.enabled = true,
    super.animate = true,
    super.bottomButtonType = BottomButtonType.cancelOrUpdate,
  });
}

class TicketViewCanceled extends TicketViewWithData {
  TicketViewCanceled({
    required super.formLayoutList,
    required super.id,
    super.color = Colors.red,
    super.animate = false,
    super.enabled = false,
    super.bottomButtonType = BottomButtonType.none,
  });
}

class TicketViewConfirmed extends TicketViewWithData {
  TicketViewConfirmed({
    required super.formLayoutList,
    required super.id,
    super.color = Colors.green,
    super.animate = false,
    super.enabled = false,
    super.bottomButtonType = BottomButtonType.none,
  });
}

class TicketViewError extends TicketViewState {}

enum BottomButtonType {
  none,
  submit,
  cancelOrUpdate,
  cancelOrEditOrConfirm,
}
