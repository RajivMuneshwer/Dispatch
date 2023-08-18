import 'package:dispatch/models/message_models.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

abstract class GenericBubble extends StatelessWidget {
  final bool isSender;
  final String text;
  final bool tail;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final DateTime date;
  final TextStyle textStyle;

  const GenericBubble({
    Key? key,
    required this.date,
    required this.text,
    required this.isSender,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 14,
    ),
  }) : super(key: key);

  Widget bubbleMain();

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Align(
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: CustomPaint(
          painter: SpecialChatBubbleOne(
              color: color,
              alignment: isSender ? Alignment.topRight : Alignment.topLeft,
              tail: tail),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .7,
            ),
            margin: isSender
                ? stateTick
                    ? const EdgeInsets.fromLTRB(7, 7, 14, 7)
                    : const EdgeInsets.fromLTRB(7, 7, 17, 7)
                : const EdgeInsets.fromLTRB(17, 7, 7, 7),
            child: Stack(
              children: <Widget>[
                Padding(
                    padding: stateTick
                        ? const EdgeInsets.only(right: 20)
                        : const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        bubbleMain(),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          DateFormat.jm().format(date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    )),
                stateIcon != null && stateTick
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: stateIcon,
                      )
                    : const SizedBox(
                        width: 1,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextBubble extends GenericBubble {
  const TextBubble({
    super.key,
    required super.text,
    required super.date,
    required super.isSender,
    super.color,
    super.tail,
    super.textStyle,
    super.sent,
    super.seen,
    super.delivered,
  });

  @override
  Widget bubbleMain() => Text(
        text,
        style: textStyle,
        textAlign: TextAlign.left,
      );
}

class TicketBubble extends GenericBubble {
  final TicketTypes ticketTypes;
  final void Function()? onPressed;
  final Color iconColor;
  const TicketBubble({
    required super.text,
    required super.date,
    required super.isSender,
    required this.ticketTypes,
    required this.onPressed,
    required this.iconColor,
    super.textStyle,
    super.sent,
    super.seen,
    super.delivered,
    super.key,
  });

  Text ticketText() {
    Map<TicketTypes, TextDetails> ticketTypeToColorAndText = {
      TicketTypes.cancelled:
          const TextDetails(text: "Cancelled", color: Colors.red),
      TicketTypes.submitted:
          const TextDetails(text: "Submitted", color: Colors.blue),
      TicketTypes.confirmed:
          const TextDetails(text: "Confirmed", color: Colors.green),
    };
    TextDetails textDetails = ticketTypeToColorAndText[ticketTypes] ??
        const TextDetails(text: "", color: Colors.white);

    return Text(
      textDetails.text,
      style: TextStyle(color: textDetails.color),
    );
  }

  @override
  Widget bubbleMain() => Column(children: [
        MaterialButton(
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minWidth: 80,
          onPressed: onPressed,
          child: FaIcon(
            FontAwesomeIcons.ticket,
            color: iconColor,
            size: 30,
          ),
        ),
        ticketText(),
        Text(
          text,
          style: textStyle,
          textAlign: TextAlign.end,
        ),
      ]);
}

class TextDetails {
  final String text;
  final Color color;
  const TextDetails({
    required this.text,
    required this.color,
  });
}

///custom painter use to create the shape of the chat bubble
///
/// [color],[alignment] and [tail] can be changed

class SpecialChatBubbleOne extends CustomPainter {
  final Color color;
  final Alignment alignment;
  final bool tail;

  SpecialChatBubbleOne({
    required this.color,
    required this.alignment,
    required this.tail,
  });

  final double _radius = 10.0;
  final double _x = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (alignment == Alignment.topRight) {
      if (tail) {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              0,
              0,
              size.width - _x,
              size.height,
              bottomLeft: Radius.circular(_radius),
              bottomRight: Radius.circular(_radius),
              topLeft: Radius.circular(_radius),
            ),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
        var path = Path();
        path.moveTo(size.width - _x, 0);
        path.lineTo(size.width - _x, 10);
        path.lineTo(size.width, 0);
        canvas.clipPath(path);
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              size.width - _x,
              0.0,
              size.width,
              size.height,
              topRight: const Radius.circular(3),
            ),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      } else {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              0,
              0,
              size.width - _x,
              size.height,
              bottomLeft: Radius.circular(_radius),
              bottomRight: Radius.circular(_radius),
              topLeft: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
            ),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      }
    } else {
      if (tail) {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              _x,
              0,
              size.width,
              size.height,
              bottomRight: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
              bottomLeft: Radius.circular(_radius),
            ),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
        var path = Path();
        path.moveTo(_x, 0);
        path.lineTo(_x, 10);
        path.lineTo(0, 0);
        canvas.clipPath(path);
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              0,
              0.0,
              _x,
              size.height,
              topLeft: const Radius.circular(3),
            ),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      } else {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              _x,
              0,
              size.width,
              size.height,
              bottomRight: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
              bottomLeft: Radius.circular(_radius),
              topLeft: Radius.circular(_radius),
            ),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
