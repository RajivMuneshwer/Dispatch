part of 'messages_view_cubit.dart';

@immutable
abstract class MessagesViewState {
  final User user;
  final MessageDatabase database;
  const MessagesViewState({required this.user, required this.database});
}

class MessagesViewInitial extends MessagesViewState {
  const MessagesViewInitial({
    required super.database,
    required super.user,
  });
}

class MessagesViewLoading extends MessagesViewState {
  const MessagesViewLoading({
    required super.database,
    required super.user,
  });
}

class MessagesViewLoaded extends MessagesViewState {
  final List<Message> messages;
  const MessagesViewLoaded({
    required this.messages,
    required super.user,
    required super.database,
  });
}

class MessagesViewError extends MessagesViewState {
  const MessagesViewError({
    required super.database,
    required super.user,
  });
}
