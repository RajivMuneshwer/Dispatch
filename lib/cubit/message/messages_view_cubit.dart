import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatch/database/message_database.dart';
import 'package:dispatch/objects/app_badge.dart';
import 'package:dispatch/objects/message_objects.dart';
import 'package:dispatch/objects/num_of_unread_q.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'messages_view_state.dart';

class MessagesViewCubit extends Cubit<MessagesViewState> {
  final MessageDatabase database;
  final User receiver;
  final User other;
  final User sender;
  final int initialNumOfMessages = 10;
  final int numOfMessagesToLoadAfterInitial = 10;
  Map<int, Message> messagesMap = {};
  late int earliestMessageTime;
  bool isComplete = false;

  MessagesViewCubit(
    this.other,
    this.receiver,
    this.database,
    this.sender,
  ) : super(
          MessagesViewInitial(
            user: receiver,
            other: other,
            database: database,
          ),
        );

  List<StreamSubscription<DatabaseEvent>> loadMessages() {
    final childAddStream = database.onChildAddedStream(initialNumOfMessages);

    final StreamSubscription<DatabaseEvent> childAddSubscription =
        childAddStream.listen(
      (event) async {
        final snapshot = event.snapshot;
        Message newMessage = MessageAdaptor(
          messagesViewState: state,
        ).adaptSnapshot(snapshot);

        bool isUser = isMessageFromUser(newMessage);
        if (!isUser && newMessage.seen == false) {
          await handleMessageExternalState(newMessage);
        }

        return handleMessageInternalToState(newMessage, state);
      },
    );

    final Stream<DatabaseEvent> childUpdateStream = database.onChildChanged();

    final StreamSubscription<DatabaseEvent> childUpdateSubscription =
        childUpdateStream.listen(
      (event) {
        final snapshot = event.snapshot;
        Message updatedMessage = MessageAdaptor(
          messagesViewState: state,
        ).adaptSnapshot(snapshot);
        Message? messageInMap = messagesMap[updatedMessage.id];

        if (messageInMap == null) return;

        messagesMap[updatedMessage.id] = updatedMessage;
        emit(
          MessagesViewLoaded(
            messages: messagesMap.values.toList(),
            user: receiver,
            other: other,
            database: database,
          ),
        );
        return;
      },
    );

    return [childAddSubscription, childUpdateSubscription];
  }

  void add(Message newMessage) {
    messagesMap.addAll({newMessage.id: newMessage});
    emit(MessagesViewLoaded(
        messages: messagesMap.values.toList(),
        user: receiver,
        other: other,
        database: database));
  }

  Future<void> loadPreviousMessages() async {
    if (isComplete) {
      return;
    }
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
          user: receiver,
          other: other,
          database: database));
      return;
    }
    final msgAdaptor = MessageAdaptor(messagesViewState: state);

    List<Message> prevMsgs = previousMessagesSnapshots
        .map((msgSnap) => msgAdaptor.adaptSnapshot(msgSnap))
        .toList();
    prevMsgs.sort((m1, m2) => m1.date.compareTo(m2.date));

    earliestMessageTime = prevMsgs.first.dateToInt();

    Map<int, Message> prevMsgMap = {
      for (final msg in prevMsgs) msg.dateToInt(): msg
    };

    prevMsgMap.addAll(messagesMap);
    messagesMap = prevMsgMap;
    emit(
      MessagesViewLoaded(
        messages: messagesMap.values.toList(),
        user: receiver,
        other: other,
        database: database,
      ),
    );
    Future.forEach(prevMsgs, (msg) => handleMessageExternalState(msg));
  }

  bool isMessageFromUser(Message newMessage) {
    return switch (receiver) {
      Dispatcher() => (newMessage.isDispatch),
      _ => (!newMessage.isDispatch),
    };
  }

  Future<void> handleMessageExternalState(Message newMessage) async {
    bool isMessageFromReceiver = (newMessage.sender.id == receiver.id);
    if (isMessageFromReceiver) {
      return;
    }
    if (newMessage.seen == true) {
      return;
    }
    await decreaseAmntMessagesInfo();
    await reduceAppBadge();
    await updateMessageToSeen(newMessage);
    return;
  }

  Future<void> reduceAppBadge() async {
    final appBadge = await AppBadge.getInstance();
    await appBadgeQueue.add<void>(() => appBadge.decreaseBadgeCountBy(1));
  }

  Future<void> updateMessageToSeen(Message newMessage) async {
    var receiver_ = receiver;
    bool isMessageFromReceiver = (newMessage.sender.id == receiver.id);
    if (isMessageFromReceiver) {
      return;
    }
    if (newMessage.seen == true) {
      return;
    }
    if (receiver_ is! Dispatcher) {
      await FirebaseFunctions.instance.httpsCallable('updateMessageSeen').call(
        {
          "companyid": Settings.companyid,
          "designation": switch (receiver) {
            Requestee() => "requestees",
            Dispatcher() => "dispatchers",
            Driver() => "drivers",
            Admin() => "admin",
            BaseUser() => "base",
          },
          "designateeid": receiver.id,
          "messageid": newMessage.id,
        },
      );
    } else {
      await FirebaseFunctions.instance.httpsCallable('updateMessageSeen').call({
        "companyid": Settings.companyid,
        "designation": switch (sender) {
          Requestee() => "requestees",
          Dispatcher() => "dispatchers",
          Driver() => "drivers",
          Admin() => "admin",
          BaseUser() => "base",
        },
        "designateeid": sender.id,
        "messageid": newMessage.id,
      });
    }
  }

  Future<void> decreaseAppBadge() async {
    final appBadge = await AppBadge.getInstance();
    appBadge.decreaseBadgeCountBy(1);
  }

  void handleMessageInternalToState(
    Message newMessage,
    MessagesViewState state,
  ) {
    switch (state) {
      case MessagesViewInitial():
        {
          earliestMessageTime = newMessage.dateToInt();
          messagesMap.addAll({newMessage.id: newMessage});
          messagesMap.addAll({newMessage.id: newMessage});
          List<Message> msgList = messagesMap.values.toList();
          msgList.sort((m1, m2) => m1.date.compareTo(m2.date));
          emit(
            MessagesViewLoaded(
              messages: msgList,
              user: receiver,
              other: other,
              database: database,
            ),
          );
        }
        break;
      case MessagesViewLoaded():
        {
          Message? msg = messagesMap[newMessage.id];
          if (msg == null) {
            messagesMap.addAll({newMessage.id: newMessage});
          }
          List<Message> msgList = messagesMap.values.toList();
          msgList.sort((m1, m2) => m1.date.compareTo(m2.date));
          emit(
            MessagesViewLoaded(
              messages: msgList,
              user: receiver,
              other: other,
              database: database,
            ),
          );
        }
      case MessagesViewLoading():
        {
          break;
        }
      case MessagesViewError():
        {
          throw Exception("message state is in error.");
        }
    }
  }

  Future<void> decreaseAmntMessagesInfo() async {
    var user_ = receiver;
    if (user_ is! Dispatcher) {
      return;
    }
    Future<HttpsCallableResult<dynamic>> decAmntMsgs() async {
      return await FirebaseFunctions.instance
          .httpsCallable('decreaseMessageSent')
          .call({
        "companyid": Settings.companyid,
        "designation": switch (sender) {
          Requestee() => "requestees",
          Dispatcher() => "dispatchers",
          Driver() => "drivers",
          Admin() => "admin",
          BaseUser() => "base",
        },
        "dispatcherid": user_.id,
        "designateeid": sender.id,
      });
    }

    unreadQ.add<void>(() async {
      final result = await decAmntMsgs();
      int status = result.data["status"] as int;
      if (status == 200) {
        print("success");
        return;
      }
      print("failed");
      return;
    });

    //{companyid, designation, dispatcherid, designateeid}
  }
}
