part of 'messages_view_cubit.dart';

@immutable
abstract class MessagesViewState {
  final User user;
  final User other;
  final MessageDatabase database;
  const MessagesViewState({
    required this.user,
    required this.database,
    required this.other,
  });
}

class MessagesViewInitial extends MessagesViewState {
  const MessagesViewInitial({
    required super.database,
    required super.user,
    required super.other,
  });
}

class MessagesViewLoading extends MessagesViewState {
  const MessagesViewLoading({
    required super.database,
    required super.user,
    required super.other,
  });
}

class MessagesViewLoaded extends MessagesViewState {
  final List<Message> messages;
  const MessagesViewLoaded({
    required this.messages,
    required super.user,
    required super.other,
    required super.database,
  });
}

class MessagesViewError extends MessagesViewState {
  const MessagesViewError({
    required super.other,
    required super.database,
    required super.user,
  });
}
