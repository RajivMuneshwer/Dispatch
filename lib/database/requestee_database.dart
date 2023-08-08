import 'package:dispatch/models/message_models.dart';
import 'package:firebase_database/firebase_database.dart';

class RequesteeDatabase {
  static String user = "test";
  static DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/$user/messages");

  Future<void> addMessage(Message message) async {
    await ref.update({
      message.id.toString(): {
        "text": message.text,
        "date": message.dateToInt(),
        "isDispatch": false,
        "sent": message.sent,
        "isTicket": message.isTicket,
        "ticketType": message.ticketType.name,
      }
    });
  }

  Future<void> updateTicketType(
      String messageID, TicketTypes ticketType) async {
    await ref.child(messageID).update({"ticketType": ticketType.name});
    return;
  }

  Future<void> updateTicketMessage(
      String messageID, String encodedTicket) async {
    await ref.child(messageID).update({"text": encodedTicket});
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
