import 'package:bloc/bloc.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'user_view_state.dart';

class UserViewCubit extends Cubit<UserViewState> {
  UserViewCubit() : super(UserViewInitial());

  Future<void> initusers<T extends User>({
    required Future<List<T>> Function() data,
  }) async {
    Future.delayed(duration, () async {
      List<T> users = await data();
      emit(UserViewWithUsers(
        users: users,
      ));
    });
  }

  Future<void> initwidget({
    required Future<Widget> futwidget,
  }) async {
    Future.delayed(duration, () async {
      Widget widget = await futwidget;
      emit(UserViewWithWidget(
        widget: widget,
      ));
    });
  }
}

const duration = Duration(
  microseconds: 500,
);
