import 'dart:async';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dispatch/cubit/driverInfo/driver_info_cubit.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:dispatch/screens/car_screens.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DriverHomeScreen extends StatefulWidget {
  final Driver driver;
  const DriverHomeScreen({
    super.key,
    required this.driver,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int currentIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    screens = [
      DriverMessageScreen(user: widget.driver),
      DriverFormScreen(driver: widget.driver),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: StyleProvider(
        style: NavStyle(),
        child: ConvexAppBar(
          color: Settings.onPrimary,
          backgroundColor: Settings.primaryColor,
          curveSize: 75,
          top: 0,
          style: TabStyle.react,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            TabItem(
              icon: FontAwesomeIcons.user,
              title: 'Messages',
            ),
            TabItem(
              icon: FontAwesomeIcons.clipboard,
              title: 'Form Sheet',
            ),
          ],
        ),
      ),
    );
  }
}

class NavStyle extends StyleHook {
  @override
  double get activeIconMargin => 4;

  @override
  double get activeIconSize => 25;

  @override
  double? get iconSize => 20;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 14, color: color);
  }
}

class DriverFormScreen extends StatefulWidget {
  final Driver driver;
  const DriverFormScreen({
    super.key,
    required this.driver,
  });

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  Timer? debounce;
  @override
  void initState() {
    super.initState();
  }

  DateTime strMilliToDate(String? strDateInMilli) {
    if (strDateInMilli != null && strDateInMilli.isNotEmpty) {
      int dateInMilli = int.parse(strDateInMilli);
      return DateTime.fromMillisecondsSinceEpoch(dateInMilli);
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    const formWidgetWidth = 150.0;
    const formOuterHeight = 110.0;
    const formInnerHeight = formOuterHeight - 5;
    const spaceWidth = 30.0;
    return BlocProvider(
      create: (context) => DriverInfoCubit(driver: widget.driver),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Form Sheet"),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
          child: BlocBuilder<DriverInfoCubit, DriverInfoState>(
            builder: (context, state) {
              switch (state) {
                case DriverInfoInitial():
                  {
                    context.read<DriverInfoCubit>().initialize();
                    return Container();
                  }
                case DriverInfoWithData():
                  {
                    var json = state.json;
                    print(json);
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: json.length,
                            itemBuilder: (context, index) => Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Settings.onPrimary,
                              ))),
                              height: formOuterHeight,
                              child: Container(
                                height: formInnerHeight,
                                decoration: BoxDecoration(
                                  color: Settings.primaryColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ListView(
                                    key: UniqueKey(),
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      SizedBox(
                                        width: formWidgetWidth,
                                        child: RequesteeDropdownSearch(
                                          iconColor: Settings.onPrimary,
                                          textColor: Settings.onPrimary,
                                          index: index,
                                          onChanged: (requestee) {
                                            var cubit =
                                                context.read<DriverInfoCubit>();
                                            cubit.updateValue(
                                              index: index,
                                              key: "pickup",
                                              value: requestee ?? "",
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: spaceWidth),
                                      SizedBox(
                                        width: formWidgetWidth,
                                        child: TimePickupButton(
                                          initialDateTime: strMilliToDate(
                                            json["$index"]?["time"],
                                          ),
                                          onPressed: () async {
                                            var pickedTime =
                                                await showTimePicker(
                                              initialEntryMode:
                                                  TimePickerEntryMode.inputOnly,
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            if (pickedTime != null) {
                                              final now = DateTime.now();
                                              DateTime pickedDate = DateTime(
                                                now.year,
                                                now.month,
                                                now.day,
                                                pickedTime.hour,
                                                pickedTime.minute,
                                              );
                                              var cubit = context
                                                  .read<DriverInfoCubit>();
                                              cubit.updateValue(
                                                index: index,
                                                value: pickedDate
                                                    .millisecondsSinceEpoch
                                                    .toString(),
                                                key: "time",
                                              );
                                              return pickedDate;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: spaceWidth),
                                      SizedBox(
                                        width: formWidgetWidth,
                                        child: CarDropDownSearch(
                                          iconColor: Settings.onPrimary,
                                          textColor: Settings.onPrimary,
                                          index: index,
                                          onChanged: (value) {
                                            DriverInfoCubit cubit =
                                                context.read<DriverInfoCubit>();
                                            cubit.updateValue(
                                              index: index,
                                              value: value ?? "",
                                              key: "vehicle",
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: spaceWidth),
                                      SizedBox(
                                        width: formWidgetWidth,
                                        child: PurposeTextField(
                                          iconColor: Settings.onPrimary,
                                          textColor: Settings.onPrimary,
                                          index: index,
                                          onChanged: (value) {
                                            if (debounce?.isActive ?? false) {
                                              debounce?.cancel();
                                            }
                                            debounce = Timer(
                                                const Duration(seconds: 1), () {
                                              context
                                                  .read<DriverInfoCubit>()
                                                  .updateValue(
                                                    index: index,
                                                    value: value ?? "",
                                                    key: "purpose",
                                                  );
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: spaceWidth),
                                      SizedBox(
                                        width: formWidgetWidth,
                                        child: OdometerNumberField(
                                          iconColor: Settings.onPrimary,
                                          index: index,
                                          textColor: Settings.onPrimary,
                                          onChanged: (value) {
                                            if (debounce?.isActive ?? false) {
                                              debounce?.cancel();
                                            }
                                            debounce = Timer(
                                                const Duration(seconds: 1), () {
                                              context
                                                  .read<DriverInfoCubit>()
                                                  .updateValue(
                                                    index: index,
                                                    value: value ?? "",
                                                    key: "odometer",
                                                  );
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: formWidgetWidth),
                                      SizedBox(
                                        width: spaceWidth,
                                        child: TrashButton(
                                          iconColor: Colors.red,
                                          index: index,
                                        ),
                                      ),
                                      const SizedBox(width: spaceWidth)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AddButton(
                            json: json,
                          ),
                        ],
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}

class RequesteeDropdownSearch extends StatelessWidget {
  final int index;
  final Color textColor;
  final Color iconColor;
  final void Function(String?)? onChanged;
  const RequesteeDropdownSearch({
    super.key,
    required this.onChanged,
    required this.index,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) return Container();
        var pickups = state.pickups;
        return DropdownSearch<String>(
          selectedItem: state.json["$index"]?["pickup"],
          items: pickups,
          itemAsString: (pickups) => pickups,
          popupProps: PopupProps.dialog(
            itemBuilder: (context, requestee, isSelected) {
              return CustomBox(children: [
                UserProfilePic(name: requestee),
                UserNameBox(name: requestee)
              ]);
            },
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            baseStyle: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
            dropdownSearchDecoration: InputDecoration(
              icon: const Icon(Icons.people),
              iconColor: iconColor,
              fillColor: Colors.white,
              helperText: "Pickup",
              helperStyle: TextStyle(color: textColor),
              hintText: "Select pickup",
            ),
          ),
          onChanged: onChanged,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        );
      },
    );
  }
}

class TimePickupButton extends StatefulWidget {
  final Future<DateTime?> Function() onPressed;
  final DateTime initialDateTime;
  const TimePickupButton({
    super.key,
    required this.onPressed,
    required this.initialDateTime,
  });

  @override
  State<TimePickupButton> createState() => _TimePickupButtonState();
}

class _TimePickupButtonState extends State<TimePickupButton> {
  late DateTime date;

  String displayTime(DateTime dateTime) {
    return DateFormat().add_jm().format(dateTime);
  }

  @override
  void initState() {
    setState(() {
      date = widget.initialDateTime;
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) return Container();
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Settings.primaryColor,
          ),
          onPressed: () async {
            DateTime? pickedDate = await widget.onPressed();
            setState(() {
              date = pickedDate ?? DateTime.now();
            });
          },
          child: Text(displayTime(date)),
        );
      },
    );
  }
}

class CarDropDownSearch extends StatelessWidget {
  final void Function(String?)? onChanged;
  final Color textColor;
  final Color iconColor;
  final int index;
  const CarDropDownSearch({
    super.key,
    required this.onChanged,
    required this.index,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) return Container();
        var cars = state.cars;
        return DropdownSearch<String>(
          items: cars,
          selectedItem: state.json["$index"]?["vehicle"],
          itemAsString: (car) => car,
          popupProps: PopupProps.dialog(
            itemBuilder: (context, car, isSelected) {
              return CustomBox(children: [
                UserProfilePic(name: car),
                UserNameBox(name: car),
              ]);
            },
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            baseStyle: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
            dropdownSearchDecoration: InputDecoration(
              helperText: "Cars",
              helperStyle: TextStyle(
                color: textColor,
              ),
              hintText: "Select car",
              fillColor: Colors.white,
              iconColor: iconColor,
              icon: FaIcon(FontAwesomeIcons.car),
            ),
          ),
          onChanged: onChanged,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        );
      },
    );
  }
}

class PurposeTextField extends StatelessWidget {
  final int index;
  final double radius = 20.0;
  final Color textColor;
  final Color iconColor;
  final Function(String?)? onChanged;
  const PurposeTextField({
    super.key,
    required this.index,
    required this.onChanged,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) {
          return Container();
        }
        ;
        var json = state.json;
        print(json[index.toString()]?["purpose"]);
        return FormBuilderTextField(
          key: UniqueKey(),
          name: UniqueKey().toString(),
          initialValue: json[index.toString()]?["purpose"] ?? "",
          autocorrect: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          showCursor: true,
          cursorColor: textColor,
          decoration: InputDecoration(
            fillColor: Colors.white,
            icon: const FaIcon(FontAwesomeIcons.lightbulb),
            iconColor: iconColor,
            alignLabelWithHint: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(radius),
                right: Radius.circular(radius),
              ),
              borderSide: BorderSide(
                color: textColor,
                width: 1.5,
              ),
            ),
            helperText: 'Purpose',
            helperStyle: TextStyle(
              color: textColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(radius),
                right: Radius.circular(radius),
              ),
            ),
          ),
          onChanged: onChanged,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.match(r'^[a-zA-Z0-9_\-\s]+$')
          ]),
        );
      },
    );
  }
}

class OdometerNumberField extends StatelessWidget {
  final int index;
  final void Function(String?)? onChanged;
  final Color textColor;
  final Color iconColor;
  const OdometerNumberField({
    super.key,
    required this.index,
    required this.onChanged,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) {
          return Container();
        }
        var json = state.json;
        return FormBuilderTextField(
          key: UniqueKey(),
          name: UniqueKey().toString(),
          initialValue: json[index.toString()]?["odometer"] ?? "",
          autocorrect: true,
          showCursor: true,
          cursorColor: textColor,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            icon: const FaIcon(FontAwesomeIcons.gauge),
            iconColor: iconColor,
            alignLabelWithHint: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: textColor,
                width: 1.5,
              ),
            ),
            helperText: 'Odometer',
            helperStyle: TextStyle(
              color: textColor,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(0),
                right: Radius.circular(0),
              ),
            ),
          ),
          onChanged: onChanged,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.match(r'^[0-9\s]+$')
          ]),
        );
      },
    );
  }
}

class TrashButton extends StatelessWidget {
  final Color iconColor;
  final int index;
  const TrashButton({
    super.key,
    required this.iconColor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) return Container();
        var json = state.json;
        return IconButton(
          iconSize: 31,
          color: iconColor,
          padding: const EdgeInsets.all(8.0),
          onPressed: () {
            var driver = context.read<DriverInfoCubit>().driver;
            Map<String, Map<String, String>> newJson = {};
            showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Delete row"),
                  content: const Text("Delete this row?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        for (var i = 0; i < json.length; i++) {
                          if (i == index) {
                            continue;
                          } else if (i < index) {
                            newJson.addAll(
                                {"$i": json["$i"] ?? emptyMap(driver.name)});
                          } else {
                            newJson.addAll({
                              "${i - 1}": json["$i"] ?? emptyMap(driver.name)
                            });
                          }
                        }
                        Navigator.pop(context, true);
                      },
                      child: const Text("Delete"),
                    )
                  ],
                );
              },
            ).then((value) {
              if (value == true) {
                context.read<DriverInfoCubit>().updateJson(json: newJson);
              }
            });
          },
          icon: const FaIcon(FontAwesomeIcons.trashCan),
        );
      },
    );
  }
}

class AddButton extends StatelessWidget {
  final Map<String, Map<String, String>> json;
  const AddButton({
    super.key,
    required this.json,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverInfoCubit, DriverInfoState>(
      builder: (context, state) {
        if (state is! DriverInfoWithData) return Container();
        return Container(
          height: 50.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Settings.primaryColor,
          ),
          child: IconButton(
            // add button
            onPressed: () async {
              var cubit = context.read<DriverInfoCubit>();
              Map<String, String> newJsonRow = emptyMap(cubit.driver.name);
              int index = json.length;
              int widgetDepth = 1;
              await _dialogueBuilder1(
                context,
                newJsonRow,
                index,
                widgetDepth,
              );
              print(newJsonRow);
              if (newJsonRow
                  case {
                    "pickup": String pickup,
                    "vehicle": String vehicle,
                    "purpose": String purpose,
                    "time": String time,
                    "driver": String driver,
                    "odometer": String odometer,
                    "status": String status,
                  }) {
                if (status != "success") {
                  return;
                }
                json.addAll({
                  index.toString(): {
                    "pickup": pickup,
                    "vehicle": vehicle,
                    "purpose": purpose,
                    "time": time,
                    "driver": driver,
                    "odometer": odometer,
                  },
                });
                cubit.updateJson(json: json);
              }
            },
            icon: const FaIcon(
              FontAwesomeIcons.circlePlus,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

Future<void> _dialogueBuilder1(
  BuildContext context_,
  Map<String, String> jsonRow,
  int index,
  int depth,
) async {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  return showDialog(
    context: context_,
    builder: (context) {
      return AlertDialog(
        title: const Text("Purpose"),
        content: BlocProvider.value(
          value: BlocProvider.of<DriverInfoCubit>(context_),
          child: FormBuilder(
              key: formKey,
              child: PurposeTextField(
                textColor: Settings.onSecondary,
                iconColor: Settings.onSecondary,
                index: index,
                onChanged: (String? str) {
                  jsonRow["purpose"] = str ?? "";
                },
              )),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              await _dialogueBuilder2(
                context_,
                jsonRow,
                index,
                depth + 1,
              );
            },
            child: Text("Next"),
          ),
          TextButton(
              onPressed: () async {
                jsonRow["status"] = "failed";
                int count = 0;
                Navigator.popUntil(context, (route) => ++count > depth);
              },
              child: Text("Cancel"))
        ],
      );
    },
  );
}

Future<void> _dialogueBuilder2(
  BuildContext context_,
  Map<String, String> jsonRow,
  int index,
  int depth,
) {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  return showDialog(
    context: context_,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Time"),
        content: BlocProvider.value(
          value: BlocProvider.of<DriverInfoCubit>(context_),
          child: FormBuilder(
            key: formKey,
            child: TimePickupButton(
              initialDateTime: DateTime.now(),
              onPressed: () async {
                var pickedTime = await showTimePicker(
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  final now = DateTime.now();
                  DateTime pickedDate = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  jsonRow["time"] =
                      pickedDate.millisecondsSinceEpoch.toString();
                  return pickedDate;
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await _dialogueBuilder3(
                  context_,
                  jsonRow,
                  index,
                  depth + 1,
                );
              },
              child: const Text("Next")),
          TextButton(
              onPressed: () async {
                jsonRow["status"] = "failed";
                int count = 0;
                Navigator.popUntil(context, (route) => ++count > depth);
              },
              child: const Text("Cancel"))
        ],
      );
    },
  );
}

_dialogueBuilder3(
  BuildContext context_,
  Map<String, String> jsonRow,
  int index,
  int depth,
) {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  return showDialog(
    context: context_,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Car"),
        content: BlocProvider.value(
          value: BlocProvider.of<DriverInfoCubit>(context_),
          child: FormBuilder(
            key: formKey,
            child: CarDropDownSearch(
              iconColor: Settings.onSecondary,
              textColor: Settings.onSecondary,
              index: index,
              onChanged: (String? car) {
                jsonRow["vehicle"] = car ?? "";
              },
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await _dialogueBuilder4(
                  context_,
                  jsonRow,
                  index,
                  depth + 1,
                );
              },
              child: const Text("Next")),
          TextButton(
              onPressed: () async {
                jsonRow["status"] = "failed";
                int count = 0;
                Navigator.popUntil(context, (route) => ++count > depth);
              },
              child: const Text("Cancel"))
        ],
      );
    },
  );
}

_dialogueBuilder4(
  BuildContext context_,
  Map<String, String> jsonRow,
  int index,
  int depth,
) {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  return showDialog(
    context: context_,
    builder: (context) {
      return AlertDialog(
        title: const Text("Odometer"),
        content: BlocProvider.value(
          value: BlocProvider.of<DriverInfoCubit>(context_),
          child: FormBuilder(
            key: formKey,
            child: OdometerNumberField(
              iconColor: Settings.onSecondary,
              textColor: Settings.onSecondary,
              index: index,
              onChanged: (String? value) {
                jsonRow["odometer"] = value?.trim() ?? "";
              },
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await _dialogueBuilder5(
                  context_,
                  jsonRow,
                  index,
                  depth + 1,
                );
              },
              child: const Text("Next")),
          TextButton(
              onPressed: () async {
                jsonRow["status"] = "failed";
                int count = 0;
                Navigator.popUntil(context, (route) => ++count > depth);
              },
              child: const Text("Cancel"))
        ],
      );
    },
  );
}

_dialogueBuilder5(
  BuildContext context_,
  Map<String, String> jsonRow,
  int index,
  int depth,
) {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  return showDialog(
    context: context_,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Pickup"),
        content: BlocProvider.value(
          value: BlocProvider.of<DriverInfoCubit>(context_),
          child: FormBuilder(
            key: formKey,
            child: RequesteeDropdownSearch(
              iconColor: Settings.onSecondary,
              textColor: Settings.onSecondary,
              index: index,
              onChanged: (String? requestee) {
                jsonRow["pickup"] = requestee ?? "";
              },
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                jsonRow["status"] = "success";
                int count = 0;
                Navigator.popUntil(context, (route) => ++count > depth);
              },
              child: const Text("Finish")),
          TextButton(
              onPressed: () async {
                jsonRow["status"] = "failed";
                int count = 0;
                Navigator.popUntil(context, (route) => ++count > depth);
              },
              child: const Text("Cancel"))
        ],
      );
    },
  );
}
