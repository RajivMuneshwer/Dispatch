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
  final RequesteeMessagesDatabase database;
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

////TODO
///Fix the date card on the messages
///make a login screen
///make some class that has static variables that effectively sign the user in
///add the phone numbers to the dispatcher and the requestees
///add a little space between profile picture and name
///make receipt
///
///
///
///COMPLETED Aug 19
///Fixed the inability to reload once already loaded
///Fix that the tickets pop up on the user's side and not the dispatcher's
///Fix the random messages for the dispatcher
///Put the name and profile picture of the requestee
///Make the dispatcher able to confirm the ticket
///Fix the ticket color
///re-write the ticket parsing, but how? With a data structure? with json and json parsing.
///Put a time stamp when the ticket was completed
///Put a widget to chose the driver but where? We need to create the driver user 
///