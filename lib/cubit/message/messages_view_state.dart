part of 'messages_view_cubit.dart';

@immutable
abstract class MessagesViewState {}

class MessagesViewInitial extends MessagesViewState {}

class MessagesViewLoading extends MessagesViewState {}

class MessagesViewLoaded extends MessagesViewState {
  final List<Message> messages;
  MessagesViewLoaded(this.messages);
}

class MessagesViewError extends MessagesViewState {}
