import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'user_view_state.dart';

class UserViewCubit<M> extends Cubit<UserViewState> {
  M data;
  UserViewCubit({required this.data}) : super(UserViewInitial());

  Future<void> init({
    required Future<M> Function() func,
  }) async =>
      Future.delayed(
        duration,
        () async {
          data = await func();
          emit(
            UserViewWithData<M>(
              data: data,
              canUpdate: true,
            ),
          );
        },
      );

  Future<void> update({
    required Future<M?> Function() downloadfunc,
    required M Function(M newdata, M olddata) combine,
  }) async =>
      Future.delayed(
        duration,
        () async {
          M? newData = await downloadfunc();
          (newData == null)
              ? emit(
                  UserViewWithData(
                    data: data,
                    canUpdate: false,
                  ),
                )
              : emit(
                  UserViewWithData(
                    data: combine(newData, data),
                    canUpdate: true,
                  ),
                );
        },
      );
}

const duration = Duration(
  microseconds: 500,
);
