import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/message_models.dart';
import 'package:dispatch/objects/car_objects.dart';
import 'package:dispatch/utils/rnd_message_generator.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateReceipt extends Message {
  final int ticketTime;
  final int updateTime;
  late final bool isUser;
  UpdateReceipt({
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required this.ticketTime,
    required this.updateTime,
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
  }) {
    isUser = (messagesViewState.user.id == sender.id);
  }

  @override
  Widget toWidget(BuildContext context) {
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
            TextSpan(
              text: "${isDispatch ? "Your" : "My"} ticket made on \n"
                  "$timeMade \n"
                  "has been ",
            ),
            const TextSpan(
              text: "updated ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: "on\n $timeUpdated\n"),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "updateTime": updateTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
      };
}

class CancelReceipt extends Message {
  final int cancelTime;
  final int ticketTime;
  late final bool isUser;
  CancelReceipt({
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required this.cancelTime,
    required this.ticketTime,
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
  }) {
    isUser = switch (messagesViewState.user) {
      Dispatcher() => (isDispatch),
      _ => (!isDispatch),
    };
  }

  @override
  Widget toWidget(BuildContext context) {
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
            TextSpan(text: "${sender.name} has "),
            const TextSpan(
              text: "cancelled ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
                text: "${isDispatch ? "Your" : "My"} ticket made on \n"
                    "$timeMade \n"),
            TextSpan(text: "at\n $timeCancelled"),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "cancelTime": cancelTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
      };
}

class ConfirmDriverErrandReceipt extends Message {
  final int confirmTime;
  final int ticketTime;
  ConfirmDriverErrandReceipt({
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.sender,
    required super.messagesViewState,
    required super.seen,
    required this.confirmTime,
    required this.ticketTime,
    required super.receiver,
    required super.delivered,
  });

  @override
  Map<String, dynamic> toMap() => {
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "confirmedTime": confirmTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
      };

  @override
  Widget toWidget(BuildContext context) {
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
            const TextSpan(text: "You have been sent on an "),
            const TextSpan(
              text: "errand ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: "confirmed at \n"
                  "$timeConfirmed\n"
                  "Any questions? Contact ${sender.name} on \n",
            ),
            TextSpan(
              text: "${sender.tel?.international}",
              style: const TextStyle(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(
                      Uri.parse("tel:${sender.tel?.international}"),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class ConfirmDriverReceipt extends Message {
  final Requestee requestee;
  final Car car;
  final int confirmTime;
  final int ticketTime;
  ConfirmDriverReceipt({
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.sender,
    required super.messagesViewState,
    required super.seen,
    required this.requestee,
    required this.confirmTime,
    required this.car,
    required this.ticketTime,
    required super.receiver,
    required super.delivered,
  });

  @override
  Map<String, dynamic> toMap() => {
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "requestee": requestee.toMap(),
        "confirmedTime": confirmTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
        "car": car.toMap(),
      };

  @override
  Widget toWidget(BuildContext context) {
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
            TextSpan(
                text: "A ticket made \n"
                    "$timeMade \n"
                    "has been "),
            const TextSpan(
              text: "confirmed ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: "on\n"
                  "$timeConfirmed\n"
                  "Contact your pickup ${requestee.name} on \n",
            ),
            TextSpan(
              text: "${requestee.tel?.international}\n",
              style: const TextStyle(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(
                      Uri.parse("tel:${requestee.tel?.international}"),
                    ),
            ),
            TextSpan(text: "Car ${car.name}; license plate ${car.licensePlate}")
          ],
        ),
      ),
    );
  }
}

class ConfirmRequesteeReceipt extends Message {
  final Driver driver;
  final Car car;
  final int confirmTime;
  final int ticketTime;
  ConfirmRequesteeReceipt({
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required this.driver,
    required this.confirmTime,
    required this.ticketTime,
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
    required this.car,
  });

  @override
  Widget toWidget(BuildContext context) {
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
            TextSpan(
              text: "${isDispatch ? "Your" : "My"} ticket made \n"
                  "$timeMade \n"
                  "has been ",
            ),
            const TextSpan(
              text: "confirmed ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: "on\n"
                  "$timeConfirmed\n"
                  "Contact your driver ${driver.name} on \n",
            ),
            TextSpan(
              text: "${driver.tel?.international}\n",
              style: const TextStyle(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(
                      Uri.parse("tel:${driver.tel?.international}"),
                    ),
            ),
            TextSpan(text: "Car ${car.name}; license plate ${car.licensePlate}")
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "driver": driver.toMap(),
        "confirmedTime": confirmTime,
        "ticketTime": ticketTime,
        "isReceipt": true,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
        "car": car.toMap(),
      };
}

class TextMessage extends Message {
  final String text;
  TextMessage({
    required this.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
      };

  @override
  Widget toWidget(BuildContext context) => Text(
        text,
        textAlign: TextAlign.left,
      );
}

class TicketConfirmedMessage extends TicketMessage {
  final int confirmedTime;
  final Driver driver;
  final Requestee requestee;
  final Car car;
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
    required super.sender,
    required super.seen,
    required this.requestee,
    required this.car,
    required super.receiver,
    required super.delivered,
  });

  set setIsDispatch(bool setValue) {
    isDispatch = setValue;
  }

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "ticketType": ticketTypes.name,
        "confirmedTime": confirmedTime,
        "driver": driver.toMap(),
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
        "requestee": requestee.toMap(),
        "car": car.toMap(),
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
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "ticketType": ticketTypes.name,
        "cancelledTime": cancelledTime,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
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
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
  });

  @override
  Map<String, dynamic> toMap() {
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
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "seen": seen,
        "delivered": delivered,
        "ticketType": ticketTypes.name,
        "sender": sender.toMap(),
        "receiver": receiver.toMap(),
      };
}

sealed class TicketMessage extends Message {
  final Color iconColor;
  final TicketTypes ticketTypes;
  final String title;
  final String text;
  TicketMessage({
    required this.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required this.ticketTypes,
    required this.iconColor,
    required super.messagesViewState,
    required this.title,
    required super.sender,
    required super.seen,
    required super.receiver,
    required super.delivered,
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
  Widget toWidget(BuildContext context) => Column(children: [
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
  final User sender;
  final User receiver;
  final DateTime date;
  bool isDispatch;
  final MessagesViewState messagesViewState;
  bool sent;
  bool delivered;
  bool seen;

  Message({
    required this.date,
    required this.isDispatch,
    required this.sent,
    required this.sender,
    required this.receiver,
    required this.messagesViewState,
    required this.seen,
    required this.delivered,
  });

  int get id => dateToInt();

  int dateToInt() {
    return date.millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap();

  Widget toWidget(BuildContext context);
}

class MessageAdaptor {
  MessagesViewState messagesViewState;
  MessageAdaptor({
    required this.messagesViewState,
  });
  Message adaptText(String text, User sender, User receiver, bool isDispatch) {
    return TextMessage(
      text: text,
      date: DateTime.now(),
      isDispatch: isDispatch,
      sent: false,
      seen: false,
      delivered: false,
      sender: sender,
      receiver: receiver,
      messagesViewState: messagesViewState,
    );
  }

  Message adaptSnapshot(DataSnapshot snapshot) {
    var objectMap = snapshot.value;
    switch (objectMap) {
      case {
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "updateTime": int updateTime,
          "ticketTime": int ticketTime,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "isReceipt": true,
        }:
        {
          return UpdateReceipt(
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            delivered: delivered,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
            messagesViewState: messagesViewState,
            ticketTime: ticketTime,
            updateTime: updateTime,
            seen: seen,
          );
        }
      case {
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "cancelTime": int cancelTime,
          "ticketTime": int ticketTime,
          "isReceipt": true
        }:
        {
          return CancelReceipt(
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            seen: seen,
            delivered: delivered,
            messagesViewState: messagesViewState,
            cancelTime: cancelTime,
            ticketTime: ticketTime,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
          );
        }
      case {
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "driver": Map<dynamic, dynamic> dmap,
          "car": Map<Object?, Object?> carMap,
          "confirmedTime": int confirmTime,
          "ticketTime": int ticketTime,
          "isReceipt": true,
        }:
        {
          return ConfirmRequesteeReceipt(
              date: DateTime.fromMillisecondsSinceEpoch(date),
              isDispatch: isDispatch,
              sent: sent,
              seen: seen,
              delivered: delivered,
              messagesViewState: messagesViewState,
              driver: UserAdaptor<Driver>().adaptMap(dmap),
              confirmTime: confirmTime,
              ticketTime: ticketTime,
              sender: UserAdaptor<BaseUser>().adaptMap(sender),
              receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
              car: CarAdaptor().adaptMap(carMap));
        }
      case {
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "requestee": Map<dynamic, dynamic> rmap,
          "car": Map<Object?, Object?> carMap,
          "confirmedTime": int confirmTime,
          "ticketTime": int ticketTime,
          "isReceipt": true,
        }:
        {
          return ConfirmDriverReceipt(
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            messagesViewState: messagesViewState,
            seen: seen,
            requestee: UserAdaptor<Requestee>().adaptMap(rmap),
            confirmTime: confirmTime,
            ticketTime: ticketTime,
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
            car: CarAdaptor().adaptMap(carMap),
            delivered: delivered,
          );
        }
      case {
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "confirmedTime": int confirmTime,
          "ticketTime": int ticketTime,
          "isReceipt": true,
        }:
        {
          return ConfirmDriverErrandReceipt(
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            messagesViewState: messagesViewState,
            seen: seen,
            confirmTime: confirmTime,
            ticketTime: ticketTime,
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
            delivered: delivered,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "ticketType": "submitted",
        }:
        {
          return TicketSubmittedMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            seen: seen,
            delivered: delivered,
            messagesViewState: messagesViewState,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "ticketType": "cancelled",
          "cancelledTime": int cancelledTime,
        }:
        {
          return TicketCancelledMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            seen: seen,
            delivered: delivered,
            messagesViewState: messagesViewState,
            cancelledTime: cancelledTime,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
          "ticketType": "confirmed",
          "confirmedTime": int confirmedTime,
          "driver": Map<Object?, Object?> driver,
          "requestee": Map<Object?, Object?> requestee,
          "car": Map<Object?, Object?> car,
        }:
        {
          return TicketConfirmedMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            seen: seen,
            delivered: delivered,
            messagesViewState: messagesViewState,
            confirmedTime: confirmedTime,
            driver: UserAdaptor<Driver>().adaptMap(driver),
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
            requestee: UserAdaptor<Requestee>().adaptMap(requestee),
            car: CarAdaptor().adaptMap(car),
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "seen": bool seen,
          "delivered": bool delivered,
          "sender": Map<Object?, Object?> sender,
          "receiver": Map<Object?, Object?> receiver,
        }:
        {
          return TextMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            seen: seen,
            delivered: delivered,
            messagesViewState: messagesViewState,
            sender: UserAdaptor<BaseUser>().adaptMap(sender),
            receiver: UserAdaptor<BaseUser>().adaptMap(receiver),
          );
        }
      case _:
        {
          throw Exception("not valid message type");
        }
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
      seen: false,
      delivered: false,
      ticketTypes: TicketTypes.submitted,
      messagesViewState: ticketState.messagesState,
      sender: ticketState.messagesState.user,
      receiver: ticketState.messagesState.other,
    );
  }
}
