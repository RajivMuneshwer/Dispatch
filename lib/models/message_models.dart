import 'package:firebase_database/firebase_database.dart';

class Message {
  final String text;
  final DateTime date;
  final bool isDispatch;
  final bool isTicket;
  bool sent;

  Message({
    required this.text,
    required this.date,
    required this.isDispatch,
    required this.sent,
    required this.isTicket,
  });
}

class FirebaseObject extends Object {
  final String text;
  final int date;
  final bool isDispatch;
  final bool isTicket;
  final bool sent;

  FirebaseObject(
    this.text,
    this.date,
    this.isDispatch,
    this.sent,
    this.isTicket,
  );
}

class MessageAdaptor {
  static Message adaptText(String text) {
    return Message(
      text: text,
      date: DateTime.now(),
      isDispatch: false,
      sent: false,
      isTicket: false,
    );
  }

  static Message adaptFirebaseObject(FirebaseObject firebaseObject) {
    return Message(
      text: firebaseObject.text,
      date: DateTime.fromMillisecondsSinceEpoch(firebaseObject.date),
      isDispatch: firebaseObject.isDispatch,
      sent: firebaseObject.sent,
      isTicket: firebaseObject.isTicket,
    );
  }

  static Message adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> objectMap = snapshot.value as Map<dynamic, dynamic>;
    return Message(
      text: objectMap["text"] as String,
      date: DateTime.fromMillisecondsSinceEpoch(objectMap["date"] as int),
      isDispatch: objectMap["isDispatch"] as bool,
      sent: objectMap["sent"] as bool,
      isTicket: objectMap["isTicket"] as bool,
    );
  }
}

class FirebaseObjectAdaptor {
  static FirebaseObject adaptMessage(Message message) {
    return FirebaseObject(
      message.text,
      message.date.millisecondsSinceEpoch,
      message.isDispatch,
      message.sent,
      message.isTicket,
    );
  }

  static FirebaseObject adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> objectMap = snapshot.value as Map<dynamic, dynamic>;
    return FirebaseObject(
      objectMap["text"] as String,
      objectMap["date"] as int,
      objectMap["isDispatch"] as bool,
      objectMap["sent"] as bool,
      objectMap["isTicket"] as bool,
    );
  }
}

class FirebaseUserMessagesDatabase {
  final String user;
  FirebaseUserMessagesDatabase(this.user);

  DatabaseReference get ref =>
      FirebaseDatabase.instance.ref("users/$user/messages");

  Future<void> addMessage(Message message) async {
    final firebaseObject = FirebaseObjectAdaptor.adaptMessage(message);
    await ref.push().set({
      "text": firebaseObject.text,
      "date": firebaseObject.date,
      "isDispatch": false,
      "sent": firebaseObject.sent,
      "isTicket": firebaseObject.isTicket,
    });
  }
}
