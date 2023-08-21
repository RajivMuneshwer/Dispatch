import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/message_models.dart';
import 'package:dispatch/models/user_objects.dart';
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
    actions: [
      IconButton(
        iconSize: 60,
        onPressed: () {
          Navigator.pop(
            context,
          );
        },
        icon: const Text(
          "Back",
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

class Ticket extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const Ticket({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) {
          return Container();
        }
        final List<Widget> children = buildTicketWidgets(
          xOffset: MediaQuery.of(context).size.width * 0.05,
          formkey: formKey,
          ticketViewWithData: state,
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
      },
    );
  }
}

List<Widget> buildTicketWidgets({
  required GlobalKey<FormBuilderState> formkey,
  required TicketViewWithData ticketViewWithData,
  double xOffset = 0,
}) {
  ListBuilder listBuilder = ListBuilder(
    xOffset: xOffset,
  );

  //// the below loop should only be for the main ticket body i.e. everything above the plus button
  /// if you re-write to another system, there will be difficulties
  /// adding rows or deleting rows,
  /// controlling the maximum and minimum number of stops.
  ///

  List<List<String>> formLayoutList = ticketViewWithData.formLayoutList;

  for (var i = 0; i < formLayoutList.length; i++) {
    listBuilder.addConnector();
    switch (formLayoutList[i]) {
      case [_, String time] when i == 0:
        {
          listBuilder.addFirstRow(time: int.parse(time));
          break;
        }
      case [_, String time] when i != 0 && time != "stay":
        {
          listBuilder.addLeaveRow(colPos: i);
          break;
        }
      case [_, "stay"] when i != formLayoutList.length - 1:
        {
          listBuilder.addStayRow(colPos: i);
          break;
        }
      case [_, "stay"] when i == formLayoutList.length - 1:
        {
          listBuilder.addLastRow(colPos: i);
          break;
        }
    }
  }
  listBuilder.children.removeAt(0); //to remove the top most connecting line

  switch (ticketViewWithData.bottomButtonType) {
    case BottomButtonType.none:
      {
        break;
      }
    case BottomButtonType.submit:
      {
        listBuilder.addConnector();
        listBuilder.addPlusButton();
        listBuilder.addVerticalSpace(10.0);
        listBuilder.addSubmitRow(formkey);
      }
    case BottomButtonType.cancelOrUpdate:
      {
        listBuilder.addConnector();
        listBuilder.addPlusButton();
        listBuilder.addVerticalSpace(10.0);
        (ticketViewWithData.messagesState.user is! Dispatcher)
            ? listBuilder.addCancelOrUpdateRow(formkey)
            : listBuilder.addCancelUpdateOrConfirm(formkey);
      }
  }

  return listBuilder.build();
}

class ListBuilder {
  final double xOffset;
  final List<Widget> children = [];

  ListBuilder({
    required this.xOffset,
  });

  ListBuilder addFirstRow({
    required int time,
  }) {
    children.add(
      const FirstRow(),
    );
    return this;
  }

  ListBuilder addStayRow({
    required int colPos,
  }) {
    children.add(
      StayRow(
        colPos: colPos,
      ),
    );
    return this;
  }

  ListBuilder addLeaveRow({
    required int colPos,
  }) {
    children.add(
      LeaveRow(
        colPos: colPos,
      ),
    );
    return this;
  }

  ListBuilder addLastRow({
    required int colPos,
  }) {
    children.add(
      LastRow(
        colPos: colPos,
      ),
    );
    return this;
  }

  ListBuilder addConnector() {
    children.add(
      ConnectingLine(
        xOffset: xOffset,
      ),
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

  ListBuilder addCancelOrUpdateRow(GlobalKey<FormBuilderState> formkey) {
    children.add(CancelOrUpdateRow(
      formKey: formkey,
    ));
    return this;
  }

  ListBuilder addCancelUpdateOrConfirm(GlobalKey<FormBuilderState> formkey) {
    children.add(CancelUpdateOrConfirm(
      formKey: formkey,
    ));
    return this;
  }

  List<Widget> build() {
    return children;
  }
}

class FirstRow extends StatelessWidget {
  const FirstRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Pickup",
          colPos: 0,
        )
        .addSpace()
        .addTimeField(
          text: "Pickup time",
          colPos: 0,
        )
        .addSpace()
        .addBlank()
        .build();
  }
}

class LastRow extends StatelessWidget {
  final int colPos;
  const LastRow({
    super.key,
    required this.colPos,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Dropoff $colPos",
          colPos: colPos,
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
  const LeaveRow({
    super.key,
    required this.colPos,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Dropoff $colPos /\nPickup ${colPos + 1}",
          colPos: colPos,
        )
        .addSpace()
        .addTimeField(
          text: "Pickup time ${colPos + 1}",
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
  const StayRow({
    super.key,
    required this.colPos,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTextField(
          text: "Dropoff $colPos /\nPickup ${colPos + 1}",
          colPos: colPos,
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

class CancelOrUpdateRow extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const CancelOrUpdateRow({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addUpdate(
          formKey: formKey,
        )
        .addSpace()
        .addCancel()
        .addSpace()
        .addBlank()
        .build();
  }
}

class CancelUpdateOrConfirm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const CancelUpdateOrConfirm({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addCancel()
        .addSpace()
        .addUpdate(formKey: formKey)
        .addSpace()
        .addConfirm(formKey: formKey)
        .build();
  }
}

class RowBuilder {
  List<Widget> children = [];
  RowBuilder();

  RowBuilder addTextField({
    required String text,
    required int colPos,
  }) {
    children.add(CustomTextFormField(
      text: text,
      colPos: colPos,
    ));
    return this;
  }

  RowBuilder addSpace() {
    children.add(const RowSpacing());
    return this;
  }

  RowBuilder addTimeField({
    required String text,
    required int colPos,
  }) {
    children.add(CustomTimePicker(
      text: text,
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

  RowBuilder addCancel() {
    children.add(const CancelButton());
    return this;
  }

  RowBuilder addUpdate({required GlobalKey<FormBuilderState> formKey}) {
    children.add(UpdateButton(
      formKey: formKey,
    ));
    return this;
  }

  RowBuilder addConfirm({required GlobalKey<FormBuilderState> formKey}) {
    children.add( ConfirmButton(formKey: formKey,));
    return this;
  }

  RowBuilder addDriverDropdown(){
    children.add(const DriverDropDown());
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
  final int colPos;

  const CustomTextFormField({
    super.key,
    required this.text,
    required this.colPos,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) {
          return Container();
        }
        return Flexible(
          child: Animate(
            effects: (state.animate)
                ? (colPos == state.formLayoutList.length - 1)
                    ? [const ScaleEffect(duration: Duration(milliseconds: 150))]
                    : []
                : [],
            child: FormBuilderTextField(
              name: UniqueKey().toString(),
              initialValue: state.formLayoutList[colPos][textPos],
              autocorrect: true,
              textAlign: TextAlign.center,
              enabled: state.enabled,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(radius),
                    right: Radius.circular(radius),
                  ),
                  borderSide: BorderSide(
                    color: state.color,
                    width: 1.5,
                  ),
                ),
                helperText: text,
                helperStyle: TextStyle(
                  color: state.color,
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
  const CustomTimePicker({
    super.key,
    required this.text,
    required this.colPos,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) {
          return Container();
        }
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(state.formLayoutList[colPos][timePos]),
        );
        return Animate(
            effects: const [ScaleEffect(duration: Duration(milliseconds: 125))],
            child: Flexible(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: (colPos != 0) ? 15.0 : 0.0,
                ),
                child: FormBuilderDateTimePicker(
                  enabled: state.enabled,
                  name: UniqueKey().toString(),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  format: DateFormat.jm(),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  initialDate: dateTime,
                  initialTime: TimeOfDay.fromDateTime(
                    dateTime,
                  ),
                  initialValue: dateTime,
                  firstDate: dateTime,
                  decoration: InputDecoration(
                    helperText: text,
                    helperStyle: TextStyle(
                      color: state.color,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: state.color,
                        width: 1.25,
                      ),
                    ),
                  ),
                  onChanged: (DateTime? changedTime) {
                    context.read<TicketViewCubit>().updateRow(
                          colPos: colPos,
                          rowPos: timePos,
                          newValue:
                              changedTime?.millisecondsSinceEpoch.toString() ??
                                  nowInMilliseconds(),
                        );
                  },
                  validator: (DateTime? dateTimeSubmitted) {
                    if (() {
                      if (dateTimeSubmitted == null) {
                        return true;
                      }
                      if (colPos == 0) {
                        return false;
                      }
                      int previousTimeinForm = context
                          .read<TicketViewCubit>()
                          .findPreviousTimeinForm(colPos);
                      return dateTimeSubmitted.millisecondsSinceEpoch <=
                          previousTimeinForm;
                    }()) {
                      return "invalid time";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ));
      },
    );
  }
}

class DriverDropDown extends StatelessWidget {
  const DriverDropDown({super.key,});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        var state_ = state;
        if (state_ is! TicketViewWithData) return Container();
        var user = state_.messagesState.user;
        if (user is! Dispatcher) return Container();
        var driverids = user.driversid;
        return FutureBuilder<List<Driver>>(
          future: getDrivers(driverids),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {return Container();}
            else if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No options available.');
            }
            return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilderDropdown<int>(
              decoration: const InputDecoration(
                labelText: "Driver",
                labelStyle: TextStyle(fontWeight: FontWeight.normal),
              ),
              name: driverDropdownName(),
              initialValue: null,
              items: snapshot.data!
                  .map((driver) => DropdownMenuItem(
                        value: driver.id,
                        child: Text(driver.name),
                      ))
                  .toList(),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
          );}
        );
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
        if (state is! TicketViewWithData) {
          return Container();
        }
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 35.0),
            child: Animate(
              effects: [
                MoveEffect(
                  begin: (leave) ? const Offset(-115, 0) : const Offset(115, 0),
                  duration: const Duration(
                    milliseconds: 90,
                  ),
                )
              ],
              child: FlutterSwitch(
                disabled: !state.enabled,
                value: leave,
                onToggle: (value) {
                  TicketViewCubit ticketViewCubit =
                      context.read<TicketViewCubit>();
                  if (value) {
                    //switch from wait to leave
                    ticketViewCubit.updateStayRowFormatToLeaveRowFormat(
                      rowPos: widget.colPos,
                    );
                  } else {
                    ticketViewCubit.updateLeaveRowToStayRow(
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
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConnectingLine extends StatelessWidget {
  final double xOffset;
  const ConnectingLine({
    super.key,
    required this.xOffset,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) {
          return Container();
        }
        return Transform.translate(
          offset: Offset(xOffset, 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: DottedLine(
              alignment: WrapAlignment.center,
              direction: Axis.vertical,
              lineLength: 40,
              lineThickness: 1.5,
              dashColor: state.color,
            ),
          ),
        );
      },
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
                    await context.read<TicketViewCubit>().addRow(state);
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
                      await context.read<TicketViewCubit>().deleteRow(state);
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
      builder: (context, ticketViewState) {
        return ElevatedButton(
          onPressed: () async {
            FormBuilderState? formbuilderState = formKey.currentState;
            if (formbuilderState == null) {
              return;
            }
            if (!formbuilderState.validate()) {
              return;
            }
            if (ticketViewState is! TicketViewWithData) {
              return;
            }
            final bool isDispatch =
                switch (ticketViewState.messagesState.user) {
              Dispatcher() => true,
              _ => false,
            };
            Message newMessageTicket = MessageAdaptor.adaptTicketState(
              ticketViewState,
              isDispatch,
            );
            Navigator.pop(
              context,
            );
            //Add the message bloc to add this new message to the message
            await ticketViewState.messagesState.database
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

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) return Container();
        return ElevatedButton(
          onPressed: () {
            state.messagesState.database
                .updateTicketType(state.id.toString(), TicketTypes.cancelled);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            side: const BorderSide(width: 1, color: Colors.red),
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.red,
            ),
          ),
        );
      },
    );
  }
}

class UpdateButton extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const UpdateButton({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) return Container();
        return ElevatedButton(
          onPressed: () {
            FormBuilderState? formbuilderState = formKey.currentState;
            if (formbuilderState == null) {
              return;
            }
            if (!formbuilderState.validate()) {
              return;
            }
            String encodedTicket =
                FormLayoutEncoder.encode(state.formLayoutList);
            String messageID = state.id.toString();
            state.messagesState.database
                .updateTicketMessage(messageID, encodedTicket);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            side: const BorderSide(width: 1, color: Colors.blue),
          ),
          child: const Text(
            "Update",
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const ConfirmButton({super.key, required this.formKey,});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) return Container();
        return ElevatedButton(
          onPressed: () {
            FormBuilderState? formbuilderState = formKey.currentState;
            if (formbuilderState == null) {
              return;
            }
            if (!formbuilderState.validate()) {
              return;
            }
            state.messagesState.database
                .updateTicketType(state.id.toString(), TicketTypes.confirmed,);
            

            
            state.messagesState.database.addMessage(message)

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            side: const BorderSide(width: 1, color: Colors.green),
          ),
          child: const Text(
            "Confirm",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.green,
            ),
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

int Function() generateNewTicketID =
    () => DateTime.now().millisecondsSinceEpoch;

List<String> Function(String?) getFinalTicketRowLayout =
    (String? initialText) => [initialText ?? empty(), stay()];

const textPos = 0;
const timePos = 1;
String Function() stay = () => "stay";
String Function() empty = () => "";
String Function() nowInMilliseconds =
    () => DateTime.now().millisecondsSinceEpoch.toString();

String Function() driverDropdownName = () => "drivers";

class FormLayoutEncoder {
  static const rowSeparator = "~";
  static const columnSeparator = "`";

  static String encode(List<List<String>> formLayoutList) {
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

  static List<List<String>> decode(String encodedLayout) {
    return encodedLayout
        .split(columnSeparator)
        .map(
          (rowString) => rowString.split(rowSeparator),
        )
        .toList();
  }
}

Future<List<Driver>> getDrivers(List<int>? driverids) async {

  if (driverids == null) return [];
  List<Driver> drivers = [];
  AdminDatabase database = AdminDatabase();
  for (final id in driverids){
          drivers.addAll((await database.getOne<Driver>(id))
          .map((snapshot) => UserAdaptor<Driver>().adaptSnapshot(snapshot))
          .toList());
  }
  return drivers;
}

////cannot delete dispatcher if they have drivers as well
////build the receipt builder that returns a message and takes the driver as argument
///the dropdown should return a driver as the value so it would be easier to get the driver for the receipt 
///the receipt needs the current time when it was confirmed and send it as a new message 
///The ticket should be updated first if the dispatcher wants to make changes
///an auto message should be sent in this case or would the push notification be enough???
///