import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../models/message_models.dart';

part 'messages_view_state.dart';

class MessagesViewCubit extends Cubit<MessagesViewState> {
  final String user;
  final int initialNumOfMessages = 3;
  Map<int, Message> messagesMap = {};
  late int earliestMessageTime;
  static bool isComplete = false;

  MessagesViewCubit(this.user) : super(MessagesViewInitial());

  StreamSubscription<DatabaseEvent> loadMessages() {
    final StreamSubscription<DatabaseEvent> sub =
        FirebaseUserMessagesDatabase(user)
            .ref
            .orderByChild("date")
            .limitToLast(initialNumOfMessages)
            .onChildAdded
            .listen(
      (event) {
        final snapshot = event.snapshot;
        Message newMessage = MessageAdaptor.adaptSnapshot(snapshot);

        if (state is MessagesViewInitial) {
          earliestMessageTime = newMessage.dateToInt();
          messagesMap.addAll({newMessage.dateToInt(): newMessage});
          emit(MessagesViewLoaded(messagesMap.values.toList()));
        } else if (state is MessagesViewLoaded) {
          Message? messageHypothetical = messagesMap[newMessage.dateToInt()];
          if (messageHypothetical == null) {
            messagesMap.addAll({newMessage.dateToInt(): newMessage});
            emit(MessagesViewLoaded(messagesMap.values.toList()));
          } else {
            //subject to change in the future
            messageHypothetical.sent = true;
            emit(MessagesViewLoaded(messagesMap.values.toList()));
          }
        }
      },
    );
    return sub;
  }

  void add(Message newMessage) {
    messagesMap.addAll({newMessage.date.millisecondsSinceEpoch: newMessage});
    emit(MessagesViewLoaded(messagesMap.values.toList()));
  }

  Future<void> loadPreviousMessages() async {
    if (!isComplete) {
      final Iterable<DataSnapshot> previousMessagesSnapshots =
          (await FirebaseUserMessagesDatabase(user)
                  .ref
                  .orderByChild("date")
                  .endBefore(earliestMessageTime)
                  .limitToLast(2)
                  .once())
              .snapshot
              .children;

      if (previousMessagesSnapshots.isEmpty) {
        isComplete = true;
        emit(MessagesViewLoaded(messagesMap.values.toList()));
      } else {
        for (final snapshot in previousMessagesSnapshots) {
          Message previousMessage = MessageAdaptor.adaptSnapshot(snapshot);

          earliestMessageTime =
              (previousMessage.dateToInt() < earliestMessageTime)
                  ? previousMessage.dateToInt()
                  : earliestMessageTime;

          Map<int, Message> previousMessageMap = {
            previousMessage.dateToInt(): previousMessage
          };
          previousMessageMap.addAll(messagesMap);
          messagesMap = previousMessageMap;
          emit(MessagesViewLoaded(messagesMap.values.toList()));
        }
      }
    }
  }
}
