part of 'ticket_view_cubit.dart';

@immutable
abstract class TicketViewState {}

class TicketViewInitial extends TicketViewState {}

class TicketViewLoading extends TicketViewState {}

abstract class TicketViewWithData extends TicketViewState {
  final List<List<String>> formLayoutList;
  final Color color;
  final bool enabled;
  final bool animate;
  final BottomButtonType bottomButtonType;
  TicketViewWithData({
    required this.formLayoutList,
    required this.color,
    required this.enabled,
    required this.animate,
    required this.bottomButtonType,
  });
}

class TicketViewAdded extends TicketViewWithData {
  TicketViewAdded({
    required super.formLayoutList,
    super.color = Colors.blue,
    super.enabled = true,
    super.animate = true,
    super.bottomButtonType = BottomButtonType.submit,
  });
}

class TicketViewDeleted extends TicketViewWithData {
  TicketViewDeleted({
    required super.formLayoutList,
    super.color = Colors.blue,
    super.enabled = true,
    super.animate = false,
    super.bottomButtonType = BottomButtonType.submit,
  });
}

class TicketViewSubmitted extends TicketViewWithData {
  TicketViewSubmitted({
    required super.formLayoutList,
    super.animate = false,
    super.color = Colors.blue,
    super.enabled = false,
    super.bottomButtonType = BottomButtonType.cancelOrEdit,
  });
}

class TicketViewCanceled extends TicketViewWithData {
  TicketViewCanceled({
    required super.formLayoutList,
    super.color = Colors.red,
    super.animate = false,
    super.enabled = false,
    super.bottomButtonType = BottomButtonType.none,
  });
}

class TicketViewConfirmed extends TicketViewWithData {
  TicketViewConfirmed({
    required super.formLayoutList,
    super.color = Colors.green,
    super.animate = false,
    super.enabled = false,
    super.bottomButtonType = BottomButtonType.none,
  });
}

class TicketViewUpdating extends TicketViewWithData {
  TicketViewUpdating({
    required super.formLayoutList,
    super.color = Colors.blue,
    super.enabled = true,
    super.animate = true,
    super.bottomButtonType = BottomButtonType.update,
  });
}

class TicketViewError extends TicketViewState {}

enum BottomButtonType {
  none,
  submit,
  update,
  cancelOrEdit,
  cancelOrEditOrConfirm,
}


////States needed
///State needs to determine the 
///color, 
///editability, 
///animations,
///button functionality
///