import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/message_models.dart';
import 'package:dispatch/models/rnd_message_generator.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class UpdateReceipt extends Message {
  final int ticketTime;
  final int updateTime;
  late final bool isUser;
  UpdateReceipt({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required this.ticketTime,
    required this.updateTime,
  }) {
    isUser = switch (messagesViewState.user) {
      Dispatcher() => (isDispatch),
      _ => (!isDispatch),
    };
  }

  @override
  Widget build(BuildContext context) {
    String timeMade = DateFormat().add_yMMMd().add_jm().format(
          DateTime.fromMillisecondsSinceEpoch(
            ticketTime,
          ),
        );
    String timeUpdated = DateFormat().add_yMMMd().add_jm().format(
          DateTime.fromMillisecondsSinceEpoch(
            updateTime,
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "${(isUser) ? "My" : "Your"} ticket made on \n"),
            TextSpan(text: "$timeMade \n"),
            const TextSpan(text: "has been "),
            const TextSpan(
              text: "updated ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: "on\n"),
            TextSpan(text: "$timeUpdated\n"),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "updateTime": updateTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
      };
}

class CancelReceipt extends Message {
  final int cancelTime;
  final int ticketTime;
  late final bool isUser;
  CancelReceipt({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required this.cancelTime,
    required this.ticketTime,
  }) {
    isUser = switch (messagesViewState.user) {
      Dispatcher() => (isDispatch),
      _ => (!isDispatch),
    };
  }

  @override
  Widget build(BuildContext context) {
    String timeMade = DateFormat().add_yMMMd().add_jm().format(
          DateTime.fromMillisecondsSinceEpoch(
            ticketTime,
          ),
        );
    String timeCancelled = DateFormat().add_yMMMd().add_jm().format(
          DateTime.fromMillisecondsSinceEpoch(
            cancelTime,
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "${(isUser) ? "My" : "Your"} ticket made on \n"),
            TextSpan(text: "$timeMade \n"),
            const TextSpan(text: "has been "),
            const TextSpan(
              text: "cancelled ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: "on\n"),
            TextSpan(text: "$timeCancelled\n"),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "cancelTime": cancelTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
      };
}

class ConfirmReceipt extends Message {
  final String driverName;
  final int confirmTime;
  final int ticketTime;
  ConfirmReceipt({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required this.driverName,
    required this.confirmTime,
    required this.ticketTime,
  });

  @override
  Widget build(BuildContext context) {
    String timeMade = DateFormat().add_yMMMd().add_jm().format(
          DateTime.fromMillisecondsSinceEpoch(
            ticketTime,
          ),
        );
    String timeConfirmed = DateFormat().add_yMMMd().add_jm().format(
          DateTime.fromMillisecondsSinceEpoch(
            confirmTime,
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "Thank you! 🎉 🎉 \n"),
            const TextSpan(text: "Your ticket made \n"),
            TextSpan(text: "$timeMade \n"),
            const TextSpan(text: "has been "),
            const TextSpan(
              text: "confirmed ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: "on\n"),
            TextSpan(text: "$timeConfirmed\n"),
            TextSpan(text: "Your driver is $driverName \n"),
            const TextSpan(text: "Please contact on")
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "driver": driverName,
        "confirmedTime": confirmTime,
        "ticketTime": ticketTime,
        "isReceipt": true
      };
}

class TextMessage extends Message {
  TextMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
      };

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.left,
      );
}

class ErrorMessage extends Message {
  ErrorMessage({
    super.text = "Error",
    required super.date,
    super.isDispatch = false,
    super.sent = false,
    required super.messagesViewState,
  });

  @override
  // TODO: implement id
  int get id => throw UnimplementedError();

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) => const Text(
        "Error! Please contact Admin",
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.left,
      );
}

class TicketConfirmedMessage extends TicketMessage {
  final int confirmedTime;
  final String driver;
  TicketConfirmedMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.confirmed,
    super.iconColor = Colors.green,
    super.title = "Confirmed",
    required super.messagesViewState,
    required this.confirmedTime,
    required this.driver,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "ticketType": ticketTypes.name,
        "confirmedTime": confirmedTime,
        "driver": driver,
      };
}

class TicketCancelledMessage extends TicketMessage {
  final int cancelledTime;
  TicketCancelledMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.cancelled,
    super.iconColor = Colors.red,
    super.title = "Cancelled",
    required super.messagesViewState,
    required this.cancelledTime,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "ticketType": ticketTypes.name,
        "cancelledTime": cancelledTime,
      };
}

class TicketNewMessage extends TicketMessage {
  TicketNewMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.submitted,
    super.iconColor = Colors.blue,
    required super.messagesViewState,
    super.title = "New Ticket",
  });

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}

class TicketSubmittedMessage extends TicketMessage {
  TicketSubmittedMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.submitted,
    super.iconColor = Colors.blue,
    super.title = "Submitted",
    required super.messagesViewState,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "ticketType": ticketTypes.name
      };
}

sealed class TicketMessage extends Message {
  final Color iconColor;
  final TicketTypes ticketTypes;
  final String title;
  TicketMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required this.ticketTypes,
    required this.iconColor,
    required super.messagesViewState,
    required this.title,
  });

  @override
  int get id => dateToInt();

  @override
  Map<String, dynamic> toMap();

  void Function() onPressedCurry(BuildContext context) => () {
        final List<List<String>> formLayoutList =
            FormLayoutEncoder.decode(text);
        Navigator.pushNamed(
          context,
          '/ticket',
          arguments: ticketTypeToState(
            formLayoutList: formLayoutList,
            ticketTypes: ticketTypes,
            id: id,
            messageState: messagesViewState,
            ticketMessage: this,
          ),
        );
      };

  @override
  Widget build(BuildContext context) => Column(children: [
        MaterialButton(
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minWidth: 80,
          onPressed: onPressedCurry(context),
          child: FaIcon(
            FontAwesomeIcons.ticket,
            color: iconColor,
            size: 30,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: iconColor,
          ),
        ),
        Text(
          MessageGenerator.generate(
            number: text.length,
            isDispatch: isDispatch,
          ),
          textAlign: TextAlign.end,
        ),
      ]);
}

sealed class Message {
  final String text;
  final DateTime date;
  final bool isDispatch;
  final MessagesViewState messagesViewState;
  bool sent;

  Message({
    required this.text,
    required this.date,
    required this.isDispatch,
    required this.sent,
    required this.messagesViewState,
  });

  int get id => dateToInt();

  int dateToInt() {
    return date.millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap();

  Widget build(BuildContext context);
}

class MessageAdaptor {
  MessagesViewState messagesViewState;
  MessageAdaptor({
    required this.messagesViewState,
  });
  Message adaptText(String text, bool isDispatch) {
    return TextMessage(
      text: text,
      date: DateTime.now(),
      isDispatch: isDispatch,
      sent: false,
      messagesViewState: messagesViewState,
    );
  }

  Message adaptSnapshot(DataSnapshot snapshot) {
    var objectMap = snapshot.value;
    switch (objectMap) {
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "updateTime": int updateTime,
          "ticketTime": int ticketTime,
          "isReceipt": true,
        }:
        {
          return UpdateReceipt(
              text: text,
              date: DateTime.fromMillisecondsSinceEpoch(date),
              isDispatch: isDispatch,
              sent: sent,
              messagesViewState: messagesViewState,
              ticketTime: ticketTime,
              updateTime: updateTime);
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "cancelTime": int cancelTime,
          "ticketTime": int ticketTime,
          "isReceipt": true
        }:
        {
          return CancelReceipt(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
            cancelTime: cancelTime,
            ticketTime: ticketTime,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "driver": String driverName,
          "confirmedTime": int confirmTime,
          "ticketTime": int ticketTime,
          "isReceipt": true
        }:
        {
          return ConfirmReceipt(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
            driverName: driverName,
            confirmTime: confirmTime,
            ticketTime: ticketTime,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "ticketType": "submitted",
        }:
        {
          return TicketSubmittedMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "ticketType": "cancelled",
          "cancelledTime": int cancelledTime,
        }:
        {
          return TicketCancelledMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
            cancelledTime: cancelledTime,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "ticketType": "confirmed",
          "confirmedTime": int confirmedTime,
          "driver": String driver
        }:
        {
          return TicketConfirmedMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
            confirmedTime: confirmedTime,
            driver: driver,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
        }:
        {
          return TextMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
          );
        }
      case _:
        return ErrorMessage(
          date: DateTime.now(),
          messagesViewState: messagesViewState,
        );
    }
  }

  Message adaptNewTicket(TicketViewWithData ticketState) {
    String encodedFormLayout =
        FormLayoutEncoder.encode(ticketState.formLayoutList);
    final bool isDispatch = switch (ticketState.messagesState.user) {
      Dispatcher() => true,
      _ => false,
    };
    return TicketSubmittedMessage(
      text: encodedFormLayout,
      date: DateTime.now(),
      isDispatch: isDispatch,
      sent: false,
      ticketTypes: TicketTypes.submitted,
      messagesViewState: ticketState.messagesState,
    );
  }
}
