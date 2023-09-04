import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatch/database/requestee_database.dart';
import 'package:dispatch/models/message_objects.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'messages_view_state.dart';

class MessagesViewCubit extends Cubit<MessagesViewState> {
  final MessageDatabase database;
  final User user;
  final int initialNumOfMessages = 3;
  final int numOfMessagesToLoadAfterInitial = 10;
  Map<int, Message> messagesMap = {};
  late int earliestMessageTime;
  bool isComplete = false;

  MessagesViewCubit(
    this.user,
    this.database,
  ) : super(MessagesViewInitial(user: user, database: database));

  List<StreamSubscription<DatabaseEvent>> loadMessages() {
    final Stream<DatabaseEvent> childAddStream =
        database.onChildAddedStream(initialNumOfMessages);

    final StreamSubscription<DatabaseEvent> childAddSubscription =
        childAddStream.listen(
      (event) {
        final snapshot = event.snapshot;
        Message newMessage =
            MessageAdaptor(messagesViewState: state).adaptSnapshot(snapshot);

        if (state is MessagesViewInitial) {
          earliestMessageTime = newMessage.dateToInt();
          messagesMap.addAll({newMessage.id: newMessage});
          emit(MessagesViewLoaded(
            messages: messagesMap.values.toList(),
            user: user,
            database: database,
          ));
        } else if (state is MessagesViewLoaded) {
          Message? messageHypothetical = messagesMap[newMessage.id];
          if (messageHypothetical == null) {
            messagesMap.addAll({newMessage.id: newMessage});
            emit(MessagesViewLoaded(
              messages: messagesMap.values.toList(),
              user: user,
              database: database,
            ));
          } else {
            //subject to change in the future
            messageHypothetical.sent = true;
            emit(MessagesViewLoaded(
              messages: messagesMap.values.toList(),
              user: user,
              database: database,
            ));
          }
        }
      },
    );

    final Stream<DatabaseEvent> childUpdateStream = database.onChildChanged();

    final StreamSubscription<DatabaseEvent> childUpdateSubscription =
        childUpdateStream.listen(
      (event) {
        final snapshot = event.snapshot;
        Message updatedMessage =
            MessageAdaptor(messagesViewState: state).adaptSnapshot(snapshot);
        Message? messageInMap = messagesMap[updatedMessage.id];

        if (messageInMap == null) return;

        messagesMap[updatedMessage.id] = updatedMessage;
        emit(MessagesViewLoaded(
          messages: messagesMap.values.toList(),
          user: user,
          database: database,
        ));
        return;
      },
    );

    return [childAddSubscription, childUpdateSubscription];
  }

  void add(Message newMessage) {
    messagesMap.addAll({newMessage.id: newMessage});
    emit(MessagesViewLoaded(
        messages: messagesMap.values.toList(), user: user, database: database));
  }

  Future<void> loadPreviousMessages() async {
    if (!isComplete) {
      final Iterable<DataSnapshot> previousMessagesSnapshots =
          (await database.loadMessagesBeforeTime(
        earliestMessageTime,
        numOfMessagesToLoadAfterInitial,
      ))
              .snapshot
              .children;

      if (previousMessagesSnapshots.isEmpty) {
        isComplete = true;
        emit(MessagesViewLoaded(
            messages: messagesMap.values.toList(),
            user: user,
            database: database));
      } else {
        for (final snapshot in previousMessagesSnapshots) {
          Message previousMessage =
              MessageAdaptor(messagesViewState: state).adaptSnapshot(snapshot);

          earliestMessageTime =
              (previousMessage.dateToInt() < earliestMessageTime)
                  ? previousMessage.dateToInt()
                  : earliestMessageTime;

          Map<int, Message> previousMessageMap = {
            previousMessage.dateToInt(): previousMessage
          };
          previousMessageMap.addAll(messagesMap);
          messagesMap = previousMessageMap;
          emit(
            MessagesViewLoaded(
              messages: messagesMap.values.toList(),
              user: user,
              database: database,
            ),
          );
        }
      }
    }
  }
}
