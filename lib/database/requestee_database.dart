import 'package:dispatch/models/message_objects.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

class RequesteeMessagesDatabase {
  final Requestee requestee;
  const RequesteeMessagesDatabase({required this.requestee});

  DatabaseReference get ref => FirebaseDatabase.instance
      .ref("muneshwers/requestees/${requestee.id}/messages");

  Future<void> addMessage(Message message) async {
    await ref.update({message.id.toString(): message.toMap()});
  }

  Future<void> updateTicket(TicketMessage ticketMessage) async {
    await ref.child(ticketMessage.id.toString()).set(ticketMessage.toMap());
  }

  Future<DatabaseEvent> loadMessagesBeforeTime(int time, int numOfMessage) {
    return ref.orderByChild("date").endBefore(time).limitToLast(2).once();
  }

  Stream<DatabaseEvent> onChildAddedStream(int messageLimit) {
    return ref.orderByChild("date").limitToLast(messageLimit).onChildAdded;
  }

  Stream<DatabaseEvent> onChildChanged() {
    return ref.onChildChanged;
  }
}
