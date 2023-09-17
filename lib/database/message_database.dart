import 'package:dispatch/objects/message_objects.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class MessageDatabase<T extends User> {
  T user;
  MessageDatabase({required this.user});
  DatabaseReference get ref;
  Future<void> sync();
  Future<void> addMessage(Message message);
  Future<void> updateTicket(TicketMessage ticketMessage);
  Future<DatabaseEvent> loadMessagesBeforeTime(int time, int numOfMessage);
  Stream<DatabaseEvent> onChildAddedStream(int messageLimit);
  Stream<DatabaseEvent> onChildChanged();
}

class RequesteesMessageDatabase extends MessageDatabase<Requestee> {
  RequesteesMessageDatabase({required super.user});

  @override
  DatabaseReference get ref => FirebaseDatabase.instance
      .ref("${Settings.companyid.toString()}/requestees/${user.id}/messages");

  @override
  Future<void> addMessage(Message message) async {
    await ref.update({message.id.toString(): message.toMap()});
  }

  @override
  Future<void> updateTicket(TicketMessage ticketMessage) async {
    await ref.child(ticketMessage.id.toString()).set(ticketMessage.toMap());
  }

  @override
  Future<DatabaseEvent> loadMessagesBeforeTime(int time, int numOfMessage) {
    return ref.orderByChild("date").endBefore(time).limitToLast(2).once();
  }

  @override
  Stream<DatabaseEvent> onChildAddedStream(int messageLimit) {
    return ref.orderByChild("date").limitToLast(messageLimit).onChildAdded;
  }

  @override
  Stream<DatabaseEvent> onChildChanged() {
    return ref.onChildChanged;
  }

  @override
  Future<void> sync() async {
    ref.keepSynced(true);
    return;
  }
}

class DriverMessageDatabase extends MessageDatabase<Driver> {
  DriverMessageDatabase({required super.user});

  @override
  DatabaseReference get ref => FirebaseDatabase.instance
      .ref("${Settings.companyid.toString()}/drivers/${user.id}/messages");

  @override
  Future<void> addMessage(Message message) async {
    await ref.update({message.id.toString(): message.toMap()});
  }

  @override
  Future<void> updateTicket(TicketMessage ticketMessage) async {
    await ref.child(ticketMessage.id.toString()).set(ticketMessage.toMap());
  }

  @override
  Future<DatabaseEvent> loadMessagesBeforeTime(int time, int numOfMessage) {
    return ref.orderByChild("date").endBefore(time).limitToLast(2).once();
  }

  @override
  Stream<DatabaseEvent> onChildAddedStream(int messageLimit) {
    return ref.orderByChild("date").limitToLast(messageLimit).onChildAdded;
  }

  @override
  Stream<DatabaseEvent> onChildChanged() {
    return ref.onChildChanged;
  }

  @override
  Future<void> sync() async {
    ref.keepSynced(true);
  }
}

class MessageDatabaseFactory<T extends User> {
  create({required T user}) {
    return switch (user) {
      Requestee() => RequesteesMessageDatabase(user: user),
      Driver() => DriverMessageDatabase(user: user),
      _ => throw Exception("user does not have database"),
    };
  }
}
