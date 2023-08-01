import 'package:bloc/bloc.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'ticket_view_state.dart';

class TicketViewCubit extends Cubit<TicketViewState> {
  static const maxLength = 5;
  static const minLength = 2;
  List<List<String>> formLayoutList;
  TicketViewCubit(this.formLayoutList) : super(TicketViewInitial());

  int findPreviousTimeinForm(int position) {
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    int currentPos = position - 1;
    while (currentPos >= 0) {
      int? parsedInt = int.tryParse(formLayoutList[currentPos][timePos]);
      if (parsedInt != null) {
        lastTime = parsedInt;
        break;
      } else {
        currentPos = currentPos - 1;
      }
    }
    return lastTime;
  }

  deleteFinalTicketRowLayout(List<List<String>> formLayoutList) {
    List<List<String>> formLayoutListCopy = List.of(formLayoutList);
    formLayoutListCopy.removeLast();
    formLayoutListCopy.last[timePos] = stay();
    return formLayoutListCopy;
  }

  List<String> stayRowFormatToLeaveRowFormat({
    required List<String> stayRowFormat,
    required int lastTime,
  }) {
    int hourInMilliseconds = const Duration(hours: 1).inMilliseconds;
    return [stayRowFormat[textPos], (lastTime + hourInMilliseconds).toString()];
  }

  List<String> leaveRowFormatToStayRowFormat({
    required List<String> leaveRowFormat,
  }) {
    return [
      leaveRowFormat[textPos],
      stay(),
    ];
  }

  Future<void> initialize() async {
    await Future.delayed(
      duration,
      () {
        if (formLayoutList.isEmpty) {
          formLayoutList = getNewTicketLayout();
          emit(TicketViewAdded(formLayoutList: formLayoutList));
        } else {
          emit(
            TicketViewAdded(formLayoutList: formLayoutList),
          );
        }
      },
    );
  }

  Future<void> addRow() async {
    await Future.delayed(
      duration,
      () {
        if (formLayoutList.length < maxLength) {
          formLayoutList.add(
            getFinalTicketRowLayout(formLayoutList.first[textPos]),
          );
          emit(
            TicketViewAdded(formLayoutList: formLayoutList),
          );
        }
      },
    );
  }

  Future<void> deleteRow() async {
    await Future.delayed(
      duration,
      () {
        if (formLayoutList.length > minLength) {
          formLayoutList = deleteFinalTicketRowLayout(formLayoutList);
          emit(
            TicketViewDeleted(formLayoutList: formLayoutList),
          );
        }
      },
    );
  }

  Future<void> updateRow(
      {required int colPos,
      required int rowPos,
      required String newValue}) async {
    await Future.delayed(
      duration,
      () {
        formLayoutList[colPos][rowPos] = newValue;
      },
    );
  }

  Future<void> updateStayRowFormatToLeaveRowFormat({
    required int rowPos,
  }) async {
    if (state is TicketViewAdded || state is TicketViewDeleted) {
      await Future.delayed(
        duration,
        () {
          int lastTime = findPreviousTimeinForm(rowPos);
          List<String> stayRowFormat = formLayoutList[rowPos];

          formLayoutList[rowPos] = stayRowFormatToLeaveRowFormat(
            stayRowFormat: stayRowFormat,
            lastTime: lastTime,
          );
          emit(
            TicketViewDeleted(formLayoutList: formLayoutList),
          );
        },
      );
    }
  }

  Future<void> updateLeaveRowToStayRow({
    required int colPos,
  }) async {
    await Future.delayed(
      duration,
      () {
        List<String> leaveRowFormat = formLayoutList[colPos];
        formLayoutList[colPos] = leaveRowFormatToStayRowFormat(
          leaveRowFormat: leaveRowFormat,
        );
        emit(
          TicketViewDeleted(formLayoutList: formLayoutList),
        );
      },
    );
  }
}

const Duration duration = Duration(
  microseconds: 500,
);
