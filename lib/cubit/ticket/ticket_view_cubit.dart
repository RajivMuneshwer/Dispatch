import 'package:bloc/bloc.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'ticket_view_state.dart';

class TicketViewCubit extends Cubit<TicketViewState> {
  static const maxLength = 5;
  static const minLength = 2;
  TicketViewWithData initialTicketViewState;
  TicketViewCubit(this.initialTicketViewState) : super(TicketViewInitial());

  int findPreviousTimeinForm(int position) {
    TicketViewState state_ = state;
    if (state_ is! TicketViewWithData) return -1;

    List<List<String>> formLayoutList = state_.formLayoutList;
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
        emit(initialTicketViewState);
      },
    );
  }

  Future<void> addRow(TicketViewState currentState) async {
    await Future.delayed(
      duration,
      () {
        if (currentState is! TicketViewWithData) return;

        List<List<String>> formLayoutList = currentState.formLayoutList;
        if (formLayoutList.length < maxLength) {
          formLayoutList.add(
            getFinalTicketRowLayout(formLayoutList.first[textPos]),
          );
          if (currentState.bottomButtonType == BottomButtonType.submit) {
            emit(
              TicketViewAdded(formLayoutList: formLayoutList),
            );
            return;
          }
          if (currentState.bottomButtonType ==
              BottomButtonType.cancelOrUpdate) {
            emit(TicketViewSubmitted(formLayoutList: formLayoutList));
            return;
          }
        }
        return;
      },
    );
  }

  Future<void> deleteRow(TicketViewState currentState) async {
    await Future.delayed(
      duration,
      () {
        if (currentState is! TicketViewWithData) return;

        List<List<String>> formLayoutList = currentState.formLayoutList;
        if (formLayoutList.length > minLength) {
          formLayoutList = deleteFinalTicketRowLayout(formLayoutList);
          if (currentState.bottomButtonType == BottomButtonType.submit) {
            emit(
              TicketViewDeleted(formLayoutList: formLayoutList),
            );
            return;
          }
          if (currentState.bottomButtonType ==
              BottomButtonType.cancelOrUpdate) {
            emit(TicketViewSubmitted(formLayoutList: formLayoutList));
            return;
          }
        }
        return;
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
        TicketViewState state_ = state;
        if (state_ is! TicketViewWithData) return;

        List<List<String>> formLayoutList = state_.formLayoutList;
        formLayoutList[colPos][rowPos] = newValue;
        emit(TicketViewDeleted(formLayoutList: formLayoutList));
        return;
      },
    );
  }

  Future<void> updateStayRowFormatToLeaveRowFormat({
    required int rowPos,
  }) async {
    await Future.delayed(
      duration,
      () {
        TicketViewState state_ = state;
        if (state_ is! TicketViewWithData) return;

        List<List<String>> formLayoutList = state_.formLayoutList;
        int lastTime = findPreviousTimeinForm(rowPos);
        List<String> stayRowFormat = formLayoutList[rowPos];

        formLayoutList[rowPos] = stayRowFormatToLeaveRowFormat(
          stayRowFormat: stayRowFormat,
          lastTime: lastTime,
        );
        emit(
          TicketViewDeleted(formLayoutList: formLayoutList),
        );
        return;
      },
    );
  }

  Future<void> updateLeaveRowToStayRow({
    required int colPos,
  }) async {
    await Future.delayed(duration, () {
      TicketViewState state_ = state;
      if (state_ is! TicketViewWithData) return;

      List<List<String>> formLayoutList = state_.formLayoutList;
      List<String> leaveRowFormat = formLayoutList[colPos];
      formLayoutList[colPos] = leaveRowFormatToStayRowFormat(
        leaveRowFormat: leaveRowFormat,
      );
      emit(
        TicketViewDeleted(formLayoutList: formLayoutList),
      );
      return;
    });
  }
}

const Duration duration = Duration(
  microseconds: 500,
);
