import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/message_models.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

AppBar ticketAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    title: const Padding(
      padding: EdgeInsets.only(
        left: 16.0,
      ),
      child: Text(
        "Ticket",
        style: TextStyle(
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    ),
    actions: [
      IconButton(
        iconSize: 60,
        onPressed: () {
          Navigator.pop(
            context,
          );
        },
        icon: const Text(
          "Cancel",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w400,
            fontSize: 14.5,
          ),
        ),
      ),
      const SizedBox(
        width: 20,
      ),
    ],
  );
}

class FormList extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List<List<String>> formLayoutList;
  final double xOffset;
  const FormList({
    super.key,
    required this.xOffset,
    required this.formKey,
    required this.formLayoutList,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = buildLayoutWidgets(
      xOffset: xOffset,
      formLayoutList: formLayoutList,
      formkey: formKey,
    );

    return FormBuilder(
      key: formKey,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

List<Widget> buildLayoutWidgets({
  required List<List<String>> formLayoutList,
  required GlobalKey<FormBuilderState> formkey,
  double xOffset = 0,
}) {
  ListBuilder listBuilder = ListBuilder(xOffset: xOffset);

  for (var colPos = 0; colPos < formLayoutList.length; colPos++) {
    List<String> formRowList = formLayoutList[colPos];
    if (colPos == 0) {
      listBuilder.addFirstRow(
        initialText: formRowList[textPos],
        time: int.parse(formRowList[timePos]),
      );
    } else if (colPos == formLayoutList.length - 1) {
      listBuilder.addLastRow(
        colPos: colPos,
        initialText: formRowList[textPos],
      );
    } else {
      if (formRowList[timePos] == stay()) {
        listBuilder.addStayRow(
          colPos: colPos,
          initialText: formRowList[textPos],
        );
      } else {
        listBuilder.addLeaveRow(
          colPos: colPos,
          initialText: formRowList[textPos],
          time: int.parse(
            formRowList[timePos],
          ),
        );
      }
    }
    listBuilder.addConnector();
  }
  listBuilder.addPlusButton();
  listBuilder.addVerticalSpace(10.0);
  listBuilder.addSubmitRow(formkey);

  return listBuilder.build();
}

class ListBuilder {
  final double xOffset;
  final List<Widget> children = [];

  ListBuilder({required this.xOffset});

  ListBuilder addFirstRow({required String initialText, required int time}) {
    children.add(
      FirstRow(
        initialText: initialText,
        time: time,
      ),
    );
    return this;
  }

  ListBuilder addStayRow({
    required int colPos,
    required String initialText,
  }) {
    children.add(
      StayRow(
        colPos: colPos,
        initialText: initialText,
      ),
    );
    return this;
  }

  ListBuilder addLeaveRow({
    required int colPos,
    required String initialText,
    required int time,
  }) {
    children.add(
      LeaveRow(
        colPos: colPos,
        initialText: initialText,
        time: time,
      ),
    );
    return this;
  }

  ListBuilder addLastRow({
    required int colPos,
    required String initialText,
  }) {
    children.add(
      LastRow(
        colPos: colPos,
        initialText: initialText,
      ),
    );
    return this;
  }

  ListBuilder addConnector() {
    children.add(
      ConnectingLine(xOffset: xOffset),
    );
    return this;
  }

  ListBuilder addPlusButton() {
    children.add(
      PlusButton(xOffset: xOffset),
    );
    return this;
  }

  ListBuilder addVerticalSpace(double height) {
    children.add(
      SizedBox(
        width: 0,
        height: height,
      ),
    );
    return this;
  }

  ListBuilder addSubmitRow(GlobalKey<FormBuilderState> formkey) {
    children.add(
      SubmitRow(
        formKey: formkey,
      ),
    );
    return this;
  }

  List<Widget> build() {
    return children;
  }
}

class FirstRow extends StatelessWidget {
  final int time;
  final String initialText;
  const FirstRow({
    super.key,
    required this.initialText,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Pickup",
          initialText: initialText,
          colPos: 0,
        )
        .addSpace()
        .addTimeField(
          text: "Pickup time",
          time: time,
          colPos: 0,
        )
        .addSpace()
        .addBlank()
        .build();
  }
}

class LastRow extends StatelessWidget {
  final int colPos;
  final String initialText;
  const LastRow({
    super.key,
    required this.colPos,
    required this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Dropoff $colPos",
          colPos: colPos,
          initialText: initialText,
        )
        .addSpace()
        .addBlank()
        .addSpace()
        .addBlank()
        .build();
  }
}

class LeaveRow extends StatelessWidget {
  final int colPos;
  final int time;
  final String initialText;
  const LeaveRow(
      {super.key,
      required this.colPos,
      required this.time,
      required this.initialText});

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Dropoff $colPos /\nPickup ${colPos + 1}",
          initialText: initialText,
          colPos: colPos,
        )
        .addSpace()
        .addTimeField(
          text: "Pickup time ${colPos + 1}",
          time: time,
          colPos: colPos,
        )
        .addSpace()
        .addSwitch(
          leave: true,
          colPos: colPos,
        )
        .build();
  }
}

class StayRow extends StatelessWidget {
  final int colPos;
  final String initialText;
  const StayRow({
    super.key,
    required this.colPos,
    required this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Dropoff $colPos /\nPickup ${colPos + 1}",
          colPos: colPos,
          initialText: initialText,
        )
        .addSpace()
        .addSwitch(
          leave: false,
          colPos: colPos,
        )
        .addSpace()
        .addBlank()
        .build();
  }
}

class SubmitRow extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const SubmitRow({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addSubmit(formKey: formKey)
        .addSpace()
        .addBlank()
        .addSpace()
        .addBlank()
        .build();
  }
}

class RowBuilder {
  List<Widget> children = [];
  RowBuilder();

  RowBuilder addTextField({
    required String text,
    required int colPos,
    required String initialText,
  }) {
    children.add(CustomTextFormField(
      text: text,
      colPos: colPos,
      initialText: initialText,
    ));
    return this;
  }

  RowBuilder addSpace() {
    children.add(const RowSpacing());
    return this;
  }

  RowBuilder addTimeField({
    required String text,
    required int time,
    required int colPos,
  }) {
    children.add(CustomTimePicker(
      text: text,
      time: time,
      colPos: colPos,
    ));
    return this;
  }

  RowBuilder addBlank() {
    children.add(
      const BlankSpace(),
    );
    return this;
  }

  RowBuilder addSwitch({required int colPos, bool leave = true}) {
    children.add(
      WaitSwitch(
        colPos: colPos,
        leave: leave,
      ),
    );
    return this;
  }

  RowBuilder addSubmit({required GlobalKey<FormBuilderState> formKey}) {
    children.add(
      CustomSubmitButton(
        formKey: formKey,
      ),
    );
    return this;
  }

  Row build() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final String text;
  final String initialText;
  final int colPos;

  const CustomTextFormField({
    super.key,
    required this.text,
    required this.colPos,
    required this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        return Flexible(
          child: Animate(
            effects: (state is TicketViewAdded)
                ? (colPos == state.formLayoutList.length - 1)
                    ? [const ScaleEffect(duration: Duration(milliseconds: 150))]
                    : []
                : [],
            child: FormBuilderTextField(
              name: UniqueKey().toString(),
              initialValue: initialText,
              autocorrect: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(radius),
                    right: Radius.circular(radius),
                  ),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                helperText: text,
                helperStyle: const TextStyle(
                  color: Colors.blue,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(radius),
                    right: Radius.circular(radius),
                  ),
                ),
              ),
              onChanged: (value) {
                context.read<TicketViewCubit>().updateRow(
                      colPos: colPos,
                      rowPos: textPos,
                      newValue: value ?? empty(),
                    );
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.match(r'^[a-zA-Z0-9_\-\s]+$')
              ]),
            ),
          ),
        );
      },
    );
  }
}

class CustomTimePicker extends StatelessWidget {
  final String text;
  final int colPos;
  final int time;
  const CustomTimePicker({
    super.key,
    required this.text,
    required this.colPos,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        return Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (colPos != 0) ? 15.0 : 0.0,
            ),
            child: FormBuilderDateTimePicker(
              name: UniqueKey().toString(),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              format: DateFormat.jm(),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              initialDate: DateTime.fromMillisecondsSinceEpoch(time),
              initialTime: TimeOfDay.fromDateTime(
                DateTime.fromMillisecondsSinceEpoch(time),
              ),
              initialValue: DateTime.fromMillisecondsSinceEpoch(time),
              firstDate: DateTime.fromMillisecondsSinceEpoch(time),
              decoration: InputDecoration(
                helperText: text,
                helperStyle: const TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.25,
                  ),
                ),
              ),
              onChanged: (DateTime? dateTime) {
                context.read<TicketViewCubit>().updateRow(
                      colPos: colPos,
                      rowPos: timePos,
                      newValue: dateTime?.millisecondsSinceEpoch.toString() ??
                          nowInMilliseconds(),
                    );
              },
              validator: (DateTime? dateTime) {
                if (() {
                  if (dateTime == null) {
                    return true;
                  }
                  if (colPos == 0) {
                    return false;
                  }
                  TicketViewState state_ = state;
                  if (state_ is! TicketViewLoaded) {
                    return false;
                  }
                  int previousTimeinForm = context
                      .read<TicketViewCubit>()
                      .findPreviousTimeinForm(colPos);
                  return dateTime.millisecondsSinceEpoch <= previousTimeinForm;
                }()) {
                  return "invalid time";
                } else {
                  return null;
                }
              },
            ),
          ),
        ).animate().scaleXY(duration: const Duration(milliseconds: 125));
      },
    );
  }
}

class WaitSwitch extends StatefulWidget {
  final bool leave;
  final int colPos;
  const WaitSwitch({
    super.key,
    required this.colPos,
    this.leave = false,
  });

  @override
  State<WaitSwitch> createState() => _WaitSwitchState();
}

class _WaitSwitchState extends State<WaitSwitch> {
  bool leave = false;

  @override
  void initState() {
    leave = widget.leave;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 35.0),
            child: Animate(
                effects: [
                  MoveEffect(
                    begin:
                        (leave) ? const Offset(-115, 0) : const Offset(115, 0),
                    duration: const Duration(
                      milliseconds: 90,
                    ),
                  )
                ],
                child: FlutterSwitch(
                  value: leave,
                  onToggle: (value) {
                    if (value) {
                      //switch from wait to leave
                      context
                          .read<TicketViewCubit>()
                          .updateStayRowFormatToLeaveRowFormat(
                            rowPos: widget.colPos,
                          );
                    } else {
                      context.read<TicketViewCubit>().updateLeaveRowToStayRow(
                            colPos: widget.colPos,
                          );
                    }
                  },
                  showOnOff: true,
                  activeText: "Leave",
                  valueFontSize: 10,
                  inactiveText: "Stay",
                  activeIcon: Transform.translate(
                    offset: const Offset(2, 0),
                    child: const FaIcon(
                      FontAwesomeIcons.carSide,
                      color: Colors.blue,
                    ),
                  ),
                  inactiveIcon: Transform.translate(
                    offset: const Offset(-2, 0),
                    child: const FaIcon(
                      FontAwesomeIcons.carSide,
                      color: Colors.grey,
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }
}

class ConnectingLine extends StatelessWidget {
  final double xOffset;
  const ConnectingLine({super.key, required this.xOffset});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(xOffset, 0),
      child: const Padding(
        padding: EdgeInsets.only(top: 6.0),
        child: DottedLine(
          alignment: WrapAlignment.center,
          direction: Axis.vertical,
          lineLength: 40,
          lineThickness: 1.0,
          dashColor: Colors.blue,
        ),
      ),
    );
  }
}

class PlusButton extends StatelessWidget {
  final double xOffset;
  const PlusButton({super.key, required this.xOffset});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        return Transform.translate(
          offset: Offset(xOffset, 0),
          child: Stack(
            children: [
              Container(
                height: 50.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: IconButton(
                  // add button
                  onPressed: () async {
                    await context.read<TicketViewCubit>().addRow();
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.circlePlus,
                    color: Colors.white,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-18.5, -18),
                child: Container(
                  height: 36.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    // minus button
                    onPressed: () async {
                      await context.read<TicketViewCubit>().deleteRow();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.circleMinus,
                      color: Colors.white,
                      size: 18.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class CustomSubmitButton extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const CustomSubmitButton({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, ticketState) {
        return ElevatedButton(
          onPressed: () async {
            FormBuilderState? formbuilderState = formKey.currentState;
            if (formbuilderState == null) {
              return;
            }
            if (!formbuilderState.validate()) {
              return;
            }
            TicketViewState ticketViewState = ticketState;
            if (ticketViewState is! TicketViewLoaded) {
              return;
            }
            Message newMessageTicket = MessageAdaptor.adaptFormLayoutList(
                ticketViewState.formLayoutList);
            print(Navigator.canPop(context));
            print(await Navigator.maybePop(context));
            //Add the message bloc to add this new message to the message
            await FirebaseUserMessagesDatabase("test")
                .addMessage(newMessageTicket);
          },
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Submit"),
          ),
        );
      },
    );
  }
}

class RowSpacing extends StatelessWidget {
  const RowSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
    );
  }
}

class BlankSpace extends StatelessWidget {
  const BlankSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(),
    );
  }
}

Widget loading() => const Center(
      child: CircularProgressIndicator(),
    );

List<List<String>> Function() getNewTicketLayout = () => [
      [empty(), nowInMilliseconds()],
      [empty(), stay()],
    ];

List<String> Function(String?) getFinalTicketRowLayout =
    (String? initialText) => [initialText ?? empty(), stay()];

const textPos = 0;
const timePos = 1;
String Function() stay = () => "stay";
String Function() empty = () => "";
String Function() nowInMilliseconds =
    () => DateTime.now().millisecondsSinceEpoch.toString();

class FormLayoutEncoder {
  static const rowSeparator = "~";
  static const columnSeparator = "`";

  String encode(List<List<String>> formLayoutList) {
    List<String> firstRowLayout = formLayoutList.first;
    String encodedLayout = firstRowLayout.first;
    for (String element in firstRowLayout.skip(1)) {
      encodedLayout += rowSeparator;
      encodedLayout += element;
    }

    for (List<String> rowLayoutList in formLayoutList.skip(1)) {
      String encodedRow = rowLayoutList.first;
      for (String element in rowLayoutList.skip(1)) {
        encodedRow += rowSeparator;
        encodedRow += element;
      }
      encodedLayout += columnSeparator;
      encodedLayout += encodedRow;
    }
    return encodedLayout;
  }

  List<List<String>> decode(String encodedLayout) {
    return encodedLayout
        .split(columnSeparator)
        .map(
          (rowString) => rowString.split(rowSeparator),
        )
        .toList();
  }
}
