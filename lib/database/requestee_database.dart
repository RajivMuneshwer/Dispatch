import 'package:dispatch/models/message_objects.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class MessageDatabase<T extends User> {
  T user;
  MessageDatabase({required this.user});
  DatabaseReference get ref;
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
}

class ErrorMessageDatabase extends MessageDatabase {
  ErrorMessageDatabase({required super.user});

  @override
  Future<void> addMessage(Message message) {
    throw UnimplementedError();
  }

  @override
  Future<DatabaseEvent> loadMessagesBeforeTime(int time, int numOfMessage) {
    throw UnimplementedError();
  }

  @override
  Stream<DatabaseEvent> onChildAddedStream(int messageLimit) {
    throw UnimplementedError();
  }

  @override
  Stream<DatabaseEvent> onChildChanged() {
    throw UnimplementedError();
  }

  @override
  DatabaseReference get ref => throw UnimplementedError();

  @override
  Future<void> updateTicket(TicketMessage ticketMessage) {
    throw UnimplementedError();
  }
}

class MessageDatabaseFactory<T extends User> {
  create({required T user}) {
    return switch (user) {
      Requestee() => RequesteesMessageDatabase(user: user),
      Driver() => DriverMessageDatabase(user: user),
      _ => ErrorMessageDatabase(user: user),
    };
  }
}
