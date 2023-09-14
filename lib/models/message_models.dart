import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/message_objects.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dispatch/models/message_bubble.dart';
import 'package:url_launcher/url_launcher.dart';

class NewMessageWidget extends StatelessWidget {
  final ScrollController controller;
  const NewMessageWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesViewCubit, MessagesViewState>(
        builder: (context, state) {
      var state_ = state;
      var user = state_.user;
      bool isDispatch = switch (user) {
        Dispatcher() => true,
        _ => false,
      };
      Future<void> submit(String text) async {
        Message newMessage =
            MessageAdaptor(messagesViewState: state_).adaptText(
          text,
          state_.user,
          state_.other,
          isDispatch,
        );
        context.read<MessagesViewCubit>().add(newMessage);
        await state_.database.addMessage(newMessage);
        scrollDown(controller);
      }

      return MessageBar(
        onSend: (String text) async {
          if (text.isEmpty) return;
          await submit(text);
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              child: IconButton(
                onPressed: () {
                  var newTicket = TicketNewMessage(
                    text: "",
                    date: DateTime.now(),
                    isDispatch: isDispatch,
                    sent: false,
                    seen: false,
                    delivered: false,
                    messagesViewState: state_,
                    sender: state_.user,
                    receiver: state_.other,
                  );
                  Navigator.pushNamed(context, '/ticket',
                      arguments: TicketViewWithData(
                        formLayoutList: getNewTicketLayout(),
                        ticketMessage: newTicket,
                        messagesState: state_,
                        color: Settings.primaryColor,
                        animate: true,
                      ));
                },
                icon: FaIcon(
                  FontAwesomeIcons.ticket,
                  color: Settings.primaryColor,
                ),
              ),
            ),
          )
        ],
        sendButtonColor: Settings.primaryColor,
      );
    });
  }
}

GroupedListView<Message, DateTime> groupListView(
  BuildContext context,
  MessagesViewLoaded state,
  ScrollController controller,
) {
  return GroupedListView<Message, DateTime>(
    sort: false,
    physics: const AlwaysScrollableScrollPhysics(),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
    controller: controller,
    groupHeaderBuilder: (element) => DateTimeCard(element: element),
    itemBuilder: (BuildContext context, Message message) =>
        MessageBubble(message: message),
    elements: state.messages,
    groupBy: (message) =>
        DateTime(message.date.year, message.date.month, message.date.day),
  );
}

class DateTimeCard extends StatelessWidget {
  final Message element;
  const DateTimeCard({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(customDateString(element.date)),
        ),
      ),
    );
  }
}

String customDateString(DateTime? date) {
  DateTime now = DateTime.now();
  DateTime todayDateTime = DateTime(now.year, now.month, now.day);
  String text = "";
  var date_ = date;
  if (date_ == null) return text;
  if (date_.isAfter(todayDateTime)) {
    text = "Today";
    return text;
  } else {
    Duration difference = todayDateTime.difference(date_);
    if (difference.inDays == 0) {
      text = "Yesterday";
      return text;
    } else if (difference.inDays <= 7) {
      text = "${difference.inDays} days ago";
      return text;
    } else {
      text = DateFormat.yMMMd().format(date_);
      return text;
    }
  }
}

void scrollDown(ScrollController controller) {
  controller.animateTo(
    controller.position.maxScrollExtent,
    duration: const Duration(milliseconds: 500),
    curve: Curves.fastOutSlowIn,
  );
}

Widget messageEmptyBody() {
  return Expanded(
    child: Column(
      children: [
        Container(),
      ],
    ),
  );
}

Widget messageLoadingBody() => const Expanded(
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
          return RefreshIndicator(
            controller: controller,
          );
        },
      ),
      onRefresh: context.read<MessagesViewCubit>().loadPreviousMessages,
      offsetToArmed: 100.0,
      child: groupListView(context, state, controller),
    ),
  );
}

class RefreshIndicator extends StatelessWidget {
  final IndicatorController controller;
  const RefreshIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Settings.secondaryColor,
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
}

Widget refreshIndicator(BuildContext context, IndicatorController controller) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Settings.secondaryColor,
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

enum TicketTypes {
  submitted,
  cancelled,
  confirmed,
}

TicketViewWithData ticketTypeToState({
  required TicketTypes ticketTypes,
  required List<List<String>> formLayoutList,
  required MessagesViewState messageState,
  required TicketMessage ticketMessage,
  required int id,
}) =>
    switch (ticketTypes) {
      TicketTypes.submitted => TicketViewSubmitted(
          formLayoutList: formLayoutList,
          ticketMessage: ticketMessage,
          messagesState: messageState,
        ),
      TicketTypes.cancelled => TicketViewCanceled(
          formLayoutList: formLayoutList,
          ticketMessage: ticketMessage,
          messagesState: messageState,
        ),
      TicketTypes.confirmed => TicketViewConfirmed(
          formLayoutList: formLayoutList,
          ticketMessage: ticketMessage,
          messagesState: messageState),
    };

class CallButton extends StatelessWidget {
  final User user;
  const CallButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
        onPressed: () async {
          var tel = user.tel;
          if (tel == null) return;
          final Uri url = Uri.parse("tel:${tel.international}");
          if (await canLaunchUrl(url)) {
            launchUrl(url);
          }
        },
        icon: const FaIcon(
          FontAwesomeIcons.phone,
          color: Colors.white,
          size: 18,
        ));
  }
}
