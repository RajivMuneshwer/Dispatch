import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'user_view_state.dart';

class UserViewCubit extends Cubit<UserViewState> {
  UserViewCubit() : super(UserViewInitial());

  Future<void> init<M>({
    required Future<M> Function() func,
  }) async {
    Future.delayed(
      duration,
      () async {
        M data = await func();
        emit(
          UserViewWithData<M>(data: data),
        );
      },
    );
  }
}

const duration = Duration(
  microseconds: 500,
);
