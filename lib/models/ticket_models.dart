//import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/database/requestee_database.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/message_objects.dart';
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

AppBar ticketAppBar(BuildContext context, TicketMessage ticketMessage) {
  return AppBar(
    centerTitle: false,
    backgroundColor: ticketMessage.iconColor,
    title: Text(ticketMessage.title),
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
  /// controlling the maximum and minimum number of rows.

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

  var user = ticketViewWithData.messagesState.user;

  switch (ticketViewWithData.ticketMessage) {
    case TicketConfirmedMessage():
      {
        listBuilder
          ..addVerticalSpace(30)
          ..addConfirmationRow()
          ..addVerticalSpace(20)
          ..addTimeStampRow();
        break;
      }
    case TicketCancelledMessage():
      {
        listBuilder
          ..addVerticalSpace(30)
          ..addCancelledRow()
          ..addVerticalSpace(10)
          ..addTimeStampRow();

        break;
      }
    case TicketSubmittedMessage():
      {
        listBuilder
          ..addConnector()
          ..addPlusButton()
          ..addVerticalSpace(10.0);

        if (user is! Dispatcher) {
          listBuilder.addCancelOrUpdateRow(formkey);
          break;
        }
        if (ticketViewWithData.messagesState.other is Requestee) {
          listBuilder
            ..addDriverDropdownRow()
            ..addVerticalSpace(60.0)
            ..addCancelUpdateOrConfirm(formkey);
          break;
        } else if (ticketViewWithData.messagesState.other is Driver) {
          listBuilder
            ..addRequesteeDropdownRow()
            ..addVerticalSpace(60.0)
            ..addCancelUpdateOrConfirm(formkey);
          break;
        }
      }
    case TicketNewMessage():
      {
        listBuilder
          ..addConnector()
          ..addPlusButton()
          ..addVerticalSpace(10.0)
          ..addSubmitRow(formkey);

        break;
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

  ListBuilder addDriverDropdownRow() {
    children.add(const DriverDropdownRow());
    return this;
  }

  ListBuilder addRequesteeDropdownRow() {
    children.add(const RequesteeDropdownRow());
    return this;
  }

  ListBuilder addConfirmationRow() {
    children.add(const ConfirmationRow());
    return this;
  }

  ListBuilder addCancelledRow() {
    children.add(const CancellationRow());
    return this;
  }

  ListBuilder addTimeStampRow() {
    children.add(const TimeStampRow());
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

class DriverDropdownRow extends StatelessWidget {
  const DriverDropdownRow({super.key});

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addDriverDropdown()
        .addSpace()
        .addBlank()
        .addSpace()
        .addBlank()
        .build();
  }
}

class RequesteeDropdownRow extends StatelessWidget {
  const RequesteeDropdownRow({super.key});

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addRequesteeDropdown()
        .addSpace()
        .addBlank()
        .addSpace()
        .addBlank()
        .build();
  }
}

class ConfirmationRow extends StatelessWidget {
  const ConfirmationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addDriverConfirmText()
        .addSpace()
        .addBlank()
        .addSpace()
        .addBlank()
        .build();
  }
}

class CancellationRow extends StatelessWidget {
  const CancellationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addCancelIcon()
        .addSpace()
        .addBlank()
        .addSpace()
        .addBlank()
        .build();
  }
}

class TimeStampRow extends StatelessWidget {
  const TimeStampRow({super.key});

  @override
  Widget build(BuildContext context) {
    return RowBuilder()
        .addTimeStampText()
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
    children.add(ConfirmButton(
      formKey: formKey,
    ));
    return this;
  }

  RowBuilder addDriverDropdown() {
    children.add(const DriverDropDown());
    return this;
  }

  RowBuilder addRequesteeDropdown() {
    children.add(const RequesteeDropDown());
    return this;
  }

  RowBuilder addConfirmIcon() {
    children.add(const ConfirmIcon());
    return this;
  }

  RowBuilder addDriverConfirmText() {
    children.add(const DriverConfirmText());
    return this;
  }

  RowBuilder addTimeStampText() {
    children.add(const TimeStampText());
    return this;
  }

  RowBuilder addCancelIcon() {
    children.add(const CancelledIcon());
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
          ),
        );
      },
    );
  }
}

class RequesteeDropDown extends StatelessWidget {
  const RequesteeDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        var state_ = state;
        if (state_ is! TicketViewWithData) return Container();
        var user = state_.messagesState.user;
        if (user is! Dispatcher) return Container();
        var requesteesid = user.requesteesid;
        print(user.toMap());
        return FutureBuilder<List<Requestee>>(
            future: getRequestees(requesteesid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return driverDropDownWidget([], "temp");
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Text('No options available.');
              }
              print(requesteesid);
              return requesteeDropDownWidget(
                snapshot.data ?? [],
                requesteeDropdownName(),
              );
            });
      },
    );
  }
}

Widget requesteeDropDownWidget(List<Requestee> requestees, String name) {
  return Flexible(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: FormBuilderDropdown<Requestee>(
          decoration: const InputDecoration(
              labelText: "Requestee",
              labelStyle: TextStyle(fontWeight: FontWeight.normal),
              border: InputBorder.none),
          name: name,
          initialValue: null,
          items: requestees
              .map((requestee) => DropdownMenuItem(
                    value: requestee,
                    child: Text(requestee.name),
                  ))
              .toList(),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
      ),
    ),
  );
}

class DriverDropDown extends StatelessWidget {
  const DriverDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        var state_ = state;
        if (state_ is! TicketViewWithData) return Container();
        var user = state_.messagesState.user;
        if (user is! Dispatcher) return Container();
        var driverids = user.driversid;
        print(user.toMap());
        return FutureBuilder<List<Driver>>(
            future: getDrivers(driverids),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return driverDropDownWidget([], "temp");
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Text('No options available.');
              }
              print(driverids);
              return driverDropDownWidget(
                snapshot.data ?? [],
                driverDropdownName(),
              );
            });
      },
    );
  }
}

Widget driverDropDownWidget(List<Driver> drivers, String name) {
  return Flexible(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: FormBuilderDropdown<Driver>(
          decoration: const InputDecoration(
              labelText: "Driver",
              labelStyle: TextStyle(fontWeight: FontWeight.normal),
              border: InputBorder.none),
          name: name,
          initialValue: null,
          items: drivers
              .map((driver) => DropdownMenuItem(
                    value: driver,
                    child: Text(driver.name),
                  ))
              .toList(),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
      ),
    ),
  );
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
                disabled: switch (state.ticketMessage) {
                  TicketCancelledMessage() => true,
                  TicketConfirmedMessage() => true,
                  TicketNewMessage() => false,
                  TicketSubmittedMessage() => false,
                },
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
              lineThickness: 2,
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
            Message newMessageTicket =
                MessageAdaptor(messagesViewState: ticketViewState.messagesState)
                    .adaptNewTicket(
              ticketViewState,
            );
            Navigator.pop(
              context,
            );
            //Add the message bloc to add this new message to the message
            //context.read<MessagesViewCubit>().add(newMessageTicket);
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
            var ticketMessage = state.ticketMessage;
            var cancelledMessage = TicketCancelledMessage(
              text: ticketMessage.text,
              date: ticketMessage.date,
              isDispatch: ticketMessage.isDispatch,
              sent: ticketMessage.sent,
              seen: ticketMessage.seen,
              sender: state.messagesState.user,
              messagesViewState: state.messagesState,
              cancelledTime: DateTime.now().millisecondsSinceEpoch,
            );
            state.messagesState.database.updateTicket(cancelledMessage);

            bool isDispatch = switch (state.messagesState.user) {
              Dispatcher() => true,
              _ => false,
            };
            var cancelReceipt = CancelReceipt(
              date: DateTime.now(),
              isDispatch: isDispatch,
              sent: false,
              seen: false,
              messagesViewState: state.messagesState,
              cancelTime: DateTime.now().millisecondsSinceEpoch,
              ticketTime: ticketMessage.date.millisecondsSinceEpoch,
              sender: state.messagesState.user,
            );
            state.messagesState.database.addMessage(cancelReceipt);

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
            String encodedTicket = FormLayoutEncoder.encode(
              state.formLayoutList,
            );
            var ticketMessage = state.ticketMessage;
            TicketSubmittedMessage submittedMessage = TicketSubmittedMessage(
              text: encodedTicket,
              date: ticketMessage.date,
              isDispatch: ticketMessage.isDispatch,
              sent: ticketMessage.sent,
              seen: ticketMessage.seen,
              messagesViewState: state.messagesState,
              sender: state.messagesState.user,
            );
            state.messagesState.database.updateTicket(submittedMessage);

            bool isDispatch = switch (state.messagesState.user) {
              Dispatcher() => true,
              _ => false,
            };
            var updateReceipt = UpdateReceipt(
              date: DateTime.now(),
              isDispatch: isDispatch,
              sent: false,
              seen: false,
              messagesViewState: state.messagesState,
              ticketTime: ticketMessage.date.millisecondsSinceEpoch,
              updateTime: DateTime.now().millisecondsSinceEpoch,
              sender: state.messagesState.user,
            );
            state.messagesState.database.addMessage(updateReceipt);

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

class ConfirmButton extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  const ConfirmButton({
    super.key,
    required this.formKey,
  });

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) return Container();
        return ElevatedButton(
          onPressed: (isRunning)
              ? () {}
              : () {
                  FormBuilderState? formbuilderState =
                      widget.formKey.currentState;
                  if (formbuilderState == null) {
                    return;
                  }
                  if (!formbuilderState.validate()) {
                    return;
                  }
                  Driver? driver =
                      formbuilderState.fields[driverDropdownName()]?.value;
                  Requestee? requestee =
                      formbuilderState.fields[requesteeDropdownName()]?.value;

                  if (driver == null && requestee == null) {
                    throw Exception(
                        "both driver and requestee fields inactive");
                  }
                  if (driver != null && requestee != null) {
                    throw Exception("both driver and requestee fields active");
                  }
                  setState(() {
                    isRunning = true;
                  });
                  //either one or the other is null

                  updateTicketToConfirmed(state, driver, requestee);
                  sendReceiptToRequestee(state, driver, requestee);
                  sendReceiptToDriver(state, driver, requestee);
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: (!isRunning) ? Colors.green : Colors.grey,
            side: const BorderSide(width: 1, color: Colors.green),
          ),
          child: (!isRunning)
              ? const Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                )
              : const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  )),
        );
      },
    );
  }
}

void updateTicketToConfirmed(
  TicketViewWithData state,
  Driver? driver,
  Requestee? requestee,
) {
  var ticketMessage = state.ticketMessage;
  var messagesState = state.messagesState;
  User other = state.messagesState.other;
  MessageDatabase messageDatabase = state.messagesState.database;
  var confirmedMessage = TicketConfirmedMessage(
    text: ticketMessage.text,
    date: ticketMessage.date,
    isDispatch: ticketMessage.isDispatch,
    sent: ticketMessage.sent,
    seen: ticketMessage.seen,
    sender: ticketMessage.messagesViewState.user,
    messagesViewState: messagesState,
    confirmedTime: DateTime.now().millisecondsSinceEpoch,
    driver: (driver !=
            null) // if the driver is not in the form field then they are the other user
        ? driver.name
        : other.name,
    requestee: (requestee !=
            null) // if the requestee is not in the form field then they are the other user
        ? requestee.name
        : other.name,
  );
  messageDatabase.updateTicket(confirmedMessage);
}

void sendReceiptToRequestee(
  TicketViewWithData state,
  Driver? driver,
  Requestee? requestee,
) {
  var ticketMessage = state.ticketMessage;
  User other = state.messagesState.other;

  var confirmRequesteeReceipt = ConfirmRequesteeReceipt(
    date: DateTime.now(),
    isDispatch: true,
    sent: false,
    seen: false,
    sender: state.messagesState.user,
    messagesViewState: state.messagesState,
    driver: (driver != null) ? driver : other as Driver,
    confirmTime: DateTime.now().millisecondsSinceEpoch,
    ticketTime: ticketMessage.date.millisecondsSinceEpoch,
  );
  RequesteesMessageDatabase(
    user: (requestee != null) ? requestee : other as Requestee,
  ).addMessage(confirmRequesteeReceipt);
}

void sendReceiptToDriver(
  TicketViewWithData state,
  Driver? driver,
  Requestee? requestee,
) {
  var ticketMessage = state.ticketMessage;
  User other = state.messagesState.other;
  var confirmDriverReceipt = ConfirmDriverReceipt(
    date: DateTime.now(),
    isDispatch: true,
    sent: false,
    sender: state.messagesState.user,
    messagesViewState: state.messagesState,
    seen: false,
    requestee: (requestee != null) ? requestee : other as Requestee,
    confirmTime: DateTime.now().millisecondsSinceEpoch,
    ticketTime: ticketMessage.date.millisecondsSinceEpoch,
  );
  DriverMessageDatabase(
    user: (driver != null) ? driver : other as Driver,
  ).addMessage(confirmDriverReceipt);
}

class ConfirmIcon extends StatelessWidget {
  const ConfirmIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: CustomPaint(
          painter: CirclePainter(),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 20.0;

    final fillPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DriverConfirmText extends StatelessWidget {
  const DriverConfirmText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) return Container();
        var message = state.ticketMessage;
        if (message is! TicketConfirmedMessage) return Container();
        return Text(
          "Driver: ${message.driver}",
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class TimeStampText extends StatelessWidget {
  const TimeStampText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketViewCubit, TicketViewState>(
      builder: (context, state) {
        if (state is! TicketViewWithData) return Container();
        var message = state.ticketMessage;
        switch (message) {
          case TicketConfirmedMessage():
            {
              String confirmedDateString = DateFormat()
                  .add_yMMMd()
                  .add_jm()
                  .format(DateTime.fromMillisecondsSinceEpoch(
                      message.confirmedTime));
              return Text(
                "Confirm time: $confirmedDateString",
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
          case TicketCancelledMessage():
            {
              String confirmedDateString =
                  DateFormat().add_yMMMd().add_jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                          message.cancelledTime,
                        ),
                      );
              return Text(
                "Cancelled time: $confirmedDateString",
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              );
            }

          case TicketSubmittedMessage():
            {
              return Container();
            }
          case TicketNewMessage():
            {
              return Container();
            }
        }
      },
    );
  }
}

class CancelledIcon extends StatelessWidget {
  const CancelledIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: CustomPaint(
        painter: XPainter(),
      ),
    );
  }
}

class XPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawPath(_getXPath(size.width, size.height), paint);
  }

  Path _getXPath(double width, double height) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(width, height);
    path.moveTo(width, 0);
    path.lineTo(0, height);
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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

String Function() requesteeDropdownName = () => "requestees";

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
  for (final id in driverids) {
    drivers.addAll((await database.getOne<Driver>(id))
        .map((snapshot) => UserAdaptor<Driver>().adaptSnapshot(snapshot))
        .toList());
  }
  return drivers;
}

Future<List<Requestee>> getRequestees(List<int>? requesteesid) async {
  if (requesteesid == null) return [];
  List<Requestee> requestees = [];
  AdminDatabase database = AdminDatabase();
  for (final id in requesteesid) {
    requestees.addAll((await database.getOne<Requestee>(id))
        .map((snapshot) => UserAdaptor<Requestee>().adaptSnapshot(snapshot))
        .toList());
  }
  return requestees;
}

////cannot delete dispatcher if they have drivers as well
///Also the ticket needs to show the time and driver for confirmation
///an auto message should be sent in case of update or would the push notification be enough???
///flesh out the widget for the dispatcher to see the dropdown for drivers
///and make a confirmation stamp on the end of the ticket
///
///
///COMPLETED
///the dropdown should return a driver as the value so it would be easier to get the driver for the receipt
////build the receipt builder that returns a message and takes the driver as argument
///The ticket should be updated first if the dispatcher wants to make changes
///the receipt needs the current time when it was confirmed and send it as a new message
