import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../models/message_models.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dispatch/models/message_bubble.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => MessagesViewCubit("test"),
        child: Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              DisplayMessagesWidget(
                controller: controller,
              ),
              NewMessageWidget(
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayMessagesWidget extends StatefulWidget {
  final ScrollController controller;

  const DisplayMessagesWidget({super.key, required this.controller});

  @override
  State<DisplayMessagesWidget> createState() => _DisplayMessagesWidgetState();
}

class _DisplayMessagesWidgetState extends State<DisplayMessagesWidget> {
  late final StreamSubscription<DatabaseEvent> sub;

  @override
  void dispose() async {
    await sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesViewCubit, MessagesViewState>(
      builder: (context, state) {
        if (state is MessagesViewInitial) {
          sub = context.read<MessagesViewCubit>().loadMessages();
          return emptyBody();
        } else if (state is MessagesViewLoaded) {
          return messageBody(context, widget.controller, state);
        } else if (state is MessagesViewLoading) {
          return loadingBody();
        } else {
          return emptyBody();
        }
      },
    );
  }
}

class NewMessageWidget extends StatefulWidget {
  final ScrollController controller;
  const NewMessageWidget({super.key, required this.controller});

  @override
  State<NewMessageWidget> createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesViewCubit, MessagesViewState>(
        builder: (context, state) {
      Future<void> submit(String text) async {
        Message newMessage = MessageAdaptor.adaptText(text);
        context.read<MessagesViewCubit>().add(newMessage);
        await FirebaseUserMessagesDatabase("test").addMessage(newMessage);
        scrollDown(widget.controller);
      }

      return MessageBar(
        onSend: (String text) async {
          if (text.isEmpty) return;
          await submit(text);
        },
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: InkWell(
              child: FaIcon(
                FontAwesomeIcons.ticket,
                color: Colors.black,
              ),
            ),
          )
        ],
      );
    });
  }
}

void scrollDown(ScrollController controller) {
  controller.animateTo(
    controller.position.maxScrollExtent,
    duration: const Duration(milliseconds: 500),
    curve: Curves.fastOutSlowIn,
  );
}

Widget emptyBody() {
  return Expanded(
    child: Column(
      children: [
        Container(),
      ],
    ),
  );
}

Widget loadingBody() => const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

Widget messageBody(BuildContext context, ScrollController controller,
    MessagesViewLoaded state) {
  return Expanded(
    child: CustomRefreshIndicator(
      builder: MaterialIndicatorDelegate(
        builder: (context, controller) {
          return refreshIndicator(context, controller);
        },
      ),
      onRefresh: context.read<MessagesViewCubit>().loadPreviousMessages,
      offsetToArmed: 100.0,
      child: groupListView(context, state, controller),
    ),
  );
}

GroupedListView<Message, DateTime> groupListView(BuildContext context,
    MessagesViewLoaded state, ScrollController controller) {
  return GroupedListView<Message, DateTime>(
    physics: const AlwaysScrollableScrollPhysics(),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
    controller: controller,
    groupHeaderBuilder: (element) => Center(
      child: Card(
        child: Text(DateFormat.yMMMd().format(element.date)),
      ),
    ),
    itemBuilder: (context, element) => (element.isTicket)
        ? ticketRendered(context, element)
        : messageRendered(context, element),
    elements: state.messages,
    groupBy: (message) =>
        DateTime(message.date.year, message.date.month, message.date.day),
  );
}

Widget refreshIndicator(BuildContext context, IndicatorController controller) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.blue,
      shape: BoxShape.circle,
    ),
    child: SizedBox(
      height: 30,
      width: 30,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: const AlwaysStoppedAnimation(Colors.white),
        value: controller.isDragging || controller.isArmed
            ? controller.value.clamp(0.0, 1.0)
            : null,
      ),
    ),
  );
}

Widget messageRendered(BuildContext context, Message element) => BubbleCustom(
      date: element.date,
      text: element.text,
      color: Colors.white,
      tail: true,
      textStyle: const TextStyle(color: Colors.black),
      sent: element.sent,
    );

Widget ticketRendered(BuildContext context, Message element) {
  return BubbleCustom(
    date: element.date,
    text: element.text,
    isTicket: true,
    textStyle: const TextStyle(
      fontSize: 12,
    ),
  );
}


//TODO

//sign in the user
//render out a design for the ticket

//find out how to change once arrrived in database
////its possible but we need to do cloud functions. I will purchase and find out later

//COMPLETED
//upload to firebase
// have the Display message widget scroll to bottom
//when creating a new user, have an initial message so there is not infinite check of context.read<MessagesCubit>().intialize("test");
// Bool from environment depends on if user is dispatcher
//react to a new message
// Click outside of the messages closes the window

//DAY 3
//always make the group list view scrollable
//remove the message on drag
// On scroll up it will load more messages.

////DAY 4
///



// class DisplayMessagesWidget extends StatefulWidget {
//   const DisplayMessagesWidget({
//     super.key,
//     required this.messages,
//   });

//   final List<Message> messages;

//   @override
//   State<DisplayMessagesWidget> createState() => _DisplayMessagesWidgetState();
// }

// class _DisplayMessagesWidgetState extends State<DisplayMessagesWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         color: secondaryColor,
//         child: GroupedListView<Message, DateTime>(
//           reverse: true,
//           order: GroupedListOrder.DESC,
//           padding: const EdgeInsets.all(8),
//           elements: widget.messages,
//           groupBy: (message) =>
//               DateTime(message.date.year, message.date.month, message.date.day),
//           groupHeaderBuilder: (Message message) => GroupHeaderCustom(
//             message: message,
//           ),
//           itemBuilder: (context, Message message) => MessageBubble(
//             message: message,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class NewMessageWidget extends StatefulWidget {
//   const NewMessageWidget({
//     super.key,
//     required this.messages,
//   });

//   final List<Message> messages;

//   @override
//   State<NewMessageWidget> createState() => _NewMessageWidgetState();
// }

// class _NewMessageWidgetState extends State<NewMessageWidget> {
//   final controller_ = TextEditingController();

//   Future<void> sendMessage() async {
//     final String text = controller_.text;
//     print(text);
//     if (text.isEmpty) return;
//     context.read<MessageCounterCubit>().increment();
//     final Message message = Message(
//         text: controller_.text,
//         date: DateTime.now(),
//         isDispatcher: false,
//         isDelivered: false,
//         isRead: false);
//     //await sendMessageToFirebase(message);
//     await sendMessageToDisplay(message);
//     print(widget.messages);
//   }

//   Future<void> sendMessageToFirebase(Message message) async {
//     DatabaseReference ref = FirebaseDatabase.instance.ref("users/test/message");
//     await ref.update({});
//   }

//   Future<void> sendMessageToDisplay(Message message) async {
//     setState(() {
//       return widget.messages.add(message);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: secondaryColor,
//       padding: const EdgeInsets.all(8),
//       child: Row(
//         children: <Widget>[
//           Container(
//             padding: const EdgeInsets.all(8),
//             child: FaIcon(
//               FontAwesomeIcons.ticket,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           const SizedBox(
//             width: 20,
//           ),
//           Expanded(
//             child: TextField(
//               controller: controller_,
//               autocorrect: true,
//               enableSuggestions: true,
//               decoration: InputDecoration(
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: secondaryColor,
//                 contentPadding: const EdgeInsets.all(12),
//                 labelText: "message",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   gapPadding: 10,
//                   borderSide: const BorderSide(width: 0),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 20,
//           ),
//           GestureDetector(
//             onTap: sendMessage,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Theme.of(context).primaryColor,
//               ),
//               child: const Icon(
//                 Icons.send,
//                 color: Colors.white,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class Message {
//   final String text;
//   final DateTime date;
//   final bool isDispatcher;
//   final bool isDelivered;
//   final bool isRead;

//   const Message({
//     required this.text,
//     required this.date,
//     required this.isDispatcher,
//     required this.isDelivered,
//     required this.isRead,
//   });
// }

// class MessageBubble extends StatefulWidget {
//   const MessageBubble({
//     super.key,
//     required this.message,
//   });

//   final Message message;

//   @override
//   State<MessageBubble> createState() => _MessageBubbleState();
// }

// class _MessageBubbleState extends State<MessageBubble> {
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: widget.message.isDispatcher
//           ? Alignment.centerLeft
//           : Alignment.centerRight,
//       child: Card(
//         color: widget.message.isDispatcher
//             ? const Color.fromRGBO(130, 130, 130, 1)
//             : Theme.of(context).primaryColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         elevation: 8,
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 250,
//                   minWidth: 100,
//                 ),
//                 child: Text(
//                   widget.message.text,
//                   style: const TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 5,
//               bottom: 3,
//               child: Row(
//                 children: <Widget>[
//                   Text(
//                     DateFormat.jm().format(widget.message.date),
//                     style: TextStyle(
//                       color: Colors.grey.shade300,
//                       fontSize: 10,
//                     ),
//                   ),
//                   if (!widget.message.isDispatcher)
//                     if (widget.message.isDelivered == false)
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                         child: FaIcon(
//                           FontAwesomeIcons.check,
//                           color: Colors.grey.shade300,
//                           size: 10,
//                         ),
//                       )
//                     else if (widget.message.isDelivered == true &&
//                         widget.message.isRead == false)
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                         child: FaIcon(
//                           FontAwesomeIcons.checkDouble,
//                           color: Colors.grey.shade300,
//                           size: 10,
//                         ),
//                       )
//                     else if (widget.message.isDelivered == true &&
//                         widget.message.isRead == true)
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//                         child: FaIcon(
//                           FontAwesomeIcons.checkDouble,
//                           color: Colors.black.withOpacity(0.875),
//                           size: 10,
//                         ),
//                       ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class GroupHeaderCustom extends StatefulWidget {
//   const GroupHeaderCustom({
//     super.key,
//     required this.message,
//   });

//   final Message message;

//   @override
//   State<GroupHeaderCustom> createState() => _GroupHeaderCustomState();
// }

// class _GroupHeaderCustomState extends State<GroupHeaderCustom> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 40,
//       child: Center(
//         child: Card(
//           color: Theme.of(context).primaryColor,
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Text(
//               DateFormat.yMMMd().format(widget.message.date),
//               style: TextStyle(color: Colors.grey.shade300, fontSize: 11),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// const Color primaryColor = Color.fromARGB(255, 193, 121, 39);
// const Color secondaryColor = Color.fromRGBO(220, 220, 220, 1);

// //TODO

// //log the user in with firebase auth
// //use the last number of messages to set the new messages
// //find out how to auto update the messages on the receiver's side
// //change the status of delivered and read

// //COMPLETED
// //find the last number of messages from the users
// //use bloc to increment the number of messsages